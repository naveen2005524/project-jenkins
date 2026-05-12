FROM alpine:latest

RUN apk update
RUN apk add apache2


COPY index.html /var/www/localhost/htdocs/index.html

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]
