# Azure-Policy-custom
Custom Azure Policies

Create Policy Defintion over API

**PUT** https://management.azure.com/subscriptions/{{subscriptionId}}/providers/Microsoft.authorization/policydefinitions/{policyDefinitionName}?api-version=2019-09-01



Add Request Body - type JSON

**change PolicyDefinitionName in URL**


{
    "properties": {
        "displayName": "MK101-Audit-StorageAccount-AzureServices",
        "description": "this policy check if storage account allow access from Azure Services",
        "mode": "all",
        "parameters": {
                    "effectType": {
                    "type": "string",
                    "defaultValue": "Deny",
                    "allowedValues": [
                        "Deny",
                        "Disabled"
                    ],
                    "metadata": {
                        "displayName": "Effect",
                        "description": "Enable or disable the execution of the policy"
                    }
                }
            },
    
    "policyRule": {
        "if": {
            "allOf": [{
                    "field": "type",
                    "equals": "Microsoft.Compute/storageAccounts"
                },
                {
                    "field": "Microsoft.Storage/storageAccounts/networkAcls.bypass",
                    "notequals": "AzureServices*"
                }
            ]
        },
        "then": {
            "effect": "[parameters('effectType')]"
        }
    }
}
} 

