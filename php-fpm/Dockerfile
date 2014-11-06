FROM fedora:20
MAINTAINER Sascha Marcel Schmidt <docker@saschaschmidt.net>

RUN yum update -y && yum install -y php-fpm php-gd php-xdebug php-mysqli php-soap php-zip php-mbstring && yum clean-all 

COPY php-fpm.conf /etc/php-fpm.conf
COPY php-fpm.d/www.conf /etc/php-fpm.d/www.conf
COPY php.ini /etc/php.ini
COPY xdebug.ini /etc/php.d/xdebug.ini

EXPOSE 9000

CMD ["/usr/sbin/php-fpm", "-F"]

