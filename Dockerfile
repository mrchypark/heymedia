FROM resin/raspberrypi3-debian:jessie

# remove several traces of debian python
RUN apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# install python dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		libsqlite3-0 \
		libssl1.0.0 \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get -y autoremove

# key 63C7CC90: public key "Simon McVittie <smcv@pseudorandom.co.uk>" imported
# key 3372DCFA: public key "Donald Stufft (dstufft) <donald@stufft.io>" imported
RUN gpg --keyserver keyring.debian.org --recv-keys 4DE8FF2A63C7CC90 \
	&& gpg --keyserver pgp.mit.edu  --recv-key 6E3CBCE93372DCFA \
	&& gpg --keyserver pgp.mit.edu --recv-keys 0x52a43a1e4b77b059

ENV PYTHON_VERSION 2.7.13

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1

ENV SETUPTOOLS_VERSION 34.3.3

RUN set -x \
	&& buildDeps=' \
		curl \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/python/v$PYTHON_VERSION/Python-$PYTHON_VERSION.linux-armv7hf.tar.gz" \
	&& echo "2f0a1098aaf9b68afc4200fb50a162eb7d6dfe4cf4b49af5f2a1a217fa7e81c0  Python-2.7.13.linux-armv7hf.tar.gz" | sha256sum -c - \
	&& tar -xzf "Python-$PYTHON_VERSION.linux-armv7hf.tar.gz" --strip-components=1 \
	&& rm -rf "Python-$PYTHON_VERSION.linux-armv7hf.tar.gz" \
	&& ldconfig \
	&& if [ ! -e /usr/local/bin/pip3 ]; then : \
		&& curl -SLO "https://raw.githubusercontent.com/pypa/get-pip/430ba37776ae2ad89f794c7a43b90dc23bac334c/get-pip.py" \
		&& echo "19dae841a150c86e2a09d475b5eb0602861f2a5b7761ec268049a662dbd2bd0c  get-pip.py" | sha256sum -c - \
		&& python3 get-pip.py \
		&& rm get-pip.py \
	; fi \
	&& pip3 install --no-cache-dir --upgrade --force-reinstall pip=="$PYTHON_PIP_VERSION" setuptools=="$SETUPTOOLS_VERSION" \
	&& [ "$(pip list |tac|tac| awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
	&& find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' + \
	&& cd / \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/python ~/.cache

# install "virtualenv", since the vast majority of users of this image will want it
RUN pip3 install --no-cache-dir virtualenv

# install dbus-python dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		libdbus-1-dev \
		libdbus-glib-1-dev \
	&& rm -rf /var/lib/apt/lists/*

ENV PYTHON_DBUS_VERSION 1.2.4

# install dbus-python
RUN set -x \
	&& buildDeps=' \
		curl \
		build-essential \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/dbus-python \
	&& curl -SL "http://dbus.freedesktop.org/releases/dbus-python/dbus-python-$PYTHON_DBUS_VERSION.tar.gz" -o dbus-python.tar.gz \
	&& curl -SL "http://dbus.freedesktop.org/releases/dbus-python/dbus-python-$PYTHON_DBUS_VERSION.tar.gz.asc" -o dbus-python.tar.gz.asc \
	&& gpg --verify dbus-python.tar.gz.asc \
	&& tar -xzC /usr/src/dbus-python --strip-components=1 -f dbus-python.tar.gz \
	&& rm dbus-python.tar.gz* \
	&& cd /usr/src/dbus-python \
	&& PYTHON=python2.7 ./configure \
	&& make -j$(nproc) \
	&& make install -j$(nproc) \
	&& cd / \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/dbus-python

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -sf pip3 pip \
	&& { [ -e easy_install ] || ln -s easy_install-* easy_install; } \
	&& ln -sf idle3 idle \
	&& ln -sf pydoc3 pydoc \
	&& ln -sf python3 python \
	&& ln -sf python3-config python-config

CMD ["echo","'No CMD command was set in Dockerfile! Details about CMD command could be found in Dockerfile Guide section in our Docs. Here's the link: http://docs.resin.io/deployment/dockerfile"]
ENV PYTHONPATH /usr/lib/python2.7/dist-packages:/usr/lib/python2.7/site-packages:$PYTHONPATH

MAINTAINER chanyub.park "mrchypark@gmail.com"

RUN apt-get update && apt-get install -y python-pip python-dev build-essential libssl-dev libffi-dev

RUN apt-get update && apt-get install -y r-base libopenblas-base r-base-dev libcurl4-openssl-dev libxml2-dev
RUN apt-get update && Rscript -e 'install.packages(c("Rcpp","xml2","httr"), destdir ="/usr/local/lib/R/site-library")' \
    && Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/reticulate_0.8.tar.gz", repo=NULL, type="source", destdir ="/usr/local/lib/R/site-library")'

COPY app/requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

COPY app/ /app
WORKDIR /app

ENTRYPOINT ["Rscript"]
CMD ["app.R"]