$PsoBject = Get-Content "C:\Assesment\Templates\MultipleVnets\azuredeploy.json" | ConvertFrom-Json

$TemplateParameterObject = @{
webAppName = "WebappProdSideB"
sku = "s1"
}
New-AzureRmResourceGroupDeployment -ResourceGroupName "SENTIAEW101" -TemplateFile "C:\Assesment\Templates\WebApp\azuredeploy.json" -TemplateParameterObject $TemplateParameterObject -Verbose


