FROM nginx:1.13.5

RUN apt-get update -qq && apt-get -y install curl unzip && rm /etc/nginx/conf.d/default.conf

RUN curl -sS https://releases.hashicorp.com/consul-template/0.19.3/consul-template_0.19.3_linux_amd64.zip > consul-template.zip
RUN unzip consul-template.zip -d /usr/local/bin

RUN mkdir /etc/consul-templates
ENV CT_FILE /etc/consul-templates/nginx.conf

COPY nginx.conf.ctmpl $CT_FILE

ENV NX_FILE /etc/nginx/conf.d/service-loadbalancer.conf

ENV CONSUL consul:8500

CMD /usr/sbin/nginx -c /etc/nginx/nginx.conf \
& CONSUL_TEMPLATE_LOG=debug consul-template \
  -consul-addr $CONSUL \
  -template "$CT_FILE:$NX_FILE:/usr/sbin/nginx -s reload";

