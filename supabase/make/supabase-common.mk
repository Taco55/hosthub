# supabase-common.mk — Shared Supabase targets
# ================================================
# Include this from your project Makefile after setting:
#   PROJECT_NAME    := myproject
#   WORKSPACE_ROOT  := $(abspath ...)
#
# Optional overrides (set before include):
#   SUPABASE_DIR          (default: $(WORKSPACE_ROOT)/supabase)
#   SCHEMA_DIR_NAME       (default: schema_dump)
#   MIN_PG_VERSION        (default: 17)
#   FUNCTION_SECRET_VARS  (default: RESEND_API_KEY FROM_EMAIL FROM_NAME DASHBOARD_BASE_URL TESTFLIGHT_URL)

# ----------------------------
# Guard: required variables
# ----------------------------
ifndef PROJECT_NAME
  $(error PROJECT_NAME must be set before including supabase-common.mk)
endif
ifndef WORKSPACE_ROOT
  $(error WORKSPACE_ROOT must be set before including supabase-common.mk)
endif

# ----------------------------
# Defaults
# ----------------------------
ENV ?= stg
SUPABASE_DIR       ?= $(WORKSPACE_ROOT)/supabase
SCHEMA_DIR_NAME    ?= schema_dump
MIN_PG_VERSION     ?= 17
FUNCTION_SECRET_VARS ?= RESEND_API_KEY FROM_EMAIL FROM_NAME DASHBOARD_BASE_URL TESTFLIGHT_URL

# ----------------------------
# Derived paths
# ----------------------------
CONFIG_FILE    ?= $(SUPABASE_DIR)/config.toml
FUNCS_DIR      ?= $(SUPABASE_DIR)/functions
MIGRATIONS_DIR ?= $(SUPABASE_DIR)/migrations
SEED_DIR       ?= $(SUPABASE_DIR)/seed
SCHEMA_DIR     := $(SUPABASE_DIR)/$(SCHEMA_DIR_NAME)
SCHEMA_LATEST  := $(SCHEMA_DIR)/latest_$(ENV).sql
LOCAL_SNAPSHOT ?= $(SCHEMA_DIR)/latest_local.sql
TMP_SNAPSHOT_FILE := /tmp/$(PROJECT_NAME)_schema_$(ENV).sql
EDGE_CONTAINER ?= supabase_edge_runtime_$(PROJECT_NAME)_local

# Secrets directory — prefers in-repo `secrets/`, then external fallbacks.
SECRETS_DIR ?= $(shell \
	if [ -d "$(WORKSPACE_ROOT)/secrets" ]; then echo "$(WORKSPACE_ROOT)/secrets"; \
	elif [ -d "$(WORKSPACE_ROOT)/../$(PROJECT_NAME)_secrets" ]; then echo "$(WORKSPACE_ROOT)/../$(PROJECT_NAME)_secrets"; \
	elif [ -d "$(WORKSPACE_ROOT)/../project_secrets" ]; then echo "$(WORKSPACE_ROOT)/../project_secrets"; \
	elif [ -d "$(WORKSPACE_ROOT)/../project-secrets" ]; then echo "$(WORKSPACE_ROOT)/../project-secrets"; \
	fi)
ENV_FILE      ?= $(SECRETS_DIR)/$(PROJECT_NAME)-$(ENV).env
LOCAL_ENV_FILE ?= $(SECRETS_DIR)/$(PROJECT_NAME)-dev.env

