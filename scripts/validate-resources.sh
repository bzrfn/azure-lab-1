#!/usr/bin/env bash
set -euo pipefail

resource_group="rg-utvt-integradora-dev-mxc-001"
workspace="log-utvt-integradora-dev-mxc-001"
insights="appi-utvt-integradora-dev-mxc-001"
plan="asp-utvt-integradora-dev-mxc-001"
webapp="app-utvt-integradora-web-dev-mxc-001"

az account show \
  --query '{user:user.name,subscription:name,subscriptionId:id,state:state,isDefault:isDefault}' \
  --output table

az group show --name "$resource_group" \
  --query '{name:name,location:location,provisioningState:properties.provisioningState,tags:tags}'

az monitor log-analytics workspace show \
  --resource-group "$resource_group" \
  --workspace-name "$workspace" \
  --query '{name:name,location:location,sku:sku.name,provisioningState:provisioningState}'

az resource show \
  --resource-group "$resource_group" \
  --name "$insights" \
  --resource-type Microsoft.Insights/components \
  --query '{name:name,location:location,kind:kind,workspaceResourceId:properties.WorkspaceResourceId,provisioningState:properties.provisioningState}'

az appservice plan show \
  --resource-group "$resource_group" \
  --name "$plan" \
  --query '{name:name,location:location,kind:kind,sku:sku}'

az webapp show \
  --resource-group "$resource_group" \
  --name "$webapp" \
  --query '{name:name,state:state,location:location,defaultHostName:defaultHostName,httpsOnly:httpsOnly,serverFarmId:serverFarmId}'

az webapp config show \
  --resource-group "$resource_group" \
  --name "$webapp" \
  --query '{windowsFxVersion:windowsFxVersion,minTlsVersion:minTlsVersion,ftpsState:ftpsState,alwaysOn:alwaysOn}'

az webapp config appsettings list \
  --resource-group "$resource_group" \
  --name "$webapp" \
  --query "[?name=='WEBSITE_NODE_DEFAULT_VERSION'].[name,value]" \
  --output table

subscription_id="$(az account show --query id --output tsv)"
for policy in scm ftp; do
  allow="$(az rest --method get \
    --url "https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.Web/sites/${webapp}/basicPublishingCredentialsPolicies/${policy}?api-version=2022-03-01" \
    --query properties.allow --output tsv)"
  printf '%s allow=%s\n' "$policy" "$allow"
done

curl --silent --show-error --output /dev/null \
  --write-out 'HTTP %{http_code} - %{url_effective}\n' \
  "https://${webapp}.azurewebsites.net"

