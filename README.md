# proxy
A docker container to expose another service behind a HTTPs reverse proxy.

# Usage
```
docker build -t eliott/proxy .
docker run -p 443:8443 -p 80:8080 -v /path/to/cache:./certs -it eliott/proxy target.com currentdomain.com
```

A prebuilt docker image is [available](https://hub.docker.com/r/eteissonniere/tls-proxy).