# ----------------------------
# Local ports (from config.toml)
# ----------------------------
TOML_DB_PORT     := $(shell awk 'BEGIN{s=0} /^\[db\]/{s=1;next} /^\[/{s=0} s&&$$1~/^port/{for(i=1;i<=NF;i++)if($$i~/^[0-9]+$$/){print $$i;exit}}' $(CONFIG_FILE) 2>/dev/null)
TOML_API_PORT    := $(shell awk 'BEGIN{s=0} /^\[api\]/{s=1;next} /^\[/{s=0} s&&$$1~/^port/{for(i=1;i<=NF;i++)if($$i~/^[0-9]+$$/){print $$i;exit}}' $(CONFIG_FILE) 2>/dev/null)
TOML_STUDIO_PORT := $(shell awk 'BEGIN{s=0} /^\[studio\]/{s=1;next} /^\[/{s=0} s&&$$1~/^port/{for(i=1;i<=NF;i++)if($$i~/^[0-9]+$$/){print $$i;exit}}' $(CONFIG_FILE) 2>/dev/null)
LOCAL_DB_URL     ?= postgresql://postgres:postgres@127.0.0.1:$(TOML_DB_PORT)/postgres
STUDIO_URL       ?= http://127.0.0.1:$(TOML_STUDIO_PORT)

# ----------------------------
# Tools
# ----------------------------
PG_BIN         ?= $(shell brew --prefix postgresql@17 2>/dev/null)/bin
PG_DUMP        ?= $(PG_BIN)/pg_dump
PSQL           ?= $(PG_BIN)/psql
DB_URL_NORMALIZER ?= $(SUPABASE_DIR)/make/normalize_db_url.py
REQUIRED_TOOLS := $(PG_DUMP) $(PSQL) supabase python3
PG_MAJOR       := $(shell $(PG_DUMP) --version 2>/dev/null | sed -n 's/.* \([0-9][0-9]*\)\..*/\1/p')

# ----------------------------
# Safety: confirm-remote macro
# ----------------------------
# On stg: asks "Run <action> on stg? [y/N]".
# On prd: asks to type "prd" to confirm (double safety).

## Resolve the Supabase management API token from env file, shell, or macOS keychain.
define resolve-mgmt-token
	MGMT_TOKEN="$${SUPABASE_ACCESS_TOKEN:-$${SUPABASE_MANAGEMENT_TOKEN:-$${SUPABASE_PAT:-}}}"; \
	if [ -z "$$MGMT_TOKEN" ]; then \
	  KEYCHAIN_RAW=$$(security find-generic-password -s "Supabase CLI" -a "supabase" -w 2>/dev/null || true); \
	  if [ -n "$$KEYCHAIN_RAW" ]; then \
	    case "$$KEYCHAIN_RAW" in \
	      go-keyring-base64:*) \
	        B64="$${KEYCHAIN_RAW#go-keyring-base64:}"; \
	        MGMT_TOKEN=$$(printf "%s" "$$B64" | base64 --decode 2>/dev/null || printf "%s" "$$B64" | base64 -D 2>/dev/null || true); \
	        ;; \
	      *) MGMT_TOKEN="$$KEYCHAIN_RAW" ;; \
	    esac; \
	  fi; \
	fi; \
	: "$${MGMT_TOKEN:?Missing Management token (SUPABASE_ACCESS_TOKEN or SUPABASE_MANAGEMENT_TOKEN or SUPABASE_PAT) in $(ENV_FILE), shell env, or macOS keychain}"
endef

define confirm-remote
	@if [ "$(ENV)" = "prd" ]; then \
	  printf "\n  ⚠  You are about to run a $(1) action on PRODUCTION (prd).\n"; \
	  read -p "  Type 'prd' to confirm: " c; [ "$$c" = "prd" ] || { echo "Aborted."; exit 1; }; \
	else \
	  read -p "Run $(1) on $(ENV)? [y/N] " c; [ "$$c" = "y" ] || { echo "Aborted."; exit 1; }; \
	fi
endef

# ============================
# Preflight checks
# ============================
.PHONY: preflight preflight-local-db preflight-local check-pg-version

## preflight — Verify required CLI tools exist and the remote env file is present.
preflight:
	@for t in $(REQUIRED_TOOLS); do command -v $$t >/dev/null || { echo "Missing tool: $$t"; exit 1; }; done
	@test -f $(ENV_FILE) || { echo "Missing env file: $(ENV_FILE)"; exit 1; }

