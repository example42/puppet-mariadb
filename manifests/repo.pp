# Class mariadb::repo
#
# This class installs aditional repos for mariadb
#
class mariadb::repo (
  $base_url = '',
  ) {

  $repo_base_url = $base_url ? {
    ''   => $::osfamily ? {
      'RedHat' => 'http://yum.mariadb.org',
      'Debian' => 'http://mirror.1000mbps.com/mariadb/repo',
    }
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

  case $::osfamily {
    redhat: {
      yumrepo { 'mariadb':
        descr          => 'MariaDB',
        enabled        => 1,
        gpgcheck       => '1',
        baseurl        => "${repo_base_url}/${repo_version}/${repo_distro}${::lsbmajdistrelease}-${repo_arch}",
        gpgkey         => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
        before         => $mariadb::manage_config_file_require,
      }
    }
    debian: {
      apt::source { 'mariadb':
        location   => "${repo_base_url}/${repo_version}/${repo_distro}",
        repos      => 'main',
        key        => '0xcbcb082a1bb943db',
        key_server => 'keyserver.ubuntu.com',
        before     => $mariadb::manage_config_file_require,
      }
    }
  }
}
