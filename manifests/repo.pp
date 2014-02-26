# Class mariadb::repo
#
# This class installs aditional repositories for MariaDB.
#
# Parameters:
#   [*base_url*]
#     Set the package's source URL. The URL must be without trailing
#     slash, version, and distribution. If an empty string (default)
#     is passed a suitable mirror is chosen, based on OS family.
#     Default: ''
#   [*apt_pin*]
#     Allows to set the source pin priority for the apt source on
#     Debian based systems.
#     Default: undef
#
# Sample Hiera Configuration (JSON backend, Puppet 3+):
# {
#   "mariadb::repo::base_url": "http://tweedo.com/mirror/mariadb/repo",
#   "mariadb::repo::apt_pin": "900"
# }
class mariadb::repo (
  $base_url = '',
  $apt_pin = undef,
  ) {

  $repo_base_url = $base_url ? {
    ''      => $::osfamily ? {
      'RedHat' => 'http://yum.mariadb.org',
      'Debian' => 'http://mirror.1000mbps.com/mariadb/repo',
    },
    default => $base_url,
  }

  $repo_distro = $::operatingsystem ? {
    'RedHat'    => 'rhel',
    'LinuxMint' => 'ubuntu',
    default     => downcase($operatingsystem),
  }

  $repo_version = $mariadb::version ? {
    /^5/   => '5.5',
    /^10/  => '10.0',
  }

  $repo_arch = $::architecture ? {
    /^.*86$/ => 'x86',
    /^.*64$/ => 'amd64',
    default  => $::architecture,
  }

  $osver = split($::operatingsystemrelease, '[.]')

  case $::osfamily {
    redhat: {
      yumrepo { 'mariadb':
        descr          => 'MariaDB',
        enabled        => '1',
        gpgcheck       => '1',
        baseurl        => "${repo_base_url}/${repo_version}/${repo_distro}${osver[0]}-${repo_arch}",
        gpgkey         => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
        before         => $mariadb::manage_config_file_require,
      }
    }
    debian: {
      apt::source { 'mariadb':
        location   => "${repo_base_url}/${repo_version}/${repo_distro}",
        repos      => 'main',
        key        => '1BB943DB',
        key_server => 'keyserver.ubuntu.com',
        before     => $mariadb::manage_config_file_require,
        pin        => $apt_pin,
      }
    }
  }
}
