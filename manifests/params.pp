# Class: mariadb::params
#
# Defines all the variables used in the module.
#
class mariadb::params {

  $service_name = $::osfamily ? {
    default => 'mysql',
  }

  $config_file_path = $::osfamily ? {
    default => '/etc/mysql/my.cnf',
  }

  $config_file_mode = $::osfamily ? {
    default => '0644',
  }

  $config_file_owner = $::osfamily ? {
    default => 'root',
  }

  $config_file_group = $::osfamily ? {
    default => 'root',
  }

  $config_dir_path = $::osfamily ? {
    default => '/etc/mysql',
  }

  case $::osfamily {
    'Debian','RedHat','Amazon': { }
    default: {
      fail("${::operatingsystem} not supported. Review params.pp for extending support.")
    }
  }
}
