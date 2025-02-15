# gitwebserver
A small  lighthttp webserver that auto pulls a website from a git repo and serves it. 
It will then pull down any updates from the repository every hour by default. This setting can be changed.

There are two version, debian at 170MB and alpine at 24.3MB.
Variables are ```GIT_REPO``` which points to your repository, and ```UPDATE_TIMER``` which is how often in seconds it will check for updates.

To use a private repo, you can generate a fine grain access token or PAT on github and enter the url as ```https://<gitTokenhere>@your_repo_URL_without_https``` for example the URL would be ```https://github_pat_xxxgdfxxxx@github.com/user/repo```

## Example Compose file
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