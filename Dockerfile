FROM codfrm/docker-nginx:latest

LABEL maintainer="CodFrm <love@xloli.top>"

ENV PHP_VERSION="7.2.11"
ENV PHPIZE_DEPS="\
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkgconf \
    re2c"

WORKDIR /home

RUN CONFIG="\
    --prefix=/usr/local/php \
    --exec-prefix=/usr/local/php \
    --bindir=/usr/local/php/bin \
    --sbindir=/usr/local/php/sbin \
    --includedir=/usr/local/php/include \
    --libdir=/usr/local/php/lib/php \
    --mandir=/usr/local/php/php/man \
    --with-config-file-path=/usr/local/php/etc \
    --with-mysql-sock=/var/lib/mysql/mysql.sock \
    --with-mysqli=shared,mysqlnd \
    --with-pdo-mysql=shared,mysqlnd \
    --with-mhash \
    --enable-ftp \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-openssl \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --enable-fpm \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --enable-cgi \
    " \
    && apk add --no-cache \
    $PHPIZE_DEPS \
    curl-dev \
    libxml2-dev \
    sqlite-dev \
    && wget -O php.tar.xz http://hk2.php.net/distributions/php-${PHP_VERSION}.tar.xz \
    && tar -xvf php.tar.xz \
    && cd php-${PHP_VERSION} \
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && ln -s /usr/local/php/bin/php /usr/bin/php \
    && ln -s /usr/local/php/bin/php-cgi /usr/bin/php-cgi \
    && ln -s /usr/local/php/bin/php-config /usr/bin/php-config \
    && ln -s /usr/local/php/bin/phpize /usr/bin/phpize \
    && ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm \
    && cd .. \
    && rm -rf php-${PHP_VERSION} php.tar.xz \
    && apk del $PHPIZE_DEPS 

COPY ./config/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY ./config/www.conf /usr/local/php/etc/php-fpm.d/www.conf
COPY ./config/nginx.fpm.conf /etc/nginx/conf.d/default.conf
COPY ./config/php.ini /usr/local/php/etc/php.ini

ENTRYPOINT php-fpm && nginx -g "daemon off;"