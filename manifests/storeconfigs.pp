# Class: puppet::storeconfiguration
#
# This class installs and configures Puppet's stored configuration capability
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::storeconfigs (
    $dbadapter,
    $dbuser,
    $dbpassword,
    $dbserver,
    $dbsocket,
    $puppet_conf,
    $puppet_service
) inherits puppet::params {

  case $dbadapter {
    'sqlite3': {
      include puppet::storeconfigs::sqlite
    }
    'mysql': {
      include puppet::storeconfigs::mysql
    }
    'puppetdb': {
      class {'puppet::storeconfigs::puppetdb':
        puppetmaster_service => $puppet_service,
        puppetdb_host        => $dbserver,
        puppet_confdir       => $::puppet::params::confdir,
      }
    }
    default: { err("target dbadapter $dbadapter not implemented") }
  }

  concat::fragment { 'puppet.conf-master-storeconfig':
    order   => '03',
    target  => $puppet_conf,
    content => template('puppet/puppet.conf-master-storeconfigs.erb'),
    notify  => $puppet_service,
  }
}