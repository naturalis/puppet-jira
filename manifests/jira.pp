# == Class: jira::jira
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
# === Copyright
#
# Apache2 license 2017.
#
class jira::jira(
){

  $container_name       = 'jira'
  $diffcmd              = "/usr/bin/diff <(docker image inspect --format='{{.Id}}' ${jira::jira_image}) <(docker inspect --format='{{.Image}}' ${container_name})"
  $service_cmd          = "/usr/sbin/service docker-${container_name} restart"

  include 'docker'

  file { "/data/${jira::container_name}" :
    ensure              => directory,
    owner               => 1000,
    group               => 1000,
  }

  docker::run { $container_name :
    image               => $jira::jira_image,
    volumes             => ["${jira::container_name}:/var/atlassian/jira"],
    links               => ['postgres:db'],
    env                 => ['JVM_MINIMUM_MEMORY=384m','JVM_MAXIMUM_MEMORY=1g','JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb',"JIRA_DB_PASSWORD=${jira::postgres_pass}",'DOCKER_WAIT_HOST=postgres','DOCKER_WAIT_PORT=5432'],
    require             => File["/data/${jira::container_name}"]
  }

  exec { $service_cmd :
    onlyif              => $diffcmd,
    require             => [Exec["/usr/bin/docker pull ${jira::jira_image}"],Docker::Run[$container_name]]
  }

  exec {"/usr/bin/docker pull ${jira::jira_image}" :
    schedule            => 'everyday-jira',
  }

  schedule { 'everyday-jira':
    period              => daily,
    repeat              => 1,
    range               => '7-9',
  }

}