## preflight-local-db — Verify CLI tools and local Supabase ports from config.toml.
preflight-local-db:
	@for t in $(REQUIRED_TOOLS); do command -v $$t >/dev/null || { echo "Missing tool: $$t"; exit 1; }; done
	@test -f "$(CONFIG_FILE)" || { echo "Missing Supabase config: $(CONFIG_FILE)"; exit 1; }
	@test -n "$(TOML_DB_PORT)" || { echo "Missing [db].port in $(CONFIG_FILE)"; exit 1; }
	@test -n "$(TOML_API_PORT)" || { echo "Missing [api].port in $(CONFIG_FILE)"; exit 1; }
	@test -n "$(TOML_STUDIO_PORT)" || { echo "Missing [studio].port in $(CONFIG_FILE)"; exit 1; }

## preflight-local — Verify supabase CLI and local dev env file exist.
preflight-local:
	@command -v supabase >/dev/null || { echo "Missing tool: supabase"; exit 1; }
	@test -f "$(LOCAL_ENV_FILE)" || { echo "Missing local env file: $(LOCAL_ENV_FILE)"; exit 1; }

## check-pg-version — Ensure pg_dump is >= MIN_PG_VERSION.
check-pg-version:
	@if [ -z "$(PG_MAJOR)" ]; then echo "pg_dump not found"; exit 1; fi
	@if [ "$(PG_MAJOR)" -lt $(MIN_PG_VERSION) ]; then echo "pg_dump $(PG_MAJOR) detected. Need >= $(MIN_PG_VERSION)"; exit 1; fi

# ============================
# LOCAL — Database
# ============================

