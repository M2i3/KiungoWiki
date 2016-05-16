FROM ruby:2.0.0-p645
ENV LANG C.UTF-8
RUN apt-get update && apt-get install -y libqt4-dev 

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

RUN apt-get update && apt-get install -y mdbtools

COPY . /usr/src/app

CMD ["/bin/bash"]
