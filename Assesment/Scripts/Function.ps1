###Function File
Function DeployLog {
    param (
        [String]$logPath,
        [String]$logMessage
    )
    $timestamp= Get-Date -Format ("yyyy-MM-dd HH:mm:ss")
    ('[{0}] {1}' -f $timestamp, $logMessage) | out-file -Filepath $logPath -append    
 }

 
function CreateAzureResGrp {
    param (
        [String]$CompanyName,
        [String]$AZLocation,
        [int16]$Sufix
    )
    $CheckAZLoc = Get-AzureRmLocation | Where-Object {$_.DisplayName -like $AZLocation}
    if ($CheckAZLoc.DisplayName -eq $AZLocation) {
        Foreach ($words in $CheckAZLoc.DisplayName -split ' ') {
            $Azloc = $Azloc + $words[0]
        }
        $NewResGrpName = $CompanyName + $Azloc + $Sufix        
        $NewResGrp = New-AzureRmResourceGroup -Name $NewResGrpName.ToUpper() -Location $CheckAZLoc.Location.ToString() 
        DeployLog -logPath $LogPath -logMessage "$NewResGrp.ResourceGroupName provision was $NewResGrp.ProvisioningState at $NewResGrp.DisplayName"
        return $NewResGrp
    }
    else {
        DeployLog -logMessage "The region is not found" -logPath $LogPath
        exit    
    }
}

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

$NetworksCreated = New-AzureRmResourceGroupDeployment `
                    -ResourceGroupName $ResGrp `
                    -TemplateFile $SubnetTemplateFile  `
                    -TemplateParameterObject $NetworkHash `
                    -Verbose
return $NetworksCreated
}

function ConvertCSVToHash {
    param (
        [array]$ParameterObject
    )
    $TemplateParameterObject = @{}
    foreach ($Parameter in ($ParameterObject | Get-Member | Where-Object {$_.Membertype -eq 'NoteProperty'})) {
           $TemplateParameterObject.Add($Parameter.Name, $ParameterObject.($Parameter.Name))
           
    }
    return $TemplateParameterObject
}
