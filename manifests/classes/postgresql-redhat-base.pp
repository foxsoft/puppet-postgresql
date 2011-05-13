class postgresql::redhat::base inherits postgresql::base {
  yumrepo { "PGDG":
     baseurl => "http://yum.pgrpms.org/reporpms/9.0/pgdg-centos-9.0-2.noarch.rpm",
     descr => "PostgreSQL PGDG RPMs for CentOS ",
     enabled => 1,
     gpgcheck => 0
  }
}