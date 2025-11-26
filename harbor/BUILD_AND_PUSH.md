### build and push

1. build image
```bash
# sudo docker build -t 192.168.1.27:8090/test/config-service:v0.0.1
docker build -t <username>/<image_name>:<tag> .
```

2. login registry
```bash
sudo docker login -u <username> -p <password> <registry_url>
```

3. push image
```bash
# sudo docker push 192.168.1.27:8090/test/config-service:v0.0.1
docker push <image_name>:<tag>
```

1. pull image
```bash
docker pull <image_name>:<tag>
```