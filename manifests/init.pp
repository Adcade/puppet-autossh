class autossh {
  include stdlib

  file { "/opt/autossh":
    ensure  => directory,
    recurse => true,
    purge 	=> true,
  } ->

  package { 'autossh':
    ensure => present,
  }
}

