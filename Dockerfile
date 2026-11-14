FROM ruby:3.3.13-slim
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev libyaml-dev git curl pkg-config \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV RAILS_ENV=development BUNDLE_JOBS=4 BUNDLE_RETRY=3
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN chmod +x bin/*
EXPOSE 3000
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
