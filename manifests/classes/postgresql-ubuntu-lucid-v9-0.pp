# See: http://www.dctrwatson.com/2010/09/installing-postgresql-9-0-on-ubuntu-10-04/
# TODO: handle upgrade case.

class postgresql::ubuntu::lucid::v9-0 inherits postgresql::ubuntu::base {
  $data_dir = $postgresql_data_dir ? {
    "" => "/var/lib/postgresql",
    default => $postgresql_data_dir,
  }

  package {
    ["python-software-properties",
     "libpq-dev",
     "libpq5",
     "postgresql-client-9.0",
     "postgresql-common",
     "postgresql-client-common",
     "postgresql-contrib-9.0"]:
      ensure => installed;
  }

  exec { "add_apt_repo":
    command => "add-apt-repository ppa:pitti/postgresql && apt-get update",
    creates => "/etc/apt/sources.list.d/pitti-postgresql-lucid.list",
    require => Package["python-software-properties"];
  }

  Package["postgresql"] {
    name => "postgresql-9.0",
    require => Exec["add_apt_repo"]
  }

  Service["postgresql"] {
    name => "postgresql",
    hasrestart => true
  }

  # re-create the cluster in UTF8
  exec { "pg_createcluster in utf8":
    command => "pg_dropcluster --stop 9.0 main && pg_createcluster -e UTF8 -d ${data_dir}/9.0/main --start 9.0 main",
    onlyif => "test \$(su -c \"psql -tA -c 'SELECT count(*)=3 AND min(encoding)=0 AND max(encoding)=0 FROM pg_catalog.pg_database;'\" postgres) = t",
    user => root,
    timeout => 60;
  }
}
