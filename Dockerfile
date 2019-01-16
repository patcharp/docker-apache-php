FROM ubuntu:16.04
MAINTAINER Patcharapong Prohmwichai <patcharp@live.com>



# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils \
    apache2 php7.0 php7.0-mysql libapache2-mod-php7.0 curl lynx-cur \
    php7.0-gd php-imagick php7.0-imap php7.0-intl php7.0-mbstring php7.0-mcrypt php-memcached php7.0-sqlite3 \
    php7.0-pspell php7.0-recode php7.0-xml  php7.0-xmlreader  php7.0-xmlrpc  php7.0-xmlwriter php7.0-tidy php7.0-xsl

# Enable apache mods.
RUN a2enmod php7.0
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/apache2/php.ini
RUN sed -i "s/expose_php = .*$/expose_php = Off/" /etc/php/7.0/apache2/php.ini
# Hide sensitive info
RUN echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
RUN echo "ServerSignature Off" >> /etc/apache2/apache2.conf

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Custom PHP Variable by iRecruit
# TODO:

# Expose apache.
EXPOSE 80

# Copy this repo into place.
ADD www /var/www/site

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND