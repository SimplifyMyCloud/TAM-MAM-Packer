# backend-init.sh
#!/bin/bash
set -e

# System updates
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y postgresql-client redis-tools ffmpeg golang-1.20 nginx

# Create application user
useradd -m -s /bin/bash mam

# Create application directories
mkdir -p /opt/mam
mkdir -p /var/lib/mam/{media,temp}
chown -R mam:mam /opt/mam /var/lib/mam

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Setup application
cat > /opt/mam/config.yaml << EOF
database:
  host: ${db_host}
  name: ${db_name}
  user: ${db_user}
  password: ${db_password}

redis:
  host: ${redis_host}
  port: 6379

storage:
  path: /var/lib/mam/media
  temp_path: /var/lib/mam/temp
EOF

# Create systemd service
cat > /etc/systemd/system/mam.service << EOF
[Unit]
Description=MAM Backend Service
After=network.target

[Service]
Type=simple
User=mam
WorkingDirectory=/opt/mam
ExecStart=/opt/mam/mam-backend
Restart=always
Environment=MAM_CONFIG=/opt/mam/config.yaml

[Install]
WantedBy=multi-user.target
EOF
