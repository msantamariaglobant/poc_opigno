FROM drupal:8.4-apache

RUN apt-get update && apt-get install -y \
	curl \
	git \
	mysql-client \
	vim \
	wget \
	nano 

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php && \
	mv composer.phar /usr/local/bin/composer && \
	php -r "unlink('composer-setup.php');"

RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.4.2/drush.phar && \
	chmod +x drush.phar && \
	mv drush.phar /usr/local/bin/drush

RUN rm -rf /var/www/html/*

COPY apache-drupal.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /app

RUN composer create-project drupal-composer/drupal-project:8.x-dev /app --stability dev --no-interaction

RUN composer require drupal/opigno_lms

RUN mkdir -p /app/config/sync && chown -R www-data:www-data /app/web && chmod -R 777 /app/web

RUN drush si opigno_lms --db-url=mysql://root:Drupal@db/drupal --account-name=admin --account-pass=admin123 -y

RUN chmod -R 776 /app/web

WORKDIR /app/web

RUN drush config-export