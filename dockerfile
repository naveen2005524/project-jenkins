FROM alpine:latest

RUN apk update
RUN apk add apache2
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf

COPY index.html /var/www/localhost/htdocs/index.html
COPY app.html /var/www/localhost/htdocs/app.html

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]
