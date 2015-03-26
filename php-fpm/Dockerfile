FROM php:5.5-fpm
MAINTAINER Sascha Marcel Schmidt <docker@saschaschmidt.net>

RUN apt-get update
RUN apt-get install -y wget libpng12-dev libjpeg-dev re2c libmcrypt-dev libxml2-dev --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN cd /tmp/ && \
    wget http://pecl.php.net/get/memcache-2.2.7.tgz && \
    tar zxvf memcache-2.2.7.tgz && \
    cd memcache-2.2.7 && \
    /usr/local/bin/phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config --enable-memcache && \
    make && \
    cp modules/* /usr/local/lib/php/extensions/ && \
    touch /usr/local/etc/php/conf.d/memcache.ini && \
    echo 'extension=/usr/local/lib/php/extensions/memcache.so' > /usr/local/etc/php/conf.d/memcache.ini

RUN cd /tmp/ && \
    wget http://pecl.php.net/get/xdebug-2.3.2.tgz && \
    tar zxvf xdebug-2.3.2.tgz && \
    cd xdebug-2.3.2 && \
    /usr/local/bin/phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config --enable-xdebug && \
    make && \
    cp modules/* /usr/local/lib/php/extensions/ && \
    touch /usr/local/etc/php/conf.d/xdebug.ini && \
    echo 'zend_extension=/usr/local/lib/php/extensions/xdebug.so' > /usr/local/etc/php/conf.d/xdebug.ini

RUN docker-php-ext-install mysqli iconv mcrypt mbstring zip soap mysql bcmath

RUN cd /usr/src/php/ext/gd && \
    /usr/local/bin/phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config \
        --enable-gd \
        --with-jpeg-dir \
        --with-png-dir && \
    make && \
    cp modules/* /usr/local/lib/php/extensions/ && \
    touch /usr/local/etc/php/conf.d/gd.ini && \
    echo 'extension=/usr/local/lib/php/extensions/gd.so' > /usr/local/etc/php/conf.d/gd.ini

RUN mkdir /usr/local/lib/php/session && chown www-data.www-data /usr/local/lib/php/session

COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
