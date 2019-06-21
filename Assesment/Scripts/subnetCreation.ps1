function DeploynetworkfromCSV {

Param (
[String]$SubnetTemplateFile,
[String]$SubnetCSV,
[String]$ResGrp
)
$NetworkCsvTemplate = Import-Csv $SubnetCSV
#TemplateParameterObject as hash table
$NetworkHash = @{}
#First CSV row for VNet
$NetworkHash.Add("vnetName",$NetworkCsvTemplate[0].subnetname)
$NetworkHash.add("vnetAddressPrefix",$NetworkCsvTemplate[0].subnetprefix)
$NetworkCsvTemplate = $NetworkCsvTemplate | select -Skip 1 
#Add subsequent vnets
$i = 1
foreach ($network in $NetworkCsvTemplate)
{
    $NetworkHash.Add("subnet$($i)Name",$network.subnetname)
    $NetworkHash.Add("subnet$($i)Prefix",$network.subnetprefix)    
    $i++
}

$NetworksCreated = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResGrp -TemplateFile $SubnetTemplateFile  `
                                    -TemplateParameterObject $NetworkHash -Verbose
return $NetworksCreated
}



$ParamsSplat = @{
SubnetTemplateFile ='E:\Assesment\Templates\MultipleVnets\azuredeploy.json'
ResGrp='SENTIAWE101'
SubnetCSV='E:\Assesment\CSV_Templates\subnet.template.csv'
}


$NetworksCreated = DeploynetworkfromCSV @ParamsSplat