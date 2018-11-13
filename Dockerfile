FROM ubuntu:latest

RUN set -x && \
      apt update && \
      apt install -y autoconf bison build-essential git libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev && \
      git clone https://github.com/rbenv/rbenv.git ~/.rbenv

RUN apt install -y curl

ENV PATH="/root/.rbenv/bin:$PATH"

RUN eval "$(rbenv init -)"

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN rbenv install 2.4.2  -v

# docker run -v .:/src --tty -i -t 1b1616875bf3 /bin/bash