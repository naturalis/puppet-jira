# == Class: jira::traefik
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
# === Copyright
#
# Apache2 license 2017.
#
class jira::traefik(

  $traefik_pass         = $jira::traefik_pass,
  $jira_internal        = $jira::jira_internal,
  $jira_url             = $jira::jira_url,

){

  $container_name       = 'traefik'
  $diffcmd              = "/usr/bin/diff <(docker image inspect --format='{{.Id}}' ${jira::traefik_image}) <(docker inspect --format='{{.Image}}' ${container_name})"
  $service_cmd          = "/usr/sbin/service docker-${container_name} restart"

  include 'docker'

  file { "/data/${container_name}" :
    ensure              => directory,
  }

  file { "/data/${container_name}/traefik.toml" :
    ensure              => present,
    content             => template('jira/traefik.toml.erb'),
    pull_on_start       => false,
    require             => File["/data/${container_name}"]
  }

  file { "/data/${container_name}/acme.json" :
    ensure              => present,
    mode                => '0600',
    require             => File["/data/${container_name}"]
  }

  docker::run { $container_name :
    image               => $jira::traefik_image,
    ports               => ['8080:8080','80:80','443:443'],
    volumes             => ["/data/${container_name}/traefik.toml:/etc/traefik/traefik.toml","/data/${container_name}/acme.json:/etc/traefik/acme.json"],
    require             => File["/data/${container_name}"]
  }

  exec { $service_cmd :
    onlyif              => $diffcmd,
    require             => [Exec["/usr/bin/docker pull ${jira::traefik_image}"],Docker::Run[$container_name]]
  }

  exec {"/usr/bin/docker pull ${jira::traefik_image}" :
    schedule            => 'everyday-traefik',
  }

  schedule { 'everyday-traefik':
    period              => daily,
    repeat              => 1,
    range               => '7-9',
  }

}
