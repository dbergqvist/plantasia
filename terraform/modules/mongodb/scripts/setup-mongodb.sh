#!/bin/bash

# Update system and install MongoDB
apt-get update
apt-get install -y gnupg curl
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] http://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt-get update
apt-get install -y mongodb-org awscli

# Configure MongoDB for authentication and remote access
cat << EOF > /etc/mongod.conf
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 0.0.0.0

security:
  authorization: enabled
EOF

# Start MongoDB
systemctl start mongod
systemctl enable mongod

# Wait for MongoDB to start
sleep 10

# Create admin user
mongosh admin --eval '
  db.createUser({
    user: "${mongodb_username}",
    pwd: "${mongodb_password}",
    roles: [ { role: "root", db: "admin" } ]
  });
'

# Create application database and user
mongosh admin -u "${mongodb_username}" -p "${mongodb_password}" --eval '
  use ${database_name};
  db.createUser({
    user: "${mongodb_username}",
    pwd: "${mongodb_password}",
    roles: [ { role: "dbOwner", db: "${database_name}" } ]
  });
'

# Setup backup script
cat << EOF > /usr/local/bin/backup-mongodb.sh
#!/bin/bash
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
mongodump --username "${mongodb_username}" --password "${mongodb_password}" --out /tmp/backup
tar czf /tmp/backup_\$TIMESTAMP.tar.gz -C /tmp backup
aws s3 cp /tmp/backup_\$TIMESTAMP.tar.gz s3://${s3_bucket}/
rm -rf /tmp/backup /tmp/backup_\$TIMESTAMP.tar.gz
EOF

chmod +x /usr/local/bin/backup-mongodb.sh

# Add to crontab (daily backup at 2 AM)
echo "0 2 * * * /usr/local/bin/backup-mongodb.sh" | crontab -