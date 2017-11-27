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
){

  $container_name       = 'traefik'
  $diffcmd              = "/usr/bin/diff <(docker image inspect --format='{{.Id}}' ${jira::traefik_image}) <(docker inspect --format='{{.Image}}' ${container_name})"
  $service_cmd          = "/usr/sbin/service docker-${container_name} restart"

  include 'docker'

  file { "/data/${jira::container_name}" :
    ensure              => directory,
  }

  file { "/data/${jira::container_name}/traefik.toml" :
    ensure              => present,
    content             => template('jira/traefik.toml.erb'),
    require             => File["/data/${jira::container_name}"]
  }

  docker::run { $container_name :
    image               => $jira::traefik_image,
    ports               => ['8080:8080','80:80'],
    volumes             => ["/data/${jira::container_name}/traefik.toml:/etc/traefik/traefik.toml"],
    require             => File["/data/${jira::container_name}"]
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
