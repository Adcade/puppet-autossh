define autossh::tunnel (
  $service             = $title,
  $ensure              = 'running',
  $user                = 'root',
  $group               = 'root',
  $ssh_id_file         = '~/.ssh/id_rsa',
  $bind_addr           = undef,
  $host                = 'localhost',
  $host_port           = 22,
  $remote_user         = undef,
  $remote_host,
  $remote_port,
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

  if (!$remote_user) {
    $real_remote_user = $user
  } else {
    $real_remote_user = $remote_user
  }

  $ssh_config = "/opt/autossh/${service}.conf"

  if $remote_forwarding == true {
    $template_path = 'autossh/remoteforward.config.erb'
  } else {
    $template_path = 'autossh/localforward.config.erb'
  }

  file { $ssh_config:
    ensure  => file,
    path    => $ssh_config,
    owner   => $user,
    group   => $group,
    content => template($template_path),
    require => File['/opt/autossh/'],
  }

  file { "/etc/init/${service}.conf":
    ensure  => file,
    path    => "/etc/init/${service}.conf",
    owner   => $user,
    group   => $group,
    content => template('autossh/tunnel.conf.erb'),
  }

  service { $service:
    ensure  => $ensure,
    enable  => true,
    require => File[$ssh_config, "/etc/init/${service}.conf"],
  }

}
