 curl esl-1.esl.default.svc.cluster.local:9000
server {
    listen 9000;
    proxy_pass esl-0.esl.default.svc.cluster.local:9000;
}

server {
    listen 37021;
    proxy_pass esl-0.esl.default.svc.cluster.local:37021;
}

server {
    listen 9001;
    proxy_pass esl-1.esl.default.svc.cluster.local:9000;
}

server {
    listen 37022;
    proxy_pass esl-1.esl.default.svc.cluster.local:37021;
}

server {
    listen 8080;
    proxy_pass shopweb-0.shopweb.default.svc.cluster.local:8080;
}

server {
    listen 3306;
    proxy_pass mysql-0.mysql.default.svc.cluster.local:3306;
}