Exec {
  path => '/usr/bin:/bin:/usr/sbin:/sbin'
}
exec {'apt-get update': } -> Package<||>

