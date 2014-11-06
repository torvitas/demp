-include make.d/*

all: docker-nginx docker-mariadb docker-php-fpm
pull-all: pull-nginx pull-php-fpm pull-mariadb
install: install-nginx install-php-fpm install-mariadb
run-all: run-nginx

docker-nginx:
	docker build -t $(DOCKERPREFIX)nginx nginx

docker-php-fpm:
	docker build -t $(DOCKERPREFIX)php-fpm php-fpm

docker-mariadb:
	docker build -t $(DOCKERPREFIX)mariadb mariadb

pull-nginx:
	docker pull torvitas/nginx

pull-php-fpm:
	docker pull torvitas/php-fpm

pull-mariadb:
	docker pull torvitas/mariadb

install-nginx: install-docker-stoprm systemd-service-folder install-nginx-data install-www-data
	sudo cp nginx/docker-nginx.service.tmpl $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service
	sudo sed -i s/$(DOCKERNAMESPACEPLACEHOLDER)/$(DOCKERNAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service
	sudo sed -i s/$(NAMESPACEPLACEHOLDER)/$(NAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service
	sudo sed -i s/$(HTTPPORTPLACEHOLDER)/$(HTTPPORT)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service
	sudo sed -i s/$(HTTPSPORTPLACEHOLDER)/$(HTTPSPORT)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service
	sudo systemctl enable $(NAMESPACE)-nginx.service

install-php-fpm: install-docker-stoprm systemd-service-folder install-www-data
	sudo cp php-fpm/docker-php-fpm.service.tmpl $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php-fpm.service
	sudo sed -i s/$(DOCKERNAMESPACEPLACEHOLDER)/$(DOCKERNAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php-fpm.service
	sudo sed -i s/$(NAMESPACEPLACEHOLDER)/$(NAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php-fpm.service
	sudo systemctl enable $(NAMESPACE)-php-fpm.service

install-mariadb: install-docker-stoprm systemd-service-folder install-mariadb-data
	sudo cp mariadb/docker-mariadb.service.tmpl $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-mariadb.service
	sudo sed -i s/$(DOCKERNAMESPACEPLACEHOLDER)/$(DOCKERNAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-mariadb.service
	sudo sed -i s/$(NAMESPACEPLACEHOLDER)/$(NAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-mariadb.service
	sudo sed -i s/$(MARIADBPORTPLACEHOLDER)/$(MARIADBPORT)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-mariadb.service
	sudo systemctl enable $(NAMESPACE)-mariadb.service

run-nginx: run-php-fpm
	sudo systemctl start $(NAMESPACE)-nginx

run-php-fpm: run-mariadb
	sudo systemctl start $(NAMESPACE)-php-fpm

run-mariadb:
	sudo systemctl start $(NAMESPACE)-mariadb

install-nginx-data:
	sudo mkdir -p $(DOCKERHOSTVOLUMES)$(NAMESPACE)-nginx/conf.d/
	docker run --name $(NAMESPACE)-nginx-data -v $(DOCKERHOSTVOLUMES)$(NAMESPACE)-nginx/conf.d/:/etc/nginx/conf.d/ busybox

install-mariadb-data:
	sudo mkdir -p $(DOCKERHOSTVOLUMES)$(NAMESPACE)-mariadb/data/
	sudo chmod o+w $(DOCKERHOSTVOLUMES)$(NAMESPACE)-mariadb/data/
	docker run --name $(NAMESPACE)-mariadb-data -v $(DOCKERHOSTVOLUMES)$(NAMESPACE)-mariadb/data/:/var/lib/mysql/ busybox
	docker run --rm --volumes-from=$(NAMESPACE)-mariadb-data $(DOCKERPREFIX)mariadb /config_mariadb.sh
	sudo chmod o-w $(DOCKERHOSTVOLUMES)$(NAMESPACE)-mariadb/data/

install-www-data:
	sudo mkdir -p $(DOCKERHOSTVOLUMES)$(NAMESPACE)-www/
	docker run --name $(NAMESPACE)-www-data -v $(DOCKERHOSTVOLUMES)$(NAMESPACE)-www/:/srv/www/ busybox

systemd-service-folder:
	sudo mkdir -p $(SYSTEMDSERVICEFOLDER)

install-docker-stoprm:
	sudo cp scripts/stoprm.sh /usr/local/bin/docker-stoprm
	sudo chmod +x /usr/local/bin/docker-stoprm

uninstall:
	-sudo systemctl stop $(NAMESPACE)-nginx
	-sudo systemctl stop $(NAMESPACE)-php-fpm
	-sudo systemctl stop $(NAMESPACE)-mariadb
	-sudo systemctl disable $(NAMESPACE)-nginx
	-sudo systemctl disable $(NAMESPACE)-php-fpm
	-sudo systemctl disable $(NAMESPACE)-mariadb
	-docker stop $(NAMESPACE)-nginx
	-docker rm $(NAMESPACE)-nginx
	-docker stop $(NAMESPACE)-php-fpm
	-docker rm $(NAMESPACE)-php-fpm
	-docker stop $(NAMESPACE)-mariadb
	-docker rm $(NAMESPACE)-mariadb
	-docker stop $(NAMESPACE)-nginx-data
	-docker rm $(NAMESPACE)-nginx-data
	-docker stop $(NAMESPACE)-www-data
	-docker rm $(NAMESPACE)-www-data
	-docker stop $(NAMESPACE)-mariadb-data
	-docker rm $(NAMESPACE)-mariadb-data
	-cd $(SYSTEMDSERVICEFOLDER); sudo rm $(NAMESPACE)-nginx.service $(NAMESPACE)-php-fpm.service $(NAMESPACE)-mariadb.service
	-sudo rm -rf $(DOCKERHOSTVOLUMES)$(NAMESPACE)-nginx
	-sudo rm -rf $(DOCKERHOSTVOLUMES)$(NAMESPACE)-www
	-sudo rm -rf $(DOCKERHOSTVOLUMES)$(NAMESPACE)-mariadb
