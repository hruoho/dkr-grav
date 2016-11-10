# Usage

## Basics
This image builds on top of phusion/baseimage. It uses supervisord to run nginx & php-fpm.

Use this image as a base for developing a Grav-based website. Each container
has a fresh Grav-install so you can develop your sites containerwise.

### Build

    docker build -t gravcms .

### Run

    docker run -v /path/to/grav:/usr/share/nginx/html gravcms

or

    docker run -e "SUB=subfoldr" -v /path/to/grav:/usr/share/nginx/html/subfoldr gravcms

### Compose

  version: '2'

  services:
  
    mygrav:
      image: gravcms
      volumes:
        - /path/to/mygrav:/usr/share/nginx/html

    subgrav:
      image: gravcms
      volumes:
        - /path/to/subgrav:/usr/share/nginx/html/subgrav
      environment:
        SUB: subgrav
