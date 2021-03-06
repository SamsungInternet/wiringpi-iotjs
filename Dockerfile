#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: BSD
# Copyright 2019-present Samsung Electronics Co., Ltd. and other contributors

FROM ubuntu:18.04
MAINTAINER Philippe Coval (rzr@users.sf.net)

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG ${LC_ALL}

RUN echo "#log: Configuring locales" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y locales \
  && echo "${LC_ALL} UTF-8" | tee /etc/locale.gen \
  && locale-gen ${LC_ALL} \
  && dpkg-reconfigure locales \
  && sync

ENV project wiringpi-iotjs

RUN echo "#log: ${project}: Setup system" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y \
     dpkg-dev \
     git \
     make \
     sudo \
     npm \
  && apt-get clean \
  && sync

RUN echo "#log: Install iotjs" \
  && set -x \
  && sudo apt-get update -y \
  && apt-cache show iotjs || echo "TODO: iotjs is in debian:testing !"\
  && dpkg-architecture || :\
  && . /etc/os-release \
  && distro="${ID}_${VERSION_ID}" \
  && [ "debian" != "${ID}" ] || distro="${distro}.0" \
  && distro=$(echo "${distro}" | sed 's/.*/\u&/') \
  && [ "ubuntu" != "${ID}" ] || distro="x${distro}" \
  && url="http://download.opensuse.org/repositories/home:/rzrfreefr:/snapshot/$distro" \
  && file="/etc/apt/sources.list.d/org_opensuse_home_rzrfreefr_snapshot.list" \
  && echo "deb [allow-insecure=yes] $url /" | sudo tee "$file" \
  && sudo apt-get update -y \
  && apt-cache search --full iotjs \
  && version=$(apt-cache show "iotjs-snapshot" \
| grep 'Version:' | cut -d' ' -f2 | sort -n | head -n1 || echo 0) \
  && sudo apt-get install -y --allow-unauthenticated \
iotjs-snapshot="$version" iotjs="$version" \
  && which iotjs \
  && iotjs -h || echo "log: iotjs's usage expected to be printed before" \
  && sync

ENV project wiringpi-iotjs
ADD . /usr/local/opt/${project}/src/${project}
WORKDIR /usr/local/opt/${project}/src/${project}

WORKDIR /usr/local/opt/${project}/src/${project}
RUN echo "#log: ${project}: Checking sources" \
  && set -x \
  && make check \
  && sync

WORKDIR /usr/local/opt/${project}/src/${project}
ENTRYPOINT [ "/usr/bin/env", "make" ]
CMD [ "start" ]
