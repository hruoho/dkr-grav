FROM nginx:latest

# PHP
ENV PHP_FPM_USER=www-data

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
 && echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y php5-fpm php5-cli php5-curl php5-gd ca-certificates gettext-base vim \
 && sed 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf


# NGINX
ARG nginx=nginx.conf
COPY $nginx /etc/nginx/nginx.conf

ARG server=server-ssl.conf
COPY $server /etc/nginx/conf.d/default.conf

ARG sub=''
RUN sed -i "s|SUB|$sub|" /etc/nginx/conf.d/default.conf \
  && sed -i "s|//index.php|/index.php|" /etc/nginx/conf.d/default.conf

# Log / forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# SSL / config and dummy certificates for localhost
COPY ./ssl/server.crt /etc/nginx/certs/server.crt
COPY ./ssl/server.key /etc/nginx/certs/server.key
COPY ./ssl/dhparams.pem /etc/nginx/certs/dhparams.pem
# create cert chain for OCSP
RUN cd /etc/nginx/certs && cat server.key server.crt dhparams.pem > chain.pem

# NGINX + GRAV
RUN rm /usr/share/nginx/html/*
COPY ./grav-admin /usr/share/nginx/html
COPY ./perms.sh /usr/share/nginx/html/
RUN cd /usr/share/nginx/html && bash perms.sh

# GRAV setup
WORKDIR /usr/share/nginx/html/
# TODO: use env-vars here
RUN ./bin/plugin login add-user -u admin -p P4ssW0rd -t Admin -e change@me.com -P b -N "Full Name"
RUN bash perms.sh

# SUPERVISOR
RUN apt-get update \
    && apt-get install -y supervisor\
    && mkdir -p /var/log/supervisor \
    && touch /var/log/supervisor/supervisord.log \
    && rm -rf /var/lib/apt/lists/*
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
