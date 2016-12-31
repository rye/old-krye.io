# krye.io [![Dependency Status](https://gemnasium.com/badges/github.com/rye/krye.io.svg)][dep] [![Code Climate](https://codeclimate.com/github/rye/krye.io/badges/gpa.svg)][cc] [![Test Coverage](https://codeclimate.com/github/rye/krye.io/badges/coverage.svg)][cc-c]

This is the code that powers [krye.io][krye.io], my personal website.
It is a proof-of-concept project involving a great amount of work
towards caching things and making it much lighter-weight.

## Goals

Caching responses to requests is a big goal of this project.
Currently, we simply build files statically and store them in a cache,
but it would be nice to cache requests whilst still maintaining
support for dynamic pages.

In the future, we will probably move from caching to more of a direct
build-on-page-request type deal.  We can always use caching in Nginx
or whatever is used as a load balancer.

## Known Issues

* This server still has an enormous footprint.  Despite being all
  in-memory and using `redis` as a primary storage backend, the system
  is still storing many things in-memory.  An in-depth look will be
  required to take care of this.

## Setup

This project has a Docker image at
[`kryestofer/krye.io`](https://hub.docker.com/r/kryestofer/krye.io/).

Otherwise, simply run the following commands to set it up on your
machine (with Ruby installed):

```sh
$ bundle install
$ bundle exec rackup -p <port>
```

[krye.io]: https://krye.io
[dep]: https://gemnasium.com/github.com/rye/krye.io
[cc]: https://codeclimate.com/github/rye/krye.io
[cc-c]: https://codeclimate.com/github/rye/krye.io/coverage
