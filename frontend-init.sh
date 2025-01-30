# frontend-init.sh
#!/bin/bash
set -e

# System updates
apt-get update
apt-get upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx

# Create application directory
mkdir -p /opt/mam-frontend

# Setup Nginx
cat > /etc/nginx/sites-available/mam-frontend << EOF
server {
    listen 80;
    server_name _;
    root /opt/mam-frontend/build;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass ${backend_url};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

ln -s /etc/nginx/sites-available/mam-frontend /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Install PM2
npm install -g pm2