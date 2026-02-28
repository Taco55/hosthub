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

# Include shared Supabase targets
include $(SUPABASE_DIR)/make/supabase-common.mk

# ============================
# Help
# ============================
.PHONY: help
help: _common-help
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
	DB_URL="$$(python3 '$(DB_URL_NORMALIZER)' "$$DB_URL" "$${SUPABASE_DB_PASSWORD:-}")" || exit 1; \
	$(PSQL) "$$DB_URL" -v ON_ERROR_STOP=1 \
	  -c "SELECT create_local_admin_user('$(EMAIL)', '$(PASSWORD)', '$(or $(USERNAME),$(EMAIL))');" \
	&& echo "Admin user created on $(ENV)."
