### avahi-daemon (mDns)


```bash
sudo apt install avahi-daemon

# Set hostname
echo "openclaw" | sudo tee /etc/hostname

sudo hostnamectl set-hostname openclaw
sudo mkdir -p /etc/avahi/services

sudo tee /etc/avahi/services/openclaw-setup.service << 'EOF'
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name>OpenClaw Setup</name>
  <service>
    <type>_http._tcp</type>
    <port>8080</port>
    <txt-record>path=/</txt-record>
  </service>
</service-group>
EOF

sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon

sudo systemctl restart avahi-daemon
```