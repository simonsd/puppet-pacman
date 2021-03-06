# Class: pacman::yaourt
#
# This sets up yaourt on your system so you can use `pacman::aur` to manage
# packages from AUR. This class should not be called directly but initialized
# via init.pp (pacman class) instead.
#
# This depends on http://meta.sh/aur webservice script to install `yaourt`
#
## If you decide to use this class separately, make sure you set
# $enable_aur parameter in pacman class to false (or skip pacman class)
#
# Dependencies:
#   curl package (pacman already depends on it)
#   http://meta.sh/aur webservice
#
# Usage:
#
#   Should not be included manually as the inclusion is controlled by
#   $enable_aur parameter in pacman class. If you, however, decide to
#   use this separately, you can follow examples below.
#
#   Install custom package from AUR:
#
#       # This is not required if you do not use pacman class.
#       class { 'pacman':
#         enable_aur => false,
#       }
#
#       include 'pacman::yaourt'
#
#       pacman::aur { 'cowsay-futurama': }
#
class pacman::yaourt inherits ::pacman {
  if $yaourt_install_method == 'package' {
    package{'yaourt':
      ensure => 'present',
    }
  } else {
    package { 'curl':
      ensure => 'present',
    }
    package { 'bc':
      ensure => 'present',
    }
  
    exec { 'pacman-base-devel':
      command   => '/usr/bin/pacman -S base-devel --needed --noconfirm',
      unless    => '/usr/bin/pacman -Qk yaourt',
      require   => [Package['curl'], Package['bc']],
      logoutput => 'on_failure',
    }
  
    # make sure yaourt install is always correct via pacman -Qk
    exec { 'pacman::yaourt':
      command   => '/bin/curl -o /tmp/aur.sh https://meta.sh/aur && /bin/chmod +x /tmp/aur.sh && /tmp/aur.sh -si package-query yaourt --noconfirm && /bin/rm /tmp/aur.sh',
      unless    => '/usr/bin/pacman -Qk yaourt',
      user      => $pacman::yaourt_exec_user,
      cwd       => $pacman::yaourt_exec_cwd,
      require   => Exec['pacman-base-devel'],
      logoutput => 'on_failure',
    }
  }
}
