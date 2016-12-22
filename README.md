# krye.io [![Dependency Status](https://gemnasium.com/badges/github.com/rye/krye.io.svg)](https://gemnasium.com/github.com/rye/krye.io)

This is the code that powers [krye.io][krye.io], my personal website.
It is a proof-of-concept project involving a great amount of work
towards caching things and making it much lighter-weight.

## Setup

This project has a Docker image at [`kryestofer/krye.io`](https://hub.docker.com/r/kryestofer/krye.io/).

Otherwise, simply run the following commands to set it up on your machine (with Ruby installed):

```sh
$ bundle install
$ bundle exec rackup -p <port>
```

[krye.io]: https://krye.io