## apply-migrations-local — Apply all SQL files in supabase/migrations/ to the local DB.
## Skips the baseline migration if profiles table already exists.
## After applying, dumps the schema to latest_local.sql.
.PHONY: apply-migrations-local
apply-migrations-local: preflight-local-db
	@DB_URL="$(LOCAL_DB_URL)"; \
	case "$$DB_URL" in *127.0.0.1:*|*localhost:*) ;; *) echo "Refusing non-local DB_URL: $$DB_URL"; exit 1;; esac; \
	set -- $(MIGRATIONS_DIR)/*.sql; \
	if [ -e "$$1" ]; then \
	  for f in "$$@"; do \
	    if echo "$$f" | grep -q "_baseline.sql$$"; then \
	      if $(PSQL) "$$DB_URL" -tAc "SELECT to_regclass('public.profiles') IS NOT NULL" | grep -q t; then \
	        echo "- Skipping $$f (baseline already applied)"; \
	        continue; \
	      fi; \
	    fi; \
	    echo "- Applying $$f"; \
	    $(PSQL) "$$DB_URL" -v ON_ERROR_STOP=1 -f "$$f" || exit 1; \
	  done; \
	else echo "- No migration files in $(MIGRATIONS_DIR)"; fi
	@$(PG_DUMP) --schema=public --schema-only "$(LOCAL_DB_URL)" > "$(LOCAL_SNAPSHOT)"
	@echo "Local snapshot updated: $(LOCAL_SNAPSHOT)"

## dump-schema-local — Dump the local public schema to latest_local.sql.
.PHONY: dump-schema-local
dump-schema-local: preflight-local-db check-pg-version
	@mkdir -p $(SCHEMA_DIR)
	@$(PG_DUMP) --schema=public --schema-only --format=plain \
	  --dbname="$(LOCAL_DB_URL)" --file="$(LOCAL_SNAPSHOT)"
	@echo "Wrote $(LOCAL_SNAPSHOT)"

## rebuild-schema-local — Drop and rebuild the local public schema from the bundled snapshot.
.PHONY: rebuild-schema-local
rebuild-schema-local: ENV=dev
rebuild-schema-local: preflight check-pg-version
	@$(MAKE) -C "$(SUPABASE_DIR)" ENV=dev rebuild-schema-local

## seed-local — Run all SQL files in supabase/seed/ against the local DB.
.PHONY: seed-local
seed-local: preflight-local-db
	@DB_URL="$(LOCAL_DB_URL)"; \
	case "$$DB_URL" in *127.0.0.1:*|*localhost:*) ;; *) echo "Refusing non-local DB_URL: $$DB_URL"; exit 1;; esac; \
	set -- $(SEED_DIR)/*.sql; \
	if [ -e "$$1" ]; then \
	  for f in "$$@"; do echo "- Seeding $$f"; $(PSQL) "$$DB_URL" -v ON_ERROR_STOP=1 -f "$$f" || exit 1; done; \
	else echo "- No seed files in $(SEED_DIR)"; fi

## sync-env-to-local — Copy the schema from a remote environment to the local DB.
## Destructive: drops the local public schema before importing.
.PHONY: sync-env-to-local
sync-env-to-local: preflight check-pg-version
	@. "$(ENV_FILE)"; \
	DB_URL="$${DB_URL:-$$SUPABASE_DB_URL}"; \
	DB_URL="$$(python3 '$(DB_URL_NORMALIZER)' "$$DB_URL" "$${SUPABASE_DB_PASSWORD:-}")" || exit 1; \
	read -p "This will DROP local schema public. Continue? [y/N] " a; [ "$$a" = "y" ] || exit 1; \
	$(PSQL) "$(LOCAL_DB_URL)" -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;"; \
	$(PG_DUMP) --schema=public --schema-only "$$DB_URL" \
	  | sed -E '/^(CREATE|ALTER|COMMENT) SCHEMA public/d' \
	  | $(PSQL) "$(LOCAL_DB_URL)" -v ON_ERROR_STOP=1
	@echo "Local schema refreshed from $(ENV)"

# ============================
# LOCAL — Edge Functions
# ============================

## functions-serve-local — Start serving all edge functions locally.
.PHONY: functions-serve-local
functions-serve-local: preflight-local
	@$(MAKE) functions-stop-local >/dev/null
	@echo "Serving all functions locally with $(LOCAL_ENV_FILE)…"
	@supabase --workdir "$(WORKSPACE_ROOT)" functions serve --no-verify-jwt --env-file "$(LOCAL_ENV_FILE)"

## functions-stop-local — Stop and remove the local edge runtime Docker container.
.PHONY: functions-stop-local
functions-stop-local:
	-@docker stop $(EDGE_CONTAINER) >/dev/null 2>&1 || true
	-@docker rm   $(EDGE_CONTAINER) >/dev/null 2>&1 || true
	@echo "Local edge runtime stopped."

## functions-logs-local — Tail the logs of the local edge runtime container.
.PHONY: functions-logs-local
functions-logs-local:
	@docker logs -f $(EDGE_CONTAINER)

# ============================
# REMOTE — Database
# ============================

## apply-migrations — Apply all SQL files in supabase/migrations/ to the remote DB.
.PHONY: apply-migrations
apply-migrations: preflight check-pg-version
	$(call confirm-remote,apply-migrations)
	@mkdir -p $(SCHEMA_DIR)
	@. "$(ENV_FILE)" 2>/dev/null || true; \
	DB_URL="$${DB_URL:-$$SUPABASE_DB_URL}"; \
	if [ -z "$$DB_URL" ]; then echo "Missing DB_URL; set SUPABASE_DB_URL in $(ENV_FILE) or pass DB_URL=..."; exit 1; fi; \
	DB_URL="$$(python3 '$(DB_URL_NORMALIZER)' "$$DB_URL" "$${SUPABASE_DB_PASSWORD:-}")" || exit 1; \
	set -- $(MIGRATIONS_DIR)/*.sql; \
	if [ -e "$$1" ]; then \
	  for f in "$$@"; do echo "- Applying $$f"; $(PSQL) "$$DB_URL" -v ON_ERROR_STOP=1 -f "$$f" || exit 1; done; \
	else echo "- No migration files in $(MIGRATIONS_DIR)"; fi; \
	$(PG_DUMP) --schema=public --schema-only --format=plain \
	  --dbname="$$DB_URL" --file="$(TMP_SNAPSHOT_FILE)" || exit 1; \
	mv "$(TMP_SNAPSHOT_FILE)" "$(SCHEMA_LATEST)" || exit 1; \
	echo "Remote snapshot updated: $(SCHEMA_LATEST)"; \
	echo "Remote migrations applied to $(ENV)"

## dump-schema — Dump the remote public schema to latest_<ENV>.sql.
.PHONY: dump-schema
dump-schema: preflight check-pg-version
	@mkdir -p $(SCHEMA_DIR)
	@. "$(ENV_FILE)"; \
	DB_URL="$${DB_URL:-$$SUPABASE_DB_URL}"; \
	if [ -z "$$DB_URL" ]; then echo "Missing DB_URL; set SUPABASE_DB_URL in $(ENV_FILE) or pass DB_URL=..."; exit 1; fi; \
	DB_URL="$$(python3 '$(DB_URL_NORMALIZER)' "$$DB_URL" "$${SUPABASE_DB_PASSWORD:-}")" || exit 1; \
	$(PG_DUMP) --schema=public --schema-only --format=plain \
	  --dbname="$$DB_URL" --file="$(SCHEMA_LATEST)"
	@echo "Wrote $(SCHEMA_LATEST)"

## rebuild-schema — Drop and rebuild the remote public schema (destructive).
.PHONY: rebuild-schema
rebuild-schema: preflight check-pg-version
	$(call confirm-remote,rebuild-schema)
	@$(MAKE) -C "$(SUPABASE_DIR)" rebuild-schema

## seed-remote — Run all SQL files in supabase/seed/ against the remote DB.
.PHONY: seed-remote
seed-remote: preflight check-pg-version
	$(call confirm-remote,seed-remote)
	@. "$(ENV_FILE)" 2>/dev/null || true; \
	DB_URL="$${DB_URL:-$$SUPABASE_DB_URL}"; \
	if [ -z "$$DB_URL" ]; then echo "Missing DB_URL; set SUPABASE_DB_URL in $(ENV_FILE) or pass DB_URL=..."; exit 1; fi; \
	DB_URL="$$(python3 '$(DB_URL_NORMALIZER)' "$$DB_URL" "$${SUPABASE_DB_PASSWORD:-}")" || exit 1; \
	set -- $(SEED_DIR)/*.sql; \
	if [ -e "$$1" ]; then \
	  for f in "$$@"; do echo "- Seeding $$f"; $(PSQL) "$$DB_URL" -v ON_ERROR_STOP=1 -f "$$f" || exit 1; done; \
	else echo "- No seed files in $(SEED_DIR)"; fi

# ============================
# REMOTE — Edge Functions
# ============================

## functions-deploy — Deploy all edge functions to the remote Supabase project.
.PHONY: functions-deploy
functions-deploy: preflight
	$(call confirm-remote,functions-deploy)
	@set -a; . "$(ENV_FILE)"; set +a; \
	: "$${SUPABASE_URL:?Missing SUPABASE_URL in $(ENV_FILE)}"; \
	REF=$$(echo "$$SUPABASE_URL" | sed -E 's#https?://([^./]+)\.supabase\.co.*#\1#'); \
	echo "Deploying functions to $(ENV) (ref=$$REF)…"; \
	find "$(FUNCS_DIR)" -mindepth 1 -maxdepth 1 -type d ! -name '_*' ! -name 'shared' ! -name '.DS_Store' \
	| while read -r d; do \
	  name=$$(basename "$$d"); \
	  if [ -f "$$d/index.ts" ] || [ -f "$$d/index.tsx" ] || [ -f "$$d/index.js" ] || [ -f "$$d/index.jsx" ]; then \
	    echo "- $$name"; supabase --workdir "$(WORKSPACE_ROOT)" functions deploy "$$name" --project-ref "$$REF" || exit 1; \
	  else \
	    echo "- skip $$name (no index.*)"; \
	  fi; \
	done; \
	echo "Deploy complete."

## auth-config-show — Show the current Supabase Auth URL config (site_url + uri_allow_list).
## Usage: make auth-config-show ENV=stg
.PHONY: auth-config-show
auth-config-show: preflight
	@set -a; . "$(ENV_FILE)"; set +a; \
	: "$${SUPABASE_URL:?Missing SUPABASE_URL in $(ENV_FILE)}"; \
	$(resolve-mgmt-token) \
	REF=$$(echo "$$SUPABASE_URL" | sed -E 's#https?://([^./]+)\.supabase\.co.*#\1#'); \
	echo "Fetching auth config for $(ENV) (ref=$$REF)…"; \
	curl -fsS "https://api.supabase.com/v1/projects/$$REF/config/auth" \
	  -H "Authorization: Bearer $$MGMT_TOKEN" \
	  -H "Content-Type: application/json"

## auth-config-set — Set the Supabase Auth URL config (site_url + uri_allow_list).
## SITE_URL defaults to DASHBOARD_BASE_URL from the env file.
## REDIRECT_URLS defaults to "<SITE_URL>/**".
## LOCAL_PORT adds "http://localhost:<LOCAL_PORT>/**" to REDIRECT_URLS.
## Usage:
##   make auth-config-set ENV=stg LOCAL_PORT=43000
##   make auth-config-set ENV=stg SITE_URL=https://example.com REDIRECT_URLS='https://example.com/**,http://localhost:43000/**'
.PHONY: auth-config-set
auth-config-set: preflight
	$(call confirm-remote,auth-config-set)
	@set -a; . "$(ENV_FILE)"; set +a; \
	: "$${SUPABASE_URL:?Missing SUPABASE_URL in $(ENV_FILE)}"; \
	$(resolve-mgmt-token) \
	REF=$$(echo "$$SUPABASE_URL" | sed -E 's#https?://([^./]+)\.supabase\.co.*#\1#'); \
	SITE_URL="$${SITE_URL:-$${DASHBOARD_BASE_URL:-}}"; \
	if [ -z "$$SITE_URL" ]; then \
	  echo "Missing SITE_URL and DASHBOARD_BASE_URL is empty in $(ENV_FILE)"; \
	  exit 1; \
	fi; \
	REDIRECT_URLS="$${REDIRECT_URLS:-$$SITE_URL/**}"; \
	if [ -n "$$LOCAL_PORT" ]; then \
	  REDIRECT_URLS="$$REDIRECT_URLS,http://localhost:$$LOCAL_PORT/**"; \
	fi; \
	echo "Updating auth config for $(ENV) (ref=$$REF)…"; \
	echo "site_url=$$SITE_URL"; \
	echo "uri_allow_list=$$REDIRECT_URLS"; \
	curl -fsS -X PATCH "https://api.supabase.com/v1/projects/$$REF/config/auth" \
	  -H "Authorization: Bearer $$MGMT_TOKEN" \
	  -H "Content-Type: application/json" \
	  -d "$$(printf '{"site_url":"%s","uri_allow_list":"%s"}' "$$SITE_URL" "$$REDIRECT_URLS")" \
	  >/dev/null; \
	echo "Auth config updated."

## functions-secrets-set — Push env secrets to the remote Supabase project.
## Which variables to push is controlled by FUNCTION_SECRET_VARS.
.PHONY: functions-secrets-set
functions-secrets-set: preflight
	$(call confirm-remote,functions-secrets-set)
	@set -a; . "$(ENV_FILE)"; set +a; \
	: "$${SUPABASE_URL:?Missing SUPABASE_URL in $(ENV_FILE)}"; \
	REF=$$(echo "$$SUPABASE_URL" | sed -E 's#https?://([^./]+)\.supabase\.co.*#\1#'); \
	echo "Setting function secrets for $(ENV) (ref=$$REF)…"; \
	ARGS=""; \
	for var in $(FUNCTION_SECRET_VARS); do \
	  val=$$(eval echo "\$$$$var"); \
	  if [ -n "$$val" ]; then ARGS="$$ARGS $$var=$$val"; fi; \
	done; \
	if [ -n "$$ARGS" ]; then \
	  supabase --workdir "$(WORKSPACE_ROOT)" secrets set --project-ref $$REF $$ARGS; \
	else \
	  echo "No secrets found to set."; \
	fi

# ============================
# Info
# ============================

## show-config — Print the current ENV, env file path, local URLs, and remote config.
.PHONY: show-config
show-config:
	@echo ""
	@echo "  Project:      $(PROJECT_NAME)"
	@echo "  ENV:          $(ENV)"
	@echo "  Env file:     $(ENV_FILE)"
	@echo "  Local DB:     $(LOCAL_DB_URL)"
	@echo "  Local Studio: $(STUDIO_URL)"
	@echo ""
	@if [ -f "$(ENV_FILE)" ]; then \
	  echo "  Remote config:"; \
	  grep -E '^(SUPABASE_DB_URL|SUPABASE_URL|SUPABASE_KEY|SUPABASE_ANON_KEY|DASHBOARD_BASE_URL)=' "$(ENV_FILE)" | sed 's/^/    /' || true; \
	  echo ""; \
	else \
	  echo "  (no env file found for $(ENV))"; echo ""; \
	fi

# ============================
# Help (common portion)
# ============================
.PHONY: _common-help
_common-help:
	@echo ""
	@_title="$(PROJECT_NAME) — database & functions"; \
	echo "  $$_title"; \
	printf '  '; printf '=%.0s' $$(seq 1 $${#_title}); echo ""
	@echo ""
	@echo "  LOCAL (127.0.0.1, no env file needed)"
	@echo "  ──────────────────────────────────────"
	@echo "  make apply-migrations-local              Apply all migrations to local DB"
	@echo "  make dump-schema-local                   Dump local schema to latest_local.sql"
	@echo "  make rebuild-schema-local                Drop & rebuild local schema (destructive)"
	@echo "  make seed-local                          Run seed files against local DB"
	@echo "  make sync-env-to-local ENV=stg           Copy remote schema to local (destructive)"
	@echo "  make functions-serve-local               Serve edge functions locally"
	@echo "  make functions-stop-local                Stop local edge runtime"
	@echo "  make functions-logs-local                Tail local edge runtime logs"
	@echo ""
	@echo "  REMOTE (requires ENV=stg|prd)"
	@echo "  ──────────────────────────────────────"
	@echo "  make apply-migrations ENV=stg            Apply all migrations to remote DB"
	@echo "  make dump-schema ENV=stg                 Dump remote schema to latest_<ENV>.sql"
	@echo "  make rebuild-schema ENV=stg              Drop & rebuild remote schema (destructive)"
	@echo "  make seed-remote ENV=stg                 Run seed files against remote DB"
	@echo "  make functions-deploy ENV=stg             Deploy all edge functions"
	@echo "  make functions-secrets-set ENV=stg        Push secrets to remote project"
	@echo "  make auth-config-show ENV=stg             Show auth URL config (site_url, redirects)"
	@echo "  make auth-config-set ENV=stg [LOCAL_PORT=…]"
	@echo "                                           Set auth URL config (site_url, redirects)"
	@echo ""
	@echo "  OTHER"
	@echo "  ──────────────────────────────────────"
	@echo "  make show-config                         Show env vars and local URLs"
