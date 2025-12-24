```bash
sudo docker build -t 192.168.1.100:5000/cuda/comfyui:v0.0.1 .

sudo docker login -u admin 192.168.1.100:5000

sudo docker push 192.168.1.100:5000/cuda/comfyui:v0.0.1
```