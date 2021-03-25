
$resourceGroupName    = "rg-image"
$galleryName          = "imgosp"
$imageDefinitionName  = "imgdef-01"
$replicationRegion    = @("West Europe")
$location             = "West Europe"
$imageBuilderIdentity = "umid-osp-imagebuilder"
$subscriptionName     = "Subscription01"
$subscriptionID       = ""
$artifactTag          = @{tag='Custom-Image01'}


# get User-assigned managed identity for ImageBuilder
import-module -name az.managedserviceidentity
$umidImageBuilder = Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName  -Name $imageBuilderIdentity


$imageDefinition = Get-AzGalleryImageDefinition `
    -ResourceGroupName $resourceGroupName `
    -GalleryName $galleryName `
    -Name $imageDefinitionName


$images = Get-AzGalleryImageVersion -ResourceGroupName $resourceGroupName `
            -GalleryName $galleryName `
            -GalleryImageDefinitionName $imageDefinitionName

# add custom member to get the list sortable with integer values
foreach($image in $images)
{
   [int[]] $versions = $image.Name.Split(".")
   $image | Add-Member -NotePropertyName "Major" -NotePropertyValue ([int] $versions[0] )
   $image | Add-Member -NotePropertyName "Minor" -NotePropertyValue ([int] $versions[1] )
   $image | Add-Member -NotePropertyName "Release" -NotePropertyValue ([int] $versions[2] )
}

# Sort to get the latestversion 
$images = $images | Sort-Object -Descending -Property Major, Minor, Release

$latestImage = $images[0]

# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/image-builder-powershell#create-an-image
#define source object
$srcPlatform = New-AzImageBuilderSourceObject -SourceTypeSharedImageVersion -ImageVersionId $latestImage.id

$imageVersion = $latestImage.id.Substring(0, $latestImage.Id.LastIndexOf("/"))
$newImageVersion = ("{0}.{1}.{2}" -f $latestImage.Major, $latestImage.Minor, ($latestImage.Release + 1))
$newImageVersionId = ("{0}/{1}" -f $imageVersion, $newImageVersion)
$runOutPutNameJob = ("SIT-RDP-ImageBuilder-{0}" -f $newImageVersion) 

# distributer Object
$disSharedImg = New-AzImageBuilderDistributorObject -SharedImageDistributor `
                    -GalleryImageId $newImageVersionId `
                    -StorageAccountType Standard_ZRS `
                    -ReplicationRegion $replicationRegion -ExcludeFromLatest $false `
                    -RunOutputName $runOutPutNameJob `
                    -ArtifactTag $artifactTag

# building the windows update customizer
$windowsUpdateCustomizer = New-AzImageBuilderCustomizerObject -WindowsUpdateCustomizer -Filter ("BrowseOnly", "IsInstalled", "`$_.Title -like '*Preview*'") -SearchCriterion "BrowseOnly=0 and IsInstalled=0"  -UpdateLimit 1000 -CustomizerName 'WindUpdate'
$azureImageBuilderTemplateName = ("aib-{0}-{1}" -f $imageDefinitionName, $newImageVersion)
New-AzImageBuilderTemplate -ImageTemplateName $azureImageBuilderTemplateName `
                            -ResourceGroupName $resourceGroupName `
                            -SubscriptionId $subscriptionID `
                            -Source $srcPlatform `
                            -Distribute $disSharedImg `
                            -UserAssignedIdentityId $umidImageBuilder.Id `
                            -Location $location `
                            -Customize @($windowsUpdateCustomizer)


$lastRunOutput = Get-AzImageBuilderTemplate -ImageTemplateName $azureImageBuilderTemplateName `
                            -ResourceGroupName $resourceGroupName |
                                Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState

Start-AzImageBuilderTemplate -ResourceGroupName $resourceGroupName -Name $azureImageBuilderTemplateName


$lastRunOutput | Get-Member

#Get-AzImageBuilderTemplate
#Get-azimagebuildertemplate -ImageTemplateName "imgdef-ospt-sandbox-test02" -ResourceGroupName $resourceGroupName `
#    | Remove-AzImageBuilderTemplate
