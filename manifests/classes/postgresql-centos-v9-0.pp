class postgresql::centos::v9-0 inherits postgresql::centos::base {
  yumrepo { "pgdg90":
    baseurl => "http://yum.postgresql.org/9.0/redhat/rhel-\$releasever-\$basearch",
    descr => "PostgreSQL 9.0 \$releasever - \$basearch",
    enabled => 1,
    gpgcheck => 0,
  }

  yumrepo { "pgdg90-source":
    baseurl => "http://yum.postgresql.org/srpms/9.0/redhat/rhel-\$releasever-\$basearch",
    descr => "PostgreSQL 9.0 \$releasever - \$basearch - source",
    enabled => 0,
    gpgcheck => 0,
    failovermethod => "priority",
  }

  package { "postgresql90-server": ensure => installed, require => [Yumrepo["pgdg90"], Yumrepo["pgdg90-source"]] }
  package { "postgresql90-devel": ensure => installed, require => [Yumrepo["pgdg90"], Yumrepo["pgdg90-source"]] }

  exec { "create-user":
    command => "/bin/su postgres -c '/usr/pgsql-9.0/bin/createuser --superuser deploy' || true",
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
  
  file {"/usr/bin/psql":
    ensure => "/usr/pgsql-9.0/bin/psql"
  }

  file {"/usr/bin/pg_dump":
    ensure => "/usr/pgsql-9.0/bin/pg_dump"
  }

  file {"/usr/bin/pg_ctl":
    ensure => "/usr/pgsql-9.0/bin/pg_ctl"
  }

  file {"/usr/bin/createuser":
    ensure => "/usr/pgsql-9.0/bin/createuser"
  }

  file {"/usr/bin/createdb":
    ensure => "/usr/pgsql-9.0/bin/createdb"
  }
  
  user { "postgres":
    ensure => present,
    require => Package["postgresql90-server"],
  }
  
  file {"/var/lib/pgsql/9.0/data/pg_hba.conf":
    mode   => 0600,
    owner  => "postgres",
    group  => "postgres",
    source => "puppet:///postgresql/pg_hba.conf",
    notify => service["postgresql-9.0"],
    require => Exec["init-db"]
  }
  
}
