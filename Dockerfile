# Use the latest version of Ruby (onbuild variant) available
FROM ruby:onbuild

# That's me!
MAINTAINER kristofer.rye@gmail.com

# Add the current directory, containing everything, to /krye.io in the image.
ADD . /krye.io/

WORKDIR /krye.io

# Update and install build-essential packages
RUN apt-get update && apt-get install -y build-essential

# Install PostgreSQL libraries
RUN apt-get install -y libpq-dev

# Install dependencies for Nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# Install any dependencies for Node
RUN apt-get install -y python python-dev python-pip python-virtualenv

# Clean up
RUN rm -rfv /var/lib/apt/lists/*

# Install Node
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -fv node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rfv /tmp/node-v*

#RUN \
#  cd /tmp && \
#  wget http://nodejs.org/dist/node-latest.tar.gz && \
#  tar xvzf node-latest.tar.gz && \
#  rm -f node-latest.tar.gz && \
#  cd node-v* && \
#  ./configure && \
#  CXX="g++ -Wno-unused-local-typedefs" make && \
#  CXX="g++ -Wno-unused-local-typedefs" make install && \
#  cd /tmp && \
#  rm -rf /tmp/node-v* && \
#  npm install -g npm && \
#  echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

RUN gem install bundler

RUN bundle install

EXPOSE 80

CMD bundle exec rackup -o 0.0.0.0 -p 80
