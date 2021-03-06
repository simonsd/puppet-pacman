# Definition: pacman::aur
#
# This lets you install packages from AUR. This installs yaourt on the system to
# manage packages. This class should be managed via main pacman class and should
# not be included separately.
#
# If you decide to use this class separately, make sure you set
# $manage_aur parameter in pacman class to false and manually include
# pacman::yaourt class which will setup AUR (or skip pacman class)
#
# Parameters:
#
#   [*ensure*]          - specify if package should be present or absent
#     (present|absent)    [default: 'present']
#
# Usage:
#
# Should not be included manually as the inclusion is controlled by $manage_aur
# parameter in pacman class. If you, however, decide to use this separately, you
# can follow examples below.
#
# Install package from AUR:
#
#       class { 'pacman':
#         manage_aur => true,
#       }
#
#       pacman::aur { 'gitlab': }
#
# Remove previously installed package from system:
#
#   pacman::aur { 'ruby20':
#     ensure => 'absent',
#   }
#
define pacman::aur(
  $ensure = 'present',
) {
  include pacman
  include pacman::yaourt

  case $ensure {
    'present': {
      exec { "pacman::aur::install::${name}":
        require     => Class[pacman::yaourt],
        command     => "/usr/bin/yaourt -S --noconfirm ${name}",
        unless      => "/usr/bin/yaourt -Qk ${name}",
        user        => $pacman::yaourt_exec_user,
        cwd         => $pacman::yaourt_exec_cwd,
        environment => "HOME=${pacman::yaourt_exec_home}",
        logoutput   => 'on_failure',
        timeout     => 1800,
      }
    }
    'absent': {
      exec { "pacman::aur::remove::${name}":
        require   => Class[pacman::yaourt],
        command   => "/usr/bin/yaourt -Rs ${name}",
        onlyif    => "/usr/bin/yaourt -Qi ${name}",
        logoutput => 'on_failure',
      }
    }
    default: {
      fail("Pacman::Aur[${name}] ensure parameter must be either 'present' or 'absent'")
    }

  }
}
