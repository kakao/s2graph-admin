FROM ruby:2.2

ENV APP_HOME    /usr/src/app
ENV CONFIG_HOME ""
ENV DB_SETUP "no"

RUN apt-get update
RUN apt-get install -y rails zlib1g-dev libmysqlclient-dev
#RUN mkdir -p $APP_HOME
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 3000

RUN chmod 755 entrypoint.sh
CMD ["bash", "./entrypoint.sh"]
