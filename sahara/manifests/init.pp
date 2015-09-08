# == Class: sahara
#
#  Sahara base package & configuration
#
# === Parameters
#
# [*package_ensure*]
#   (Optional) Ensure state for package
#   Defaults to 'present'.
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true.
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to 'false'.
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to 'false'.
#
# [*use_syslog*]
#   Use syslog for logging.
#   (Optional) Defaults to false.
#
# [*log_facility*]
#   Syslog facility to receive log lines.
#   (Optional) Defaults to LOG_USER.
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/sahara'
#
# [*host*]
#   (Optional) Hostname for sahara to listen on
#   Defaults to '0.0.0.0'.
#
# [*port*]
#   (Optional) Port for sahara to listen on
#   Defaults to 8386.
#
# [*use_neutron*]
#   (Optional) Whether to use neutron
#   Defaults to 'false'.
#
# [*use_floating_ips*]
#   (Optional) Whether to use floating IPs to communicate with instances.
#   Defaults to 'true'.
#
# [*database_connection*]
#   (Optional) Non-sqllite database for sahara
#   Defaults to 'mysql://sahara:secrete@localhost:3306/sahara'
#
# == keystone authentication options
#
# [*admin_user*]
#   (Optional) Service user name
#   Defaults to 'admin'.
#
# [*admin_password*]
#   (Optional) Service user password.
#   Defaults to false.
#
# [*admin_tenant_name*]
#   (Optional) Service tenant name.
#   Defaults to 'admin'.
#
# [*auth_uri*]
#   (Optional) Complete public Identity API endpoint.
#   Defaults to 'http://127.0.0.1:5000/v2.0/'.
#
# [*identity_uri*]
#   (Optional) Complete admin Identity API endpoint.
#   This should specify the unversioned root endpoint.
#   Defaults to 'http://127.0.0.1:35357/'.
#
# == DEPRECATED PARAMETERS
#
# [*service_host*]
#   (Optional) DEPRECATED: Use host instead.
#   Hostname for sahara to listen on
#   Defaults to undef.
#
# [*service_port*]
#   (Optional) DEPRECATED: Use port instead.
#   Port for sahara to listen on
#   Defaults to undef.
#
# [*keystone_username*]
#   (Optional) DEPRECATED: Use admin_user instead.
#   Username for sahara credentials
#   Defaults to undef.
#
# [*keystone_password*]
#   (Optional) DEPRECATED: Use admin_password instead.
#   Password for sahara credentials
#   Defaults to undef.
#
# [*keystone_tenant*]
#   (Optional) DEPRECATED: Use admin_tenant_name instead.
#   Tenant for keystone_username
#   Defaults to undef.
#
# [*keystone_url*]
#   (Optional) DEPRECATED: Use auth_uri instead.
#   Public identity endpoint
#   Defaults to undef.
#
# [*identity_url*]
#   (Optional) DEPRECATED: Use identity_uri instead.
#   Admin identity endpoint
#   Defaults to undef.
#
class sahara(
  $manage_service      = true,
  $enabled             = true,
  $package_ensure      = 'present',
  $verbose             = false,
  $debug               = false,
  $use_syslog          = false,
  $log_facility        = 'LOG_USER',
  $log_dir             = '/var/log/sahara',
  $host                = '0.0.0.0',
  $port                = '8386',
  $use_neutron         = false,
  $use_floating_ips    = true,
  $database_connection = 'mysql://sahara:secrete@localhost:3306/sahara',
  $admin_user          = 'admin',
  $admin_password      = false,
  $admin_tenant_name   = 'admin',
  $auth_uri            = 'http://127.0.0.1:5000/v2.0/',
  $identity_uri        = 'http://127.0.0.1:35357/',
  # DEPRECATED PARAMETERS
  $service_host        = undef,
  $service_port        = undef,
  $keystone_username   = undef,
  $keystone_password   = undef,
  $keystone_tenant     = undef,
  $keystone_url        = undef,
  $identity_url        = undef,
) {
  include ::sahara::params
  include ::sahara::policy

  if $service_host {
    warning('The service_host parameter is deprecated. Use host parameter instead')
    $host_real = $service_host
  } else {
    $host_real = $host
  }

  if $service_port {
    warning('The service_port parameter is deprecated. Use port parameter instead')
    $port_real = $service_port
  } else {
    $port_real = $port
  }

  if $keystone_username {
    warning('The keystone_username parameter is deprecated. Use admin_user parameter instead')
    $admin_user_real = $keystone_username
  } else {
    $admin_user_real = $admin_user
  }

  if $keystone_password {
    warning('The keystone_password parameter is deprecated. Use admin_password parameter instead')
    $admin_password_real = $keystone_password
  } else {
    $admin_password_real = $admin_password
  }

  if $keystone_tenant {
    warning('The keystone_tenant parameter is deprecated. Use admin_tenant_name parameter instead')
    $admin_tenant_name_real = $keystone_tenant
  } else {
    $admin_tenant_name_real = $admin_tenant_name
  }

  if $keystone_url {
    warning('The keystone_url parameter is deprecated. Use auth_uri parameter instead')
    $auth_uri_real = $keystone_url
  } else {
    $auth_uri_real = $auth_uri
  }

  if $identity_url {
    warning('The identity_url parameter is deprecated. Use identity_uri parameter instead')
    $identity_uri_real = $identity_url
  } else {
    $identity_uri_real = $identity_uri
  }

  if $::osfamily == 'RedHat' {
    $group_require = Package['sahara']
    $dir_require = Package['sahara']
    $conf_require = Package['sahara']
  } else {
    # TO-DO(mmagr): This hack has to be removed as soon as following bug
    # is fixed. On Ubuntu sahara-trove is not installable because it needs
    # running database and prefilled sahara.conf in order to install package:
    # https://bugs.launchpad.net/ubuntu/+source/sahara/+bug/1452698
    Sahara_config<| |> -> Package['sahara']

    $group_require = undef
    $dir_require = Group['sahara']
    $conf_require = File['/etc/sahara']
  }
  group { 'sahara':
    ensure  => 'present',
    name    => 'sahara',
    system  => true,
    require => $group_require
  }

  user { 'sahara':
    ensure  => 'present',
    gid     => 'sahara',
    system  => true,
    require => Group['sahara']
  }

  file { '/etc/sahara/':
    ensure                  => directory,
    owner                   => 'root',
    group                   => 'sahara',
    require                 => $dir_require,
    selinux_ignore_defaults => true
  }

  file { '/etc/sahara/sahara.conf':
    owner                   => 'root',
    group                   => 'sahara',
    require                 => $conf_require,
    selinux_ignore_defaults => true
  }

  package { 'sahara':
    ensure => $package_ensure,
    name   => $::sahara::params::package_name,
    tag    => 'openstack',
  }

  # Because Sahara does not support SQLite, sahara-common will fail to be installed
  # if /etc/sahara/sahara.conf does not contain valid database connection and if the
  # database does not actually exist.
  # So we first manage the configuration file existence, then we configure Sahara and
  # then we install Sahara. This is a very ugly hack to fix packaging issue.
  # https://bugs.launchpad.net/cloud-archive/+bug/1450945
  File['/etc/sahara/sahara.conf'] -> Sahara_config<| |>

  Package['sahara'] -> Class['sahara::policy']

  Package['sahara'] ~> Service['sahara']
  Class['sahara::policy'] ~> Service['sahara']

  validate_re($database_connection, '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $database_connection {
    /^mysql:\/\//: {
      require mysql::bindings
      require mysql::bindings::python
    }
    /^postgresql:\/\//: {
      require postgresql::lib::python
    }
    /^sqlite:\/\//: {
      fail('Sahara does not support sqlite!')
    }
    default: {
      fail('Unsupported db backend configured')
    }
  }

  sahara_config {
    'DEFAULT/use_neutron': value => $use_neutron;
    'DEFAULT/use_floating_ips': value => $use_floating_ips;
    'DEFAULT/host':             value => $host_real;
    'DEFAULT/port':             value => $port_real;
    'DEFAULT/debug':            value => $debug;
    'DEFAULT/verbose':          value => $verbose;
    'database/connection':
      value => $database_connection,
      secret => true;
  }

  if $admin_password_real {
    sahara_config {
      'keystone_authtoken/auth_uri':          value => $auth_uri_real;
      'keystone_authtoken/identity_uri':      value => $identity_uri_real;
      'keystone_authtoken/admin_user':        value => $admin_user_real;
      'keystone_authtoken/admin_tenant_name': value => $admin_tenant_name_real;
      'keystone_authtoken/admin_password':
        value => $admin_password_real,
        secret => true;
    }
  }

  if $log_dir {
    sahara_config {
      'DEFAULT/log_dir': value => $log_dir;
    }
  } else {
    sahara_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  if $use_syslog {
    sahara_config {
      'DEFAULT/use_syslog':          value => true;
      'DEFAULT/syslog_log_facility': value => $log_facility;
    }
  } else {
    sahara_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'sahara':
    ensure     => $service_ensure,
    name       => $::sahara::params::service_name,
    hasstatus  => true,
    enable     => $enabled,
    hasrestart => true,
    subscribe  => Exec['sahara-dbmanage'],
  }

  exec { 'sahara-dbmanage':
    command     => $::sahara::params::dbmanage_command,
    path        => '/usr/bin',
    user        => 'sahara',
    refreshonly => true,
    subscribe   => [Package['sahara'], Sahara_config['database/connection']],
    logoutput   => on_failure,
  }

}
