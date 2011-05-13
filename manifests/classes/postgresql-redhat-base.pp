class postgresql::redhat::base {
  exec { "install-pgdg":
      command => "rpm -i http://yum.pgrpms.org/reporpms/9.0/pgdg-centos-9.0-2.noarch.rpm",
      unless => "yum list installed | grep pgdg"
  }
}