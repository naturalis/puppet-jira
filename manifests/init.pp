# == Class: jira
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
# === Copyright
#
# Apache2 license 2017.
#
class jira (
  $postgres_pass,
  $data_dir             = '/data',
  $jira_port            = '80',
  $jira_dir             = '/data/jira',
  $jira_image           = 'blacklabelops/jira:7.5.2',
  $postgres_dir         = '/data/postgres',
  $postgres_image       = 'postgres:9.4',
){

  file { $data_dir :
    ensure              => directory,
  }

  class { 'docker' :
    version             => 'latest',
  }

  class { 'jira::postgres' :
    require             => Class['docker']
  }

  class { 'jira::jira' :
    require             => Class['docker','jira::postgres']
  }

}
