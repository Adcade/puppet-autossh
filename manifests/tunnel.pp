define autossh::tunnel (
  $remote_host,
  $remote_port,
  $service             = $title,
  $ensure              = 'running',
  $user                = "root",
  $group               = "root",
  $ssh_id_file         = "~/.ssh/id_rsa",
  $bind_addr           = undef,
  $host                = "localhost",
  $host_port           = 22,
  $remote_user         = undef,
  $monitor_port        = 0,
  $remote_forwarding   = true,
  $autossh_background  = false,
  $autossh_gatetime    = undef,
  $autossh_logfile     = undef,
  $autossh_first_poll  = undef,
  $autossh_poll        = undef,
  $autossh_maxlifetime = undef,
  $autossh_maxstart    = undef,
) {

  if ! $remote_user {
    $real_remote_user = $user
  } else {
    $real_remote_user = $remote_user
  }

  $ssh_config = "/opt/autossh/${service}"

  if $remote_forwarding {
    file { $ssh_config:
      ensure  => present,
      path    => $ssh_config,
      owner   => $user,
      group   => $group,
      content => template( 'autossh/remoteforward.config.erb' ),
      require => File[ '/opt/autossh/' ],
    }
  } else {
    file { $ssh_config:
      ensure  => present,
      path    => $ssh_config,
      owner   => $user,
      group   => $group,
      content => template('autossh/localforward.config.erb'),
      require => File[ '/opt/autossh/' ],
    }
  }

  # Determine whether we need sysvinit or systemd
  case $::os['family'] {
    'Debian': {
      if versioncmp( $::os['release']['major'], '16.04' ) >= 0 {
        $is_systemd = true
      }
      else {
        $is_systemd = false
      }
    }
    'RedHat' : {
      if versioncmp( $::os['release']['major'], '7' ) >= 0 {
        $is_systemd = true
      }
      else {
        $is_systemd = false
      }
    }
    default: {
      fail( 'This operating system is not supported' )
    }
  }

  if $is_systemd {
    $init_file_path     = "/etc/systemd/system/${service}.service"
    $init_file_template = 'autossh/tunnel.systemd.conf.erb'

    file { "/etc/autossh/${service}.conf":
      ensure  => present,
      owner   => $user,
      group   => $group,
      content => template( 'autossh/tunnel.config.erb' ),
    }
  }
  else {
    $init_file_path     = "/etc/init/${service}.conf"
    $init_file_template = 'autossh/tunnel.sysvinit.conf.erb'
  }

  file { $init_file_path:
    ensure  => present,
    path    => $init_file_path,
    owner   => $user,
    group   => $group,
    content => template( $init_file_template ),
  }

  service { $service:
    ensure  => $ensure,
    enable  => true,
    require => File[ $ssh_config, $init_file_path ],
  }

}
