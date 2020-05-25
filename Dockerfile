FROM ruby:2.4.0-slim

MAINTAINER Alexander Morozov <oleksandr.morozov@customertimes.com>

ENV APP_HOME /food_in_hoods
ENV TERM xterm

RUN apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
			build-essential \
    	libpq-dev \
			file \
    	git \
    	nodejs \
    	imagemagick \
    	curl \
			libxrender1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock
COPY ./config/docker/gemrc  /root/.gemrc

RUN gem install bundler
RUN bundle install --jobs 20 --retry 3

ADD . $APP_HOME

CMD ./cmd.sh

EXPOSE 3000
