# jira

Puppet module to run docker containers for Jira.

* This module builds 3 separate docker containers:
    - [postgres:9.4](https://hub.docker.com/_/postgres/)
    - [blacklabelops/jira](https://hub.docker.com/r/blacklabelops/jira/)
    - [traefik](https://hub.docker.com/r/_/traefik/)

* In the vm system different folders are mounted for each function:
    - /data/postgres/db      = Postgres-container -> database
    - /data/jira             = Jira-container (/var/atlassian/jira) -> web dir
    - /data/traefik          = Traefik container for https proxy, with letsencrypt cert

## Dependencies
* We use the following dependencies:
    - [garethr/garethr-docker:5.3.0](https://github.com/garethr/garethr-docker/)
    - [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

Puppet code:

```
class { jira: }
```

## Result

Separated docker containers for every function.

## Limitations

This module has been built on and tested against Puppet 3.2 and 4.10

The module has been tested on:

* Ubuntu 16.04 LTS
