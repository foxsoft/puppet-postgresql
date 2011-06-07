class postgresql::redhat::v9-0 inherits postgresql::redhat::base {
  exec { "install-pgdg":
      command => "/bin/rpm -i http://yum.pgrpms.org/reporpms/9.0/pgdg-centos-9.0-2.noarch.rpm",
      unless => "/usr/bin/yum list installed | /bin/grep pgdg"
  }
  package { "postgresql90-server": ensure => installed, require => Exec["install-pgdg"] }
  package { "postgresql90-devel": ensure => installed, require => Exec["install-pgdg"] }

  exec { "create-user":
    command => "/bin/su postgres -c '/usr/pgsql-9.0/bin/createuser --superuser deploy' || true",
    unless => <<-EOF
/bin/su postgres -c "/usr/pgsql-9.0/bin/psql template1 -c \"select * from pg_user where usename = 'deploy';\"" | /bin/grep deploy
EOF
  }
  
  exec { "init-db":
    command => "/sbin/service postgresql-9.0 initdb",
    require => Package["postgresql90-server"],
    unless => "/bin/su postgres -c '/usr/pgsql-9.0/bin/pg_ctl status -D /var/lib/pgsql/9.0/data'",
  }
  
  Service["postgresql-9.0"] {
    start   => "/sbin/service postgresql-9.0 start",
    status  => "/sbin/service postgresql-9.0 status",
    stop    => "/sbin/service postgresql-9.0 stop",
    restart => "/sbin/service postgresql-9.0 restart",
  }
  
  service { "postgresql-9.0":
    ensure => running,
    require => [Exec["create-user"], Exec["init-db"]],
  }
  
  file {"/usr/bin/pg_config":
    ensure => "/usr/pgsql-9.0/bin/pg_config"
  }
  
}
