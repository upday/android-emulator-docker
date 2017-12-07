FROM butomo1989/docker-android-x86-7.1.1

LABEL maintainer "Pawel Polanski <pawel@upday.com>"

COPY src /root/src
COPY supervisord.conf /root/
RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf

CMD /usr/bin/supervisord --configuration supervisord.conf
