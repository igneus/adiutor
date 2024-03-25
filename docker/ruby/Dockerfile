# based on https://betterprogramming.pub/rails-6-development-with-docker-55437314a1ad

FROM ruby:3.3.0-alpine

ENV APP_PATH /var/app/rails_app
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
mariadb-dev \
mariadb-client \
libxml2-dev \
libxslt-dev \
nodejs \
yarn \
imagemagick \
tzdata \
less \
bash \
python3 \
python3-dev \
py3-pip \
py3-wheel \
jpeg-dev \
zlib-dev \
tiff-dev \
freetype-dev \
&& rm -rf /var/cache/apk/* \
&& mkdir -p $APP_PATH

# Python: remove the "externally managed environment" (PEP 668) marker file
# in order to allow `pip install`
RUN rm $(echo 'import sysconfig; print(sysconfig.get_path("stdlib", sysconfig.get_default_scheme()))' | python)/EXTERNALLY-MANAGED

# navigate to app directory
WORKDIR $APP_PATH

EXPOSE $RAILS_PORT

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
