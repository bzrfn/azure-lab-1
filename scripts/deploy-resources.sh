#!/usr/bin/env bash
set -euo pipefail

# Este script reproduce el despliegue realizado. Requiere una sesión activa de Azure CLI.
resource_group="rg-utvt-integradora-dev-mxc-001"
workspace="log-utvt-integradora-dev-mxc-001"
insights="appi-utvt-integradora-dev-mxc-001"
plan="asp-utvt-integradora-dev-mxc-001"
webapp="app-utvt-integradora-web-dev-mxc-001"
resource_group_location="mexicocentral"
service_location="chilecentral"

subscription_id="$(az account show --query id --output tsv)"

az group create \
  --name "$resource_group" \
  --location "$resource_group_location" \
  --tags cost_center=utvt owner=equipo-integradora managed_by=portal \
  --output none

az monitor log-analytics workspace create \
  --resource-group "$resource_group" \
  --workspace-name "$workspace" \
  --location "$service_location" \
  --sku PerGB2018 \
  --tags cost_center=utvt environment=dev managed_by=portal owner=equipo-integradora \
  --output none

workspace_id="$(az monitor log-analytics workspace show \
  --resource-group "$resource_group" \
  --workspace-name "$workspace" \
  --query id --output tsv)"

insights_url="https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.Insights/components/${insights}?api-version=2020-02-02"
az rest --method put --url "$insights_url" \
  --body "{\"location\":\"${service_location}\",\"kind\":\"web\",\"tags\":{\"cost_center\":\"utvt\",\"environment\":\"dev\",\"managed_by\":\"portal\",\"owner\":\"equipo-integradora\"},\"properties\":{\"Application_Type\":\"web\",\"WorkspaceResourceId\":\"${workspace_id}\"}}" \
  --output none

az appservice plan create \
  --resource-group "$resource_group" \
  --name "$plan" \
  --location "$service_location" \
  --sku F1 \
  --is-linux false \
  --tags cost_center=utvt environment=dev managed_by=portal owner=equipo-integradora \
  --output none

az webapp create \
  --resource-group "$resource_group" \
  --plan "$plan" \
  --name "$webapp" \
  --runtime "NODE:24LTS" \
  --tags cost_center=utvt environment=dev managed_by=portal owner=equipo-integradora \
  --output none

az webapp update --resource-group "$resource_group" --name "$webapp" \
  --https-only true --output none
az webapp config set --resource-group "$resource_group" --name "$webapp" \
  --min-tls-version 1.2 --ftps-state Disabled --output none

for policy in scm ftp; do
  policy_url="https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.Web/sites/${webapp}/basicPublishingCredentialsPolicies/${policy}?api-version=2022-03-01"
  az rest --method put --url "$policy_url" \
    --body '{"properties":{"allow":false}}' --output none
done

connection_string="$(az rest --method get --url "$insights_url" \
  --query properties.ConnectionString --output tsv)"
az webapp config appsettings set \
  --resource-group "$resource_group" \
  --name "$webapp" \
  --settings \
    APPLICATIONINSIGHTS_CONNECTION_STRING="$connection_string" \
    ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
    XDT_MicrosoftApplicationInsights_Mode=recommended \
  --output none

echo "Despliegue completado. Ejecute scripts/validate-resources.sh para comprobarlo."
