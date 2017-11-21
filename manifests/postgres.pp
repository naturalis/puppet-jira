# == Class: jira::postgres
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
# === Copyright
#
# Apache2 license 2017.
#
class jira::postgres(
){

  $container_name       = 'postgres'
  $diffcmd              = "/usr/bin/diff <(docker image inspect --format='{{.Id}}' ${jira::postgres_image}) <(docker inspect --format='{{.Image}}' ${container_name})"
  $service_cmd          = "/usr/sbin/service docker-${container_name} restart"

  include 'docker'

  file { $jira::postgres_dir :
    ensure              => directory,
  }

  docker::run { $container_name :
    image               => $jira::postgres_image,
    volumes             => ["${jira::postgres_dir}/db:/var/lib/postgresql"],
    env                 => ['POSTGRES_USER=jira',"POSTGRES_PASSWORD=${jira::postgres_pass}",'POSTGRES_DB=jiradb','POSTGRES_ENCODING=UNICODE','POSTGRES_COLLATE=C','POSTGRES_COLLATE_TYPE=C'],
    require             => File[$jira::postgres_dir]
  }

  exec { $service_cmd :
    onlyif              => $diffcmd,
    require             => [Exec["/usr/bin/docker pull ${jira::postgres_image}"],Docker::Run[$container_name]]
  }

  exec {"/usr/bin/docker pull ${jira::postgres_image}" :
    schedule            => 'everyday-postgres',
  }

  schedule { 'everyday-postgres':
    period              => daily,
    repeat              => 1,
    range               => '7-9',
  }

}
