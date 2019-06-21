###Initialization of functions
$ScripRoot = 'C:\Assesment'

$SettingsFile= Join-Path $ScripRoot 'Scripts\Function.ps1' -Resolve
If( -not( Test-Path $SettingsFile)) {
    Write-Error 'Could not find settings file'; Exit 1
}
Else {
    Write-Host "loading the functions"
    . $SettingsFile
}

###Variables
$CompanyName = "LeLuPractice"
$AZLocation = "West Europe"
$LogPath = (Join-Path $ScripRoot 'logs\deploylog.log') #"D:\Assesment\Logs\deploylog.log"

#Connect to Azure
if (!$cred) {
    Write-Host "please type in your credentials"
    $cred = Get-Credential
}
Connect-AzureRmAccount 

#Make Resource group
$AzResGrpParam = @{
    CompanyName = $CompanyName
    AZLocation = $AZLocation
    Sufix = 101
}
 
$DeployResGrp = CreateAzureResGrp @AzResGrpParam 

#Deploy Storage Data Lake V2
    $Name = ($DeployResGrp.ResourceGroupName + '-' + ((Get-Date)).ToString('MMdd-HHmm')).tolower()
    $ResourceGroupName  = $DeployResGrp.ResourceGroupName
    $TemplateFile  = (Join-Path $ScripRoot 'Templates\DataLakeGen2\azuredeploy.json' )  #"E:\Assesment\Templates\DataLakeGen2\azuredeploy.json"
    $TemplateParametersObject = @{
        resourcePrefix = "lab123"
        storageSku = "Standard_LRS"
    }
$NewAZRmStorage = New-AzureRmResourceGroupDeployment -Name $Name -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterObject $TemplateParametersObject

#Deploy Network Vnet and Subnets
$ParamsSplat = @{
SubnetTemplateFile = (Join-Path $ScripRoot '\Templates\MultipleVnets\azuredeploy.json')
ResGrp= $DeployResGrp.ResourceGroupName
SubnetCSV= (Join-Path $ScripRoot '\CSV_Templates\subnet.template.csv')
}


$NetworksCreated = DeploynetworkfromCSV @ParamsSplat



#Deploy Webapp

#Deploy UDR

#Deploy LBL