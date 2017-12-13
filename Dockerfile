FROM php:7.1.11-fpm-alpine3.4

# Supervisord Vars
ENV PYTHON_VERSION=2.7.12-r0
ENV PY_PIP_VERSION=8.1.2-r0
ENV SUPERVISOR_VERSION=3.3.1

# MediaWiki Vars
ENV MEDIAWIKI_MAJOR_VERSION 1.29
ENV MEDIAWIKI_BRANCH REL1_29
ENV MEDIAWIKI_VERSION 1.29.2
ENV MEDIAWIKI_SHA512 53c6ca82280938d1e3281aa296f44c86dcfbbdf82710b7de578e73e1ef3150db145e059c8c8208859bc437f7a7f7a13eed896be9d44fd364a0ee6d78893fbe86

# install dependencies via apk
RUN apk update && apk add -u python=$PYTHON_VERSION py-pip=$PY_PIP_VERSION libpng-dev nginx git nodejs

# install supervisord
RUN pip install supervisor==$SUPERVISOR_VERSION

# install php extensions
RUN docker-php-ext-install mysqli json mbstring gd


# Install MEDIAWIKI

# Change working dir
WORKDIR /var/www/html/

RUN mkdir /var/www/data && chown www-data:www-data /var/www/data

# download MEDIAWIKI
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
	&& echo "${MEDIAWIKI_SHA512} *mediawiki.tar.gz" | sha512sum -c - \
	&& tar -xz --strip-components=1 -f mediawiki.tar.gz \
	&& rm mediawiki.tar.gz \
  && chown -R www-data:www-data extensions skins cache images

RUN cd extensions \
		&& wget https://extdist.wmflabs.org/dist/extensions/VisualEditor-REL1_29-b655946.tar.gz \
		&& tar -xzf VisualEditor-REL1_29-b655946.tar.gz

# install parsoid, needed by media wiki to run the visual editor plugin
RUN npm install -g parsoid

# add customer configuration for nginx and supervisord
ADD server-templates/config.yaml /usr/lib/node_modules/parsoid
ADD server-templates/nginx.conf /etc/nginx
ADD server-templates/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE  80
