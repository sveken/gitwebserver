# gitwebserver
A small  lighthttp webserver that auto pulls a website from a git repo and serves it. 
It will then pull down any updates from the repository every hour by default. This setting can be changed.

There are three version in both AMD64 and arm7/arm64, debian with lighthttpd at 170MB, alpine at 21.9MB with lighthttpd and a alpine with caddy version with auto SSL at 60MB.
Variables are 

```GIT_REPO``` which points to your repository. 

```UPDATE_TIMER``` which is how often in seconds it will check for updates. 

```GIT_PAT``` Which when set will be used to authenticate against private repos.

 ```DOMAIN``` Used in the caddy version for auto SSL. It is the domain of your website


## Example Compose file with alpine and lighthttpd
```
services:
  gitweb:
    environment:
      GIT_REPO: # The Public Git Repo here.
      UPDATE_TIMER: 3600 # in seconds git will update the web files (default 3600) which is an hour. 
    image: ghcr.io/sveken/gitwebserver-alpine:latest
    ports:
      - "8080:8080"
    restart: always
```


## Docker Run Example

```
docker run -d \
  -e GIT_REPO="https://your-public-repo.git" \
  -e UPDATE_TIMER=3600 \
  -p 8080:8080 \
  --restart always \
  ghcr.io/sveken/gitwebserver-alpine:latest
```

## Example Caddy Compose file using a private repo
``` 
services:
  gitweb:
    environment:
      GIT_REPO: https://github.com/username/website
      UPDATE_TIMER: 3600 # in seconds git will update the web files (default 3600) which is an hour. 
      DOMAIN: mydomain.com
      GIT_PAT: github_pat_xxx
    image: ghcr.io/sveken/gitwebserver-caddy:latest
    ports:
      - "443:443"
      - "80:80"
    restart: always
    ```