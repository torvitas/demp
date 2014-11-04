# DEMP

Docker + nginx + mariadb + php-fpm
LEMP in docker containers.

## Quickstart
`# make pull-all; make run-all`
This will pull a docker image for each of the services and
create data only containers. To manage the lifecycle of the
Docker containers systemd is being used.

## Setup
- for parametrisation you can edit the variables in the Makefile
- to just build the images run `# make all`
- instead of building the images you can also pull them from the docker registry by `# make pull-all`
- to install the systemd service files run `# make install`
- to do the previous step + run the containers run `# make run-all`
- to uninstall the containers, services and host volumes run `# make uninstall`
    - this only uninstalls containers that match the NAMESPACE variable
    - this does not delete the images

## Troubleshooting
- systemctl: command not found
    - you do need systemd
- dial unix /var/run/docker.sock: no such file or directory
    - docker needs to be installed and running
        - `# yum install docker-io; systemctl start docker`
