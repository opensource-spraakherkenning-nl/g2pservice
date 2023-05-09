FROM debian:11.4-slim
LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="Grapheme to phoneme conversion"

ENV UWSGI_UID=100
ENV UWSGI_GID=100
ENV UWSGI_PROCESSES=2
ENV UWSGI_THREADS=2

# By default, data from the webservice will be stored on the mount you provide
ENV CLAM_ROOT=/data/g2pservice
ENV CLAM_PORT=80
# (set to true or false, enable this if you run behind a properly configured reverse proxy only)
ENV CLAM_USE_FORWARDED_HOST=false
# Set this for interoperability with the CLARIN Switchboard
ENV CLAM_SWITCHBOARD_FORWARD_URL=""

# By default, there is no authentication on the service,
# which is most likely not what you want if you aim to
# deploy this in a production environment.
# You can connect your own Oauth2/OpenID Connect authorization by setting the following environment parameters:
ENV CLAM_OAUTH=false
#^-- set to true to enable
ENV CLAM_OAUTH_AUTH_URL=""
#^-- example for clariah: https://authentication.clariah.nl/Saml2/OIDC/authorization
ENV CLAM_OAUTH_TOKEN_URL=""
#^-- example for clariah https://authentication.clariah.nl/OIDC/token
ENV CLAM_OAUTH_USERINFO_URL=""
#^--- example for clariah: https://authentication.clariah.nl/OIDC/userinfo
ENV CLAM_OAUTH_CLIENT_ID=""
ENV CLAM_OAUTH_CLIENT_SECRET=""
#^-- always keep this private!

#Set to 1 to enable development version of CLAM
ARG CLAM_DEV=0

# Install all global dependencies
RUN apt-get update && apt-get install -y --no-install-recommends runit curl ca-certificates nginx uwsgi uwsgi-plugin-python3 python3-pip python3-yaml python3-lxml python3-requests python3-dev git make g++ libtool gfortran autoconf automake autoconf-archive gawk wget perl zip

# Prepare environment
RUN mkdir -p /etc/service/nginx /etc/service/uwsgi

# Patch to set proper mimetype for CLAM's logs; maximum upload size
RUN sed -i 's/txt;/txt log;/' /etc/nginx/mime.types &&\
    sed -i 's/xml;/xml xsl;/' /etc/nginx/mime.types &&\
    sed -i 's/client_max_body_size 1m;/client_max_body_size 1000M;/' /etc/nginx/nginx.conf

# Temporarily add the sources of this webservice
COPY . /usr/src/webservice

#Install mitlm and phonetisaurus
RUN mkdir -p /usr/src && cd /usr/src &&\
    git clone https://github.com/mitlm/mitlm &&\
    cd mitlm &&\
    autoreconf -i &&\
    ./configure &&\
    make &&\
    make install &&\
    cd /usr/src &&\
    wget http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.6.2.tar.gz && \
    tar --no-same-permissions --no-same-owner -xvzf openfst-1.6.2.tar.gz && \
    cd openfst-1.6.2 && \
    ./configure --enable-static --enable-shared --enable-far --enable-ngram-fsts && \
    make -j $(nproc) && \
    make install && \
    ldconfig &&\
    cd /usr/src &&\
    git clone https://github.com/AdolfVonKleist/Phonetisaurus.git &&\
    cd Phonetisaurus &&\
    pip3 install pybindgen &&\
    PYTHON=python3 ./configure --enable-python &&\
    make &&\
    make install &&\
    cp .libs/Phonetisaurus.so python/ &&\
    cd python &&\
    python3 setup.py install &&\
    ln -s /usr/bin/python3 /usr/bin/python

# Prepare environment
RUN mkdir -p /etc/service/nginx /etc/service/uwsgi

# Temporarily add the sources of this webservice
COPY . /usr/src/webservice

# Patch to set proper mimetype for CLAM's logs; maximum upload size
RUN sed -i 's/txt;/txt log;/' /etc/nginx/mime.types &&\
    sed -i 's/xml;/xml xsl;/' /etc/nginx/mime.types &&\
    sed -i 's/client_max_body_size 1m;/client_max_body_size 1000M;/' /etc/nginx/nginx.conf


# Configure webserver and uwsgi server
RUN cp /usr/src/webservice/runit.d/nginx.run.sh /etc/service/nginx/run &&\
    chmod a+x /etc/service/nginx/run &&\
    cp /usr/src/webservice/runit.d/uwsgi.run.sh /etc/service/uwsgi/run &&\
    chmod a+x /etc/service/uwsgi/run &&\
    cp /usr/src/webservice/g2pservice/g2pservice.wsgi /etc/g2pservice.wsgi &&\
    chmod a+x /etc/g2pservice.wsgi &&\
    cp -f /usr/src/webservice/g2pservice.nginx.conf /etc/nginx/sites-enabled/default

# Install the the service itself
RUN if [ $CLAM_DEV -eq 1 ]; then pip install git+https://github.com/proycon/clam.git; fi &&\
    cd /usr/src/webservice && pip install . && rm -Rf /usr/src/webservice
RUN ln -s /usr/local/lib/python3.*/dist-packages/clam /opt/clam

# Remove build-time dependencies
RUN apt-get remove -y autoconf automake autoconf-archive g++ gfortran python3-dev wget

VOLUME ["/data"]
EXPOSE 80
WORKDIR /

ENTRYPOINT ["runsvdir","-P","/etc/service"]
