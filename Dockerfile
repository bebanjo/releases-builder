FROM ruby:2.4.1

RUN apt-get update && apt-get install -y
RUN apt-get -y install curl libcurl3 libcurl3-gnutls libcurl4-openssl-dev

ENV APP_HOME /app
ENV HOME /root

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/

RUN gem update --system
RUN gem install bundler
RUN bundle install

COPY . $APP_HOME

CMD ["foreman", "start"]
