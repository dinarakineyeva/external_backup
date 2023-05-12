#!/bin/bash

# Install MongoDB tools and dependencies
sudo apt-get update
sudo apt-get install -y mongo-tools

# Download and install mongosh
wget https://downloads.mongodb.com/compass/mongosh-1.8.0-linux-x64.tgz
tar -xvzf mongosh-1.8.0-linux-x64.tgz
sudo mv mongosh-1.8.0-linux-x64/bin/mongosh /usr/local/bin/

# Set environment variables
export PATH=$PATH:/usr/local/bin

# Create the backup script
echo '#!/bin/bash
# Retrieve credentials from metadata server
curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/cred > /tmp/cred.json

# Backup the MongoDB database to a file
mongodump --uri mongodb+srv://user:user@test-cluster-m.wzw1h.mongodb.net/database --archive | gzip > /tmp/backuper.gz

# Authenticate with Google Cloud and upload the backup file to a bucket
gcloud auth activate-service-account --key-file /tmp/cred.json
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/cred.json
gsutil cp /tmp/backuper.gz gs://mongo-crypt-bucket/
' > /home/backup.sh

# Make the backup script executable
chmod +x /home/backup.sh
echo 'hi'
echo '[Unit]
Description=MongoDB backup service

[Service]
ExecStart=/bin/bash /home/backup.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/mongo-backup.service
echo '[Unit]
Description=Run backup every minute

[Timer]
OnUnitActiveSec=1min
Unit=mongo-backup.service

[Install]
WantedBy=timers.target
' > /etc/systemd/system/backup.timer

sudo systemctl daemon-reload
sudo systemctl enable mongo-backup.service
sudo systemctl start mongo-backup.service

sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
