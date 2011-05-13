class postgresql::redhat::v9-0 inherits postgresql::redhat::base {
  package { "postgresql90-server": ensure => installed }
}