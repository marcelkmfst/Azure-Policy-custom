https://management.azure.com/subscriptions/{{subscriptionId}}/providers/Microsoft.authorization/policydefinitions/{policyDefinitionName}?api-version=2019-09-01



Das ganze mit Request Body - type JSON

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


