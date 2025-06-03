FROM nginx:latest

WORKDIR /usr/share/nginx/html

COPY App/index.html .

EXPOSE 80
