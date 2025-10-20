FROM ruby:3.2.0-alpine

# Install dependencies
RUN apk add --update --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    git \
    nodejs \
    npm

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
