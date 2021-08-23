# based on https://betterprogramming.pub/rails-6-development-with-docker-55437314a1ad

FROM ruby:3.0.0-alpine

ENV APP_PATH /var/app
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000

# install dependencies for application
RUN apk -U add --no-cache \
build-base \
git \
postgresql-dev \
postgresql-client \
libxml2-dev \
libxslt-dev \
nodejs \
yarn \
imagemagick \
tzdata \
less \
bash \
&& rm -rf /var/cache/apk/* \
&& mkdir -p $APP_PATH

# navigate to app directory
WORKDIR $APP_PATH

EXPOSE $RAILS_PORT
