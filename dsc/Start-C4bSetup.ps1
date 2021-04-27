Configuration InstallChoco {

    Import-DscResource -Module cChoco
    
    Node "localhost"
    
    {
        cChocoInstaller InstallChoco
        {
            InstallDir            = "C:\ProgramData\chocolatey"
            ChocoInstallScriptUrl = "https://chocoserver:8443/repository/choco-install/ChocolateyInstall.ps1"
        }
        cChocoSource ChocolateyInternal
        {
            Name                 = 'ChocolateyInternal'
            Source               = 'https://chocoserver:8443/repository/ChocolateyInternal/'
            Priority             = 1
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoSource CommunityRepo
        {
            Name                 = 'Chocolatey'
            Ensure               = 'Absent'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller installLicensePackage
        {
            Name                 = 'chocolatey-license'
            Ensure               = 'Present'
            AutoUpgrade          = $True
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstaller installLicensedExtension
        {
            Name                 = 'chocolatey.extension'
            Ensure               = 'Present'
            Params               = '/NoContextMenu'
            AutoUpgrade          = $True
            DependsOn            = '[cChocoInstaller]installChoco'
        }
        cChocoPackageInstallerSet installBasePackages
        {
            Ensure              = 'Present'
            Name                = @(
                "chocolateygui"
                "chocolatey-agent"
                )
            DependsOn           = "[cChocoInstaller]installChoco"
        }
        cChocoFeature showNonElevatedWarnings
        {
            FeatureName         = 'showNonElevatedWarnings'
            Ensure              = 'Absent'
        }
        cChocoFeature useBackgroundService
        {
            FeatureName         = 'useBackgroundService'
            Ensure              = 'Present'
        }
        cChocoFeature useBackgroundServiceWithNonAdministratorsOnly
        {
            FeatureName         = 'useBackgroundServiceWithNonAdministratorsOnly'
            Ensure              = 'Present'
        }
        cChocoFeature allowBackgroundServiceUninstallsFromUserInstallsOnly
        {
            FeatureName         = 'allowBackgroundServiceUninstallsFromUserInstallsOnly'
            Ensure              = 'Present'
        }
        cChocoConfig CentralManagementServiceUrl
        {
            ConfigName         = 'CentralManagementServiceUrl'
            Ensure             = 'Present'
            Value              = 'https://chocoserver:24020/ChocolateyManagementService' 
        }
        cChocoFeature useChocolateyCentralManagement
        {
            FeatureName         = 'useChocolateyCentralManagement'
            Ensure              = 'Present'
        }
        cChocoFeature useChocolateyCentralManagementDeployments
        {
            FeatureName         = 'useChocolateyCentralManagementDeployments'
            Ensure              = 'Present'
        }
    }
}

$config = InstallChoco

Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force
