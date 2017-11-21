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

  user { 'jira' :
    ensure              => present,
    comment             => 'jira user',
    password            => sha1('jira'),
  }

  include 'docker'

  file { $jira::jira_dir :
    ensure              => directory,
    owner               => 'jira',
    group               => 'jira',
  }

  docker::run { $container_name :
    image               => $jira::jira_image,
    ports               => ["${jira::jira_port}:8080"],
    volumes             => ["${jira::jira_dir}:/var/atlassian/jira","${jira::jira_dir}/log:/var/atlassian/jira/log"],
    links               => ['postgres:postgres'],
    env                 => ['JVM_MINIMUM_MEMORY=384m','JVM_MAXIMUM_MEMORY=1g','JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb',"JIRA_DB_PASSWORD=${jira::postgres_pass}",'DOCKER_WAIT_HOST=postgres','DOCKER_WAIT_PORT=5432'],
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
