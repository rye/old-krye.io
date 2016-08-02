# Use the latest version of Ruby (onbuild variant) available
FROM ruby:onbuild

# That's me!
MAINTAINER Kristofer Rye

# Add the current directory, containing everything, to /krye.io in the image.
ADD . /krye.io/

WORKDIR /krye.io

# Update and install build-essential packages
RUN apt-get update \
  && curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
  && apt-get update \
  && apt-get install -y nodejs

# Clean up
RUN rm -rfv /var/lib/apt/lists/*

# Install app dependencies
RUN bundle install

EXPOSE 80

CMD bundle exec rackup -o 0.0.0.0 -p 80
