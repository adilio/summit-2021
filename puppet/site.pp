# Requires puppetlabs/chocolatey module
# See https://forge.puppet.com/puppetlabs/chocolatey

#include chocolatey

case $operatingsystem {
  'windows': {
    Package { provider => chocolatey, }
  }
}

## - Ensure Chocolatey Install -
## Download chocolatey.nupkg to your internal repository (see above
##  about getting the package for offline use)
## Note: `chocolatey_download_url is completely different than normal
##  source locations. This is directly to the bare download url for the
##  chocolatey.nupkg, similar to what you see when you browse to
##  https://chocolatey.org/api/v2/package/chocolatey
class {'chocolatey':
  chocolatey_download_url         => 'https://chocoserver:8443/repository/ChocolateyInternal/chocolatey/0.10.15',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
  choco_install_location          => 'C:\ProgramData\chocolatey'
}

## Keep chocolatey up to date based on your internal source
## You control the upgrades based on when you push an updated version
##  to your internal repository.
package {'chocolatey':
  ensure   => latest,
  source   => 'https://chocoserver:8443/repository/ChocolateyInternal/',
}

## - Configure Chocolatey -
chocolateyconfig {'cacheLocation':
  value => 'c:\ProgramData\chocolatey\choco-cache',
}

## Increase timeout to 4 hours
chocolateyconfig {'commandExecutionTimeoutSeconds':
  value => '14400',
}

### Sources
## Remove the default community package repository source
chocolateysource {'chocolatey':
  ensure   => absent,
  location => 'https://chocolatey.org/api/v2/',
}

## Add default sources for your internal repositories
chocolateysource {'chocolatey_internal':
  ensure             => present,
  location           => 'https://chocoserver:8443/repository/ChocolateyInternal/',
  priority           => 1,
  bypass_proxy       => true,
  admin_only         => false,
  allow_self_service => true,
}

### Features
chocolateyfeature {'checksumFiles':
  ensure => enabled,
}
chocolateyfeature {'showDownloadProgress':
  ensure => disabled,
}
chocolateyfeature {'useRememberedArgumentsForUpgrades':
  ensure => enabled,
}

## - LICENSED OPTIONS -
### See https://docs.chocolatey.org/en-us/licensed-extension/setup

file { ['C:/ProgramData/chocolatey','C:/ProgramData/chocolatey/license']:
  ensure => directory,
}

### Ensure the license file is installed
file {'C:/ProgramData/chocolatey/license/chocolatey.license.xml':
  ensure              => file,
  source              => 'C:\Users\Adilio\Documents\choco-temp\chocolatey.license.xml',
  source_permissions  => ignore,
}

## Ensure the chocolatey.extension package
package {'chocolatey.extension':
  ensure          => latest,
  source          => 'chocolatey_internal',
  require         => File['C:/ProgramData/chocolatey/license/chocolatey.license.xml'],
}

## Install additional Chocolatey packages
package {['chocolateygui',
          'chocolatey-agent',
          ]:
  ensure    => latest,
  source    => 'chocolatey_internal',
}

## Configure additonal licensed features
chocolateyfeature {'showNonElevatedWarnings':
  ensure  => disabled,
  require => Package['chocolatey.extension'],
}
chocolateyfeature {'useBackgroundService':
  ensure  => enabled,
  require => Package['chocolatey.extension'],
}
chocolateyfeature {'useBackgroundServiceWithNonAdministratorsOnly':
  ensure  => enabled,
  require => Package['chocolatey.extension'],
}

## Configure endpoint to check into CCM Server
chocolateyconfig {'CentralManagementServiceUrl':
  value  => "https://chocoserver:24020/ChocolateyManagementService",
}
chocolateyfeature {'useChocolateyCentralManagement':
  ensure  => enabled,
  require => Package['chocolatey.extension'],
}
chocolateyfeature {'useChocolateyCentralManagementDeployments':
  ensure  => enabled,
  require => Package['chocolatey.extension'],
}

## Install some additional packages
package {['7zip',
          'notepadplusplus',
          ]:
  ensure    => latest,
  source    => 'chocolatey_internal',
}
