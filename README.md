
To test locally:

```bash
docker build -t nietaki/opustinator --load .
docker run -it -v './input':'/input':'rw' -v './output':'/output':'rw' nietaki/opustinator
```


To push to registry:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --tag registry.hoplon.net/nietaki/opustinator:latest --push .
```
