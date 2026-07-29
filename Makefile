# HostHub — Makefile
# ===================================
#
# Usage:  make help
#         make apply-migrations-local
#         make create-admin-local EMAIL=me@example.com PASSWORD=secret
#         make functions-deploy ENV=stg

.DEFAULT_GOAL := help

# ----------------------------
# Project configuration
# ----------------------------
PROJECT_NAME   := hosthub
WORKSPACE_ROOT := $(abspath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
SUPABASE_DIR   := $(WORKSPACE_ROOT)/supabase

# Edge-function secrets pushed by `make functions-secrets-set ENV=<env>` — each
# is read from the ENV_FILE (hosthub_secrets/hosthub-<env>.env) and only pushed
# when present. Set BEFORE the include so this wins over the shared `?=` default.
# Email (Resend) + the translate-content provider config; the free MyMemory
# default needs no key, DEEPL_API_KEY opts into DeepL, LIBRETRANSLATE_URL into a
# self-hosted engine (see supabase/functions/translate-content).
# SUPPORT_EMAIL and EMAIL_ENV_LABEL are read by send_auth_email and
# invite_site_member: the auth mail templates moved into the functions, so the
# support address in their footer and the environment badge that used to come
# from the console's own config have to be available server-side. Neither is
# secret; they travel with the other function config.
FUNCTION_SECRET_VARS := RESEND_API_KEY FROM_EMAIL FROM_NAME DASHBOARD_BASE_URL \
                        SUPPORT_EMAIL EMAIL_ENV_LABEL \
                        DEEPL_API_KEY TRANSLATE_PROVIDER \
                        LIBRETRANSLATE_URL LIBRETRANSLATE_API_KEY MYMEMORY_EMAIL

# Include shared Supabase targets
include $(SUPABASE_DIR)/make/supabase-common.mk

# ----------------------------
# Sites worker (public websites) configuration
# ----------------------------
WEB_DIR         := $(WORKSPACE_ROOT)/web
WEB_WORKER      ?= hosthub-sites
SECRETS_DIR_ABS := $(WORKSPACE_ROOT)/../hosthub_secrets
# Split secret files sourced for the sites worker: client + shared-server
# (CLOUDFLARE_API_TOKEN, RESEND_API_KEY) + prd-server (SUPABASE_SECRET_KEY).
WEB_SECRET_ENV    := $(SECRETS_DIR_ABS)/hosthub-prd.env
WEB_SHARED_ENV    := $(SECRETS_DIR_ABS)/hosthub-shared-server.env
WEB_SERVER_ENV    := $(SECRETS_DIR_ABS)/hosthub-prd-server.env
WEB_LOCAL_ENV     := $(WEB_DIR)/.env.local
# Server-only PLATFORM-WIDE secrets synced to the shared sites worker.
# Intentionally NOT here — these are per consumer, resolved per site from the DB:
#   - LODGIFY_API_KEY   (console → lodgify_api_keys, per owner)
#   - CONTACT_EMAIL_TO  (per-site contact recipient) + per-site sender name
# Only genuinely platform-wide secrets belong below: the shared Resend key and
# the Supabase secret key (used to read per-site config from the DB).
WEB_SECRET_KEYS := SUPABASE_SECRET_KEY RESEND_API_KEY

# ============================
# Combined deploy
# ============================

## deploy — Apply migrations, deploy all edge functions, and push secrets.
## Usage: make deploy ENV=stg
.PHONY: deploy
deploy: apply-migrations functions-deploy functions-secrets-set
	@echo ""
	@echo "  ✓ Full deploy to $(ENV) complete (migrations + functions + secrets)."
	@echo ""

# ============================
# Sites worker secrets
# ============================

## web-secrets — Upload the shared sites worker's runtime secrets to Cloudflare.
## Reads values from hosthub-prd.env + web/.env.local and pushes each present key
## via `wrangler secret put` (never prints values). Lodgify is intentionally
## excluded — it is per consumer (console → lodgify_api_keys, resolved per site).
## Usage: make web-secrets [WEB_WORKER=hosthub-sites]
.PHONY: web-secrets
web-secrets:
	@command -v npx >/dev/null 2>&1 || { echo "npx not found (need Node)"; exit 1; }
	@bash -c 'set -a; \
	  for __f in "$(WEB_SECRET_ENV)" "$(WEB_SHARED_ENV)" "$(WEB_SERVER_ENV)" "$(WEB_LOCAL_ENV)"; do [ -f "$$__f" ] && . "$$__f"; done; \
	  set +a; \
	  [ -n "$$CLOUDFLARE_API_TOKEN" ] || { echo "Missing CLOUDFLARE_API_TOKEN in $(WEB_SHARED_ENV)"; exit 1; }; \
	  cd "$(WEB_DIR)"; \
	  echo "Syncing secrets to worker: $(WEB_WORKER)"; \
	  for k in $(WEB_SECRET_KEYS); do \
	    v="$${!k}"; \
	    if [ -n "$$v" ]; then \
	      printf "%s" "$$v" | npx wrangler secret put "$$k" --name "$(WEB_WORKER)" >/dev/null \
	        && echo "  OK   $$k" || echo "  FAIL $$k"; \
	    else echo "  SKIP $$k (not in env files)"; fi; \
	  done; \
	  echo "Done."'

# ============================
# Help
# ============================
.PHONY: help
help: _common-help
	@echo ""
	@echo "  COMBINED"
	@echo "  ──────────────────────────────────────"
	@echo "  make deploy ENV=stg                      Apply migrations + deploy functions + push secrets"
	@echo ""
	@echo "  PROJECT-SPECIFIC"
	@echo "  ──────────────────────────────────────"
	@echo "  make create-admin-local EMAIL=… PASSWORD=… [USERNAME=…]"
	@echo "                                           Create an admin user in local DB"
	@echo "  make create-admin ENV=stg EMAIL=… PASSWORD=… [USERNAME=…]"
	@echo "                                           Create an admin user in remote DB"
	@echo ""

# ============================
# Project-specific: admin users
# ============================

## create-admin-local — Create an admin user in the local DB.
## Calls the create_local_admin_user() SQL function (auth.users + profiles).
## USERNAME defaults to EMAIL if not provided.
## Example: make create-admin-local EMAIL=me@example.com PASSWORD=secret USERNAME=Taco
.PHONY: create-admin-local
create-admin-local: preflight-local-db
	@test -n "$(EMAIL)" || { echo "Usage: make create-admin-local EMAIL=… PASSWORD=… [USERNAME=…]"; exit 1; }
	@test -n "$(PASSWORD)" || { echo "Usage: make create-admin-local EMAIL=… PASSWORD=… [USERNAME=…]"; exit 1; }
	@$(PSQL) "$(LOCAL_DB_URL)" -v ON_ERROR_STOP=1 \
	  -c "SELECT create_local_admin_user('$(EMAIL)', '$(PASSWORD)', '$(or $(USERNAME),$(EMAIL))');" \
	&& echo "Admin user created."

## create-admin — Create an admin user in the remote DB.
## Requires ENV=stg|prd. Asks for confirmation before running.
## USERNAME defaults to EMAIL if not provided.
## Example: make create-admin ENV=stg EMAIL=me@example.com PASSWORD=secret USERNAME=Taco
.PHONY: create-admin
create-admin: preflight check-pg-version
	@test -n "$(EMAIL)" || { echo "Usage: make create-admin ENV=… EMAIL=… PASSWORD=… [USERNAME=…]"; exit 1; }
	@test -n "$(PASSWORD)" || { echo "Usage: make create-admin ENV=… EMAIL=… PASSWORD=… [USERNAME=…]"; exit 1; }
	$(call confirm-remote,create-admin)
	@. "$(ENV_FILE)" 2>/dev/null || true; \
	DB_URL="$${DB_URL:-$$SUPABASE_DB_URL}"; \
	if [ -z "$$DB_URL" ]; then echo "Missing DB_URL; set SUPABASE_DB_URL in $(ENV_FILE) or pass DB_URL=..."; exit 1; fi; \
	$(PSQL) "$$DB_URL" -v ON_ERROR_STOP=1 \
	  -c "SELECT create_local_admin_user('$(EMAIL)', '$(PASSWORD)', '$(or $(USERNAME),$(EMAIL))');" \
	&& echo "Admin user created on $(ENV)."
