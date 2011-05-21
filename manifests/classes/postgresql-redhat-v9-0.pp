class postgresql::redhat::v9-0 inherits postgresql::redhat::base {
  exec { "install-pgdg":
      command => "/bin/rpm -i http://yum.pgrpms.org/reporpms/9.0/pgdg-centos-9.0-2.noarch.rpm",
      unless => "/usr/bin/yum list installed | /bin/grep pgdg"
  }
  package { "postgresql90-server": ensure => installed, require => Exec["install-pgdg"] }
  package { "postgresql90-devel": ensure => installed, require => Exec["install-pgdg"] }
  
  Service["postgresql-9.0"] {
    start   => "service postgresql-9.0 start",
    status  => "service postgresql-9.0 status",
    stop    => "service postgresql-9.0 stop",
    restart => "service postgresql-9.0 restart",
    require => Package["postgresql90-server"],
  }
  
  service { "postgresql-9.0":
    ensure => running,
  }
}
