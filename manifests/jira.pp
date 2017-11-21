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

  file { $jira::jira_dir :
    ensure              => directory,
  }

  docker::run { $container_name :
    image               => $jira::jira_image,
    ports               => ["${jira::jira_port}:8080"],
    volumes             => ["${jira::jira_dir}:/var/atlassian/jira"],
    links               => ['postgres:db'],
    env                 => ['CATALINA_OPTS= -Xms384m -Xmx1g','JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb',"JIRA_DB_PASSWORD=${jira::postgres_pass}",'DOCKER_WAIT_HOST=postgres','DOCKER_WAIT_PORT=5432'],
    require             => File[$jira::jira_dir]
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
