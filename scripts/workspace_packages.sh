#!/bin/bash

# Shared workspace package lists used by helper scripts.
# Format: "<package_path>:<package_name>"

WORKSPACE_PACKAGES=(
    "packages/core/domain:core_domain"
    "packages/core/data:core_data"
    "packages/common/env:common_env"
    "packages/common/ui:common_ui"
    "packages/common/utils:common_utils"
    "packages/integrations/analytics:integration_analytics"
    "packages/integrations/auth_session:integration_auth_session"
    "packages/integrations/backend_api:integration_backend_api"
    "packages/integrations/barcode_scanner:integration_barcode_scanner"
    "packages/integrations/database:integration_database"
    "packages/integrations/firebase_services:integration_firebase_services"
    "packages/integrations/logger:integration_logging"
    "packages/integrations/metadata_api:integration_metadata_api"
    "packages/integrations/sync_api:integration_sync_api"
    "packages/integrations/storage:integration_storage"
    "packages/integrations/payment:integration_payment"
)

WORKSPACE_PACKAGES_WITH_APP=(
    "${WORKSPACE_PACKAGES[@]}"
    "apps/mobile:mobile_app"
)

WORKSPACE_PACKAGES_APP_FIRST=(
    "apps/mobile:mobile_app"
    "${WORKSPACE_PACKAGES[@]}"
)
