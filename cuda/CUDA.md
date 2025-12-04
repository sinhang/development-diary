### CUDA

### 查看CUDA版本
```bash
nvidia-smi

# 输出
nvidia-smi
Thu Dec  4 10:39:11 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.95.05              Driver Version: 580.95.05      CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4060 Ti     Off |   00000000:02:00.0  On |                  N/A |
|  0%   42C    P8             15W /  165W |    1525MiB /  16380MiB |     15%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A           28805      G   /usr/lib/xorg/Xorg                      827MiB |
|    0   N/A  N/A           29327      G   /usr/bin/gnome-shell                     49MiB |
|    0   N/A  N/A           29605      G   .../sunloginclient --cmd=autorun          9MiB |
|    0   N/A  N/A           30154      G   ...l/sunlogin/bin/sunloginclient          2MiB |
|    0   N/A  N/A           30285      G   ...0D528D63156D3784BB941ADC1C095          2MiB |
|    0   N/A  N/A           31921      G   /usr/bin/nautilus                        16MiB |
|    0   N/A  N/A           36045      G   ...ersion=20251201-110412.186000         90MiB |
|    0   N/A  N/A           56867      G   ...ess --variations-seed-version          3MiB |
|    0   N/A  N/A           77894      G   ...OTP --variations-seed-version         29MiB |
|    0   N/A  N/A          112797      G   ...ase\CloudMusic\cloudmusic.exe          2MiB |
|    0   N/A  N/A          112957      G   ...ase\CloudMusic\cloudmusic.exe         98MiB |
|    0   N/A  N/A          139769      G   ...ess --variations-seed-version          9MiB |
|    0   N/A  N/A          215548      G   /usr/bin/gnome-system-monitor            10MiB |
|    0   N/A  N/A          280132      G   ...ess --variations-seed-version        111MiB |
|    0   N/A  N/A          359046      G   /proc/self/exe                           93MiB |
+-----------------------------------------------------------------------------------------+
```