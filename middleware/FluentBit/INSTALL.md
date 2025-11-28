### INSTALL Fluent Bit

1. [Fluent Bit github](https://github.com/fluent/fluent-bit)
2. [website](https://fluentbit.io/)
3. [install doc](https://docs.fluentbit.io/manual/installation/downloads/linux/ubuntu)

### INSTALL Fluentd
```bash
sudo sh -c 'curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg'

codename=$(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release 2>/dev/null || lsb_release -cs 2>/dev/null)

echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/ubuntu/$codename $codename main" | sudo tee /etc/apt/sources.list.d/fluent-bit.list

sudo apt-get update

sudo apt-get install fluent-bit -y
```

### START Fluentd
```bash
sudo systemctl start fluent-bit
sudo systemctl status fluent-bit
```