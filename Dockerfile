FROM praekeltfoundation/alpine-buildpack-deps
ARG version=1.4.3

# pango-dev for cairo support
RUN apk update && apk add \
	pango-dev \
	cairo \
  # libncursesw5-dev \
  # libcairo2-dev \
  # libpango1.0-dev \
  # libtokyocabinet-dev \
	sqlite \
	wget \
	unzip

# ADD https://github.com/zevv/duc/releases/download/${VERSION}/duc-${VERSION}.tar.gz /root/src/
WORKDIR /usr/local/src

COPY duc-${version}.tar.gz .

RUN tar xvfz duc-${version}.tar.gz \
  && cd duc-${version} \
  && ./configure --with-db-backend=sqlite3 --disable-ui \
  && make \
  && make install

RUN wget -P /usr/local/src/ https://github.com/iamceege/tooltipster/archive/master.zip && \
    unzip /usr/local/src/master.zip -d /usr/local/src

FROM httpd:alpine

COPY --from=0 /usr/local/bin/duc /usr/local/bin/duc
# COPY --from=0 /usr/local/src/duc-${version}/www/duc.js /usr/local/apache2/htdocs/
# COPY --from=0 /usr/local/src/duc-master/www/duc-tooltipster.js /usr/local/apache2/htdocs/
# COPY --from=0 /usr/local/src/tooltipster-master/dist/css/tooltipster.main.min.css /usr/local/apache2/htdocs/
# COPY --from=0 /usr/local/src/tooltipster-master/dist/js/tooltipster.main.min.js /usr/local/apache2/htdocs/
WORKDIR /usr/local/apache2
COPY duc.cgi ./cgi-bin/
COPY httpd.conf ./conf/
RUN chmod 0755 ./cgi-bin/duc.cgi \
  && touch /usr/local/share/duc.db \
  && chown daemon:daemon /usr/local/share/duc.db \
	&& chown daemon:daemon ./cgi-bin/duc.cgi \
  && apk update && apk add \
		pango-dev \
		cairo \
		sqlite

VOLUME ["/data"]
EXPOSE 80
ENV DUC_CGI_OPTIONS -i -l -t --maxlevels=5 --pixels=1000

# # Install Dependencies
# RUN apt-get update -qq && \
# 	apt-get install -qq --force-yes libcairo2-dev libpango1.0-dev libtokyocabinet-dev wget unzip dh-autoreconf apache2 && \
# 	apt-get autoremove && \
# 	apt-get autoclean

# Install duc
# RUN mkdir /duc && \
#     autoreconf --install && \
#     ./configure && \
#     make && \
#     make install && \
#     ldconfig && \
#     cp /duc/duc-master/www/duc.js /var/www/html && \
#     cp /duc/duc-master/www/tooltipster-duc.css /var/www/html && \
#     wget -P /duc/ https://github.com/iamceege/tooltipster/archive/master.zip && \
#     unzip /duc/master.zip -d /duc/ && \
#     rm /duc/master.zip && \
#     cp /duc/tooltipster-master/js/jquery.tooltipster.min.js /var/www/html && \
#     cp /duc/tooltipster-master/css/tooltipster.css /var/www/html && \
#     rm -r /duc/duc-master && \
#     rm -r /duc/tooltipster-master
#
#
# COPY duc.cgi /usr/lib/cgi-bin/
# COPY 000-default.conf /etc/apache2/sites-available/
# COPY index.html /var/www/html/
#
# COPY duc_startup.sh /duc/
#
# #create a starter database so that we can set permissions for cgi access
# RUN mkdir /data && \
# 	duc index /data/ && \
# 	chmod 777 /duc/ && \
# 	chmod 777 /duc/.duc.db && \
# 	a2enmod cgi && \
# 	a2dismod deflate && \
# 	chmod +x /duc/duc_startup.sh && \
# 	chmod +x /usr/lib/cgi-bin/duc.cgi
#
# ENV DUC_CGI_OPTIONS -i -l -t --maxlevels=5 --pixels=1000
# VOLUME ["/data"]
# EXPOSE 80
#
# CMD /duc/duc_startup.sh
