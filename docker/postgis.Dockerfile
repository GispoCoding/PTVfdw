ARG IMAGE_VERSION=12.4

FROM kartoza/postgis:$IMAGE_VERSION
MAINTAINER gispo<info@gispo.fi>

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
    python \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    libxml2-dev \
    libxslt-dev \
    libssl-dev \
    libxml2-utils \
    xsltproc \
    postgresql-12-cron \
    && apt clean

# Install Multicorn for Foreign Data Wrappers
RUN wget https://github.com/pgsql-io/multicorn2/archive/refs/tags/v2.3.tar.gz \
    && tar -xvf v2.3.tar.gz \
    && cd multicorn2-2.3 \
    && make && make install \
    && cd ..

# Install plpygis for Foreign Data Wrapper support for Postgis
RUN pip3 install -q plpygis
RUN pip3 install -q requests

WORKDIR /

COPY dev_install.sh /scripts/dev_install.sh
RUN chmod +x /scripts/dev_install.sh
