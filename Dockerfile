FROM ubuntu

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php-cli \
        php-fpm \
        php-gd \
        php-mcrypt \
        php-mbstring \
        php-pdo\
        php-curl \
        php-xml \
        php-zip \
        nginx \
        supervisor

# Configure and secure PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/fpm/php.ini
    # sed -i '/^listen = /clisten = unix:/run/php/php7.0-fpm.sock' /etc/php/7.0/fpm/pool.d/www.conf
    # sed -i '/^listen = /clisten = 0.0.0.0:9000' /etc/php/7.0/fpm/pool.d/www.conf


RUN mkdir -p /run/php/php7.0-fpm/ && touch /run/php/php7.0-fpm/pid

# NGINX
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

ARG nginx=nginx.conf
COPY $nginx /etc/nginx/nginx.conf

ARG server=server.conf
COPY $server /etc/nginx/conf.d/default.conf

RUN useradd nginx && usermod -aG www-data nginx

# SUPERVISOR
RUN mkdir -p /var/log/supervisor \
    && touch /var/log/supervisor/supervisord.log

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clear apt
RUN rm -rf /var/lib/apt/lists/*

ADD ./install.sh /

CMD bash /install.sh $SUB && sed -i "s|SUB|$SUB|" /etc/nginx/conf.d/default.conf && \
  /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
