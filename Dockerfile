# Use the latest version of Ruby (onbuild variant) available.
FROM ruby:alpine

# That's me!
MAINTAINER Kristofer Rye <kristofer.rye@gmail.com>

# Add the current directory, containing everything, to /krye.io in the image.
ADD . /krye.io/

# Set the working directory to our project root.
WORKDIR /krye.io

# Update and install build-essential packages.
RUN apk add --no-cache g++ musl-dev make nodejs git

# Install app dependencies.
RUN bundle install

# Print out the git status for diagnostic purposes.
RUN git status

# Fetch the tags and do the things?
RUN git fetch origin --unshallow --tags; \
    git describe --tags --dirty || exit 0

# Expose port 80 from the internal server.
EXPOSE 80

# Run the default command, binding to 0.0.0.0, or localhost.
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "80"]
