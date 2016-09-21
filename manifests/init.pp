##
## Class : autossh
##

class autossh (

) {

  include ::stdlib

  file { [ '/opt/autossh', '/etc/autossh' ]:
    ensure  => directory,
    recurse => true,
    purge   => true,
  } ->

  package { 'autossh':
    ensure => present,
  }
}
