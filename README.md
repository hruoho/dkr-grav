# What?
A docker image to set up basic nginx & php services for [Grav](https://getgrav.org). Builds on top of phusion/baseimage and uses supervisord to run nginx & php-fpm.

## Usage
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
