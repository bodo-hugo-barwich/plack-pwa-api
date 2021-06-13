FROM ubuntu:xenial
RUN apt-get update &&\
  apt-get -y install apt-utils gcc make openssl &&\
  apt-get -y install cpanminus perl-modules perl-doc liblocal-lib-perl
RUN mkdir -p /usr/share/plack-pwa/log
COPY cpanfile /usr/share/plack-pwa/
RUN cd /usr/share/plack-pwa/\
  && date +"%s" > log/web_cpanm_install_$(date +"%F").log\
  ; cpanm -vn --installdeps . 2>&1 >> log/web_cpanm_install_$(date +"%F").log\
  ; date +"%s" >> log/web_cpanm_install_$(date +"%F").log
COPY etc/docker/entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh\
  && ln -s /usr/local/bin/entrypoint.sh /entrypoint.sh # backwards compat
RUN groupadd web &&\
  useradd pwa1_web -g web -md /home/plack-pwa -s /sbin/nologin &&\
  chmod a+rx /home/plack-pwa
ADD ./ /home/plack-pwa
USER pwa1_web
WORKDIR /home/plack-pwa
RUN mkdir -p /home/plack-pwa/log
ENTRYPOINT ["entrypoint.sh"]
CMD ["plackup", "--server", "Twiggy", "--port", "3000", "scripts/web.psgi"]
