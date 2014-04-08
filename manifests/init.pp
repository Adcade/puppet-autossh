class autossh {
  include stdlib

  file { '/opt/autossh':
    ensure  => directory,
    recurse => true,
  } ->

  package { 'autossh':
    ensure => present,
  }
}

