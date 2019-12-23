server {
 listen 80;
 root /var/www/html;
 index index.php;
 server_name mysite www.mysite;
 access_log /var/log/nginx/mysite.access_log;
 error_log /var/log/nginx/mysite.error_log
 notice;



 location / {
  try_files $uri $uri/ /index.php?$args;
 }
 
 location ~ \.php$ {
	include snippets/fastcgi-php.conf;
	fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
 }
 
#viamybox optimization
 gzip on; # включаем сжатие gzip
 gzip_disable "msie6";
 gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript;
 
 location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
    access_log off;
    log_not_found off;
    expires max; # кеширование статики
 }
 location ~ /\. {
    deny all; # запрет для скрытых файлов
 }
 location ~* /(?:uploads|files)/.*\.php$ {
    deny all; # запрет для загруженных скриптов
 }
#location / {
#    try_files $uri $uri/ /index.php?$args; # permalinks
# }

}
