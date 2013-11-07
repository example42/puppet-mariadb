#
# = Class: mariadb
#
# This class installs and manages mariadb
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class mariadb (

  $galera_install            = false,
  $version                   = '10.0',

  $package_name              = '',
  $package_ensure            = 'present',

  $service_name              = $mariadb::params::service_name,
  $service_ensure            = 'running',
  $service_enable            = true,

  $config_file_path          = $mariadb::params::config_file_path,
  $config_file_replace       = $mariadb::params::config_file_replace,
  $config_file_require       = 'Package[mariadb]',
  $config_file_notify        = 'Service[mariadb]',
  $config_file_source        = undef,
  $config_file_template      = undef,
  $config_file_content       = undef,
  $config_file_options_hash  = undef,

  $config_dir_path           = $mariadb::params::config_dir_path,
  $config_dir_source         = undef,
  $config_dir_purge          = false,
  $config_dir_recurse        = true,

  $repo_class                = 'mariadb::repo',

  $monitor_class             = undef,
  $monitor_options_hash      = { } ,

  $firewall_class            = undef,
  $firewall_options_hash     = { } ,

  $scope_hash_filter         = '(uptime.*|timestamp)',

  $tcp_port                  = undef,
  $udp_port                  = undef,

  ) inherits mariadb::params {


  # Class variables validation and management

  validate_bool($galera_install)
  validate_bool($service_enable)
  validate_bool($config_dir_recurse)
  validate_bool($config_dir_purge)
  if $config_file_options_hash { validate_hash($config_file_options_hash) }
  if $monitor_options_hash { validate_hash($monitor_options_hash) }
  if $firewall_options_hash { validate_hash($firewall_options_hash) }

  $config_file_owner          = $mariadb::params::config_file_owner
  $config_file_group          = $mariadb::params::config_file_group
  $config_file_mode           = $mariadb::params::config_file_mode

  $manage_config_file_content = default_content($config_file_content, $config_file_template)

  $manage_config_file_notify = pickx($config_file_notify)
  $manage_package_ensure = pickx($package_ensure)

  $galera_package_name = $galera_install ? {
    true  => "MariaDB-Galera-server"
    false => "MariaDB-server"
  }

  $manage_package_name = $::osfamily {
    'Debian' => downcase($galera_package_name),
    default  => $galera_package_name,
  }

  if $package_ensure == 'absent' {
    $manage_service_enable = undef
    $manage_service_ensure = stopped
    $config_dir_ensure = absent
    $config_file_ensure = absent
  } else {
    $manage_service_enable = $service_enable
    $manage_service_ensure = $service_ensure
    $config_dir_ensure = directory
    $config_file_ensure = present
  }


  # Resources managed

  if $mariadb::package_name {
    package { $mariadb::manage_package_name:
      ensure   => $mariadb::manage_package_ensure,
    }
  }

  if $mariadb::service_name {
    service { $mariadb::service_name:
      ensure     => $mariadb::manage_service_ensure,
      enable     => $mariadb::manage_service_enable,
    }
  }

  if $mariadb::config_file_path {
    file { 'mariadb.conf':
      ensure  => $mariadb::config_file_ensure,
      path    => $mariadb::config_file_path,
      mode    => $mariadb::config_file_mode,
      owner   => $mariadb::config_file_owner,
      group   => $mariadb::config_file_group,
      source  => $mariadb::config_file_source,
      content => $mariadb::manage_config_file_content,
      notify  => $mariadb::manage_config_file_notify,
      require => $mariadb::config_file_require,
    }
  }

  if $mariadb::config_dir_source {
    file { 'mariadb.dir':
      ensure  => $mariadb::config_dir_ensure,
      path    => $mariadb::config_dir_path,
      source  => $mariadb::config_dir_source,
      recurse => $mariadb::config_dir_recurse,
      purge   => $mariadb::config_dir_purge,
      force   => $mariadb::config_dir_purge,
      notify  => $mariadb::config_file_notify,
      require => $mariadb::config_file_require,
    }
  }


  # Extra classes

  if $mariadb::dependency_class {
    include $mariadb::dependency_class
  }

  if $mariadb::my_class {
    include $mariadb::my_class
  }

  if $mariadb::monitor_class {
    class { $mariadb::monitor_class:
      options_hash => $mariadb::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $mariadb::firewall_class {
    class { $mariadb::firewall_class:
      options_hash => $mariadb::firewall_options_hash,
      scope_hash   => {},
    }
  }

}

