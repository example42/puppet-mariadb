# Class mariadb::galera
#
# This class installs galera
#
class mariadb::galera {

    package { 'galera':
      ensure   => $mariadb::manage_package_ensure,
    }

}
