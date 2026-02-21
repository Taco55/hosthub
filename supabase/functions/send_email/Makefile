# supabase/functions/send_email/Makefile
# Copy inline email assets into function package

SHELL := /bin/bash
APP ?= organize
BRAND_EMAIL := ../../../brand/$(APP)/email
DEST := assets

.PHONY: help assets clean

help:
	@echo "Targets for send_email function assets"
	@echo "  assets  - Copy brand e-mail PNG into place"
	@echo "  clean   - Remove generated asset from this directory"

assets:
	@mkdir -p "$(DEST)"
	cp -f "$(BRAND_EMAIL)/logo_120.png" "$(DEST)/organize_logo.png"
	@echo ">> Copied $(BRAND_EMAIL)/logo_120.png -> $(DEST)/organize_logo.png"

clean:
	@rm -f "$(DEST)/organize_logo.png"
