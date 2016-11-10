FROM phusion/baseimage

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

# Clear apt
RUN rm -rf /var/lib/apt/lists/*

# Configure and secure PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/fpm/php.ini
    # sed -i '/^listen = /clisten = unix:/run/php/php7.0-fpm.sock' /etc/php/7.0/fpm/pool.d/www.conf
    # sed -i '/^listen = /clisten = 0.0.0.0:9000' /etc/php/7.0/fpm/pool.d/www.conf



RUN useradd nginx && usermod -aG www-data nginx
RUN mkdir -p /run/php/php7.0-fpm/ && touch /run/php/php7.0-fpm/pid

# NGINX
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#  && ln -sf /dev/stderr /var/log/nginx/error.log

ADD ./add/nginx.conf /etc/nginx/nginx.conf
ADD ./add/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/html

# SUPERVISOR
RUN mkdir -p /var/log/supervisor \
    && touch /var/log/supervisor/supervisord.log

ADD ./add/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV SUB=''

CMD if [ ! -z $SUB ]; \
    then \
    perl -pi -e "s|location /|location /$SUB|" /etc/nginx/conf.d/default.conf; \
    perl -pi -e "s|/index\.php|/$SUB/index.php|" /etc/nginx/conf.d/default.conf; \
    fi && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

# If SUB is not empty, relocate Grav and fix config
# CMD if [ ! -z $SUB ]; \
#     then mv html $SUB; \
#     mkdir html && mv $SUB html/; \
#     perl -pi -e "s|location /|location /$SUB|" /etc/nginx/conf.d/default.conf; \
#     perl -pi -e "s|/index\.php|/$SUB/index.php|" /etc/nginx/conf.d/default.conf; \
#     fi && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
