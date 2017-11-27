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
  $traefik_pass,
  $jira_internal,
  $jira_url,
  $jira_image           = 'blacklabelops/jira:7.5.2',
  $postgres_image       = 'postgres:9.4',
  $traefik_image        = 'traefik:1.4-alpine',
){

  file { '/data' :
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
