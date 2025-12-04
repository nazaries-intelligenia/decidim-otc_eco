ARG RUBY_VERSION=3.3.4
ARG NODE_VERSION=18
ARG BUNDLER_VERSION=2.4.20

FROM ruby:${RUBY_VERSION}

ENV DEBIAN_FRONTEND noninteractive ENV NODE_MAJOR=18

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    build-essential \
    imagemagick \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Install node
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ARG NODE_VERSION
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create workdir
RUN mkdir /app
WORKDIR /app

## Install gems and add app
COPY Gemfile Gemfile.lock /app/
ARG BUNDLER_VERSION
RUN gem install bundler:${BUNDLER_VERSION}
RUN bundle install
COPY . /app

# Compile assets
RUN npm i -g yarn
RUN npm ci
RUN bundle exec rake assets:precompile

# Entrypoint
COPY docker/entrypoint.sh /entrypoint
RUN chmod 755 /entrypoint
ENTRYPOINT [ "/entrypoint" ]
