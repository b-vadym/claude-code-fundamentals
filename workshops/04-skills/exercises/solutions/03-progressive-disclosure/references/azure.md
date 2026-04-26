# Azure deploy reference

## Prerequisites

- `az` CLI installed
- Active subscription
- `jq` for parsing `.azure/config.json`

## Steps

1. Verify login:
   ```bash
   az account show
   ```
   If fails — `az login`.

2. Set subscription:
   ```bash
   sub=$(jq -r '.subscription' .azure/config.json)
   az account set --subscription "$sub"
   ```

3. Create resource group if missing:
   ```bash
   service=$(jq -r '.service' .azure/config.json)
   location=$(jq -r '.location // "westeurope"' .azure/config.json)
   az group create --name "rg-$service" --location "$location"
   ```

4. Validate Bicep template before deploy:
   ```bash
   az deployment group validate \
     --resource-group "rg-$service" \
     --template-file bicep/main.bicep
   ```

5. Deploy:
   ```bash
   az deployment group create \
     --resource-group "rg-$service" \
     --template-file bicep/main.bicep
   ```

6. Capture outputs:
   ```bash
   az deployment group show \
     --resource-group "rg-$service" \
     --name main \
     --query properties.outputs
   ```

7. Health check: curl exposed endpoint from outputs, expect 200.

## Rollback

If health check fails or user requests rollback:

```bash
az group delete --name "rg-$service" --yes
```

⚠️ Confirm with user — destroys ALL resources in the group.
