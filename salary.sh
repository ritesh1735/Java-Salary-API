

sudo apt update
sudo apt install openjdk-17-jre -y
wget https://dlcdn.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz
tar -xvzf apache-maven-3.9.4-bin.tar.gz
sudo mv apache-maven-3.9.4 /opt/
echo 'M2_HOME="/opt/apache-maven-3.9.4"' >> ~/.profile
echo 'PATH="$M2_HOME/bin:$PATH"' >> ~/.profile
echo 'export PATH' >> ~/.profile
source .profile 
sudo apt update && sudo apt install make -y
sudo apt-get update
sudo apt-get install -y openjdk-8-jre-headless
sudo update-java-alternatives --jre-headless -s java-1.8.0-openjdk-amd64
sudo apt install jq -y
wget https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz
tar -xvzf migrate.linux-amd64.tar.gz 
sudo mv migrate /usr/bin/
git clone https://github.com/OT-MICROSERVICES/salary-api.git
echo '{
  "database": "cassandra://172.17.0.3:9042/employee_db?username=scylladb&password=password"
}' > /home/ubuntu/salary-api/migration.json
echo 'spring:
  cassandra:
    keyspace-name: employee_db
    contact-points: 172.17.0.3
    port: 9042
    username: scylladb
    password: password
    local-datacenter: datacenter1
  data:
    redis:
      host: 172.17.0.4
      port: 6379
      password: password

management:
  endpoints:
    web:
      base-path: /actuator
      exposure:
        include: [ "health", "prometheus", "metrics" ]
  health:
    cassandra:
      enabled: true
  endpoint:
    health:
      show-details: always
    metrics:
      enabled: true
    prometheus:
      enabled: true

logging:
  level:
    org.springframework.web: DEBUG

springdoc:
  swagger-ui:
    path: /salary-documentation
    tryItOutEnabled: true
    filter: true
  api-docs:
    path: /salary-api-docs
  show-actuator: true' | sudo tee /home/ubuntu/salary-api/src/main/resources/application.yml
mvn clean package -DskipTests 
echo '#!/bin/bash

java -jar target/salary-0.1.0-RELEASE.jar' | tee /home/ubuntu/salary-api/start.sh
echo "[Unit]
Description=Salary API Service
After=network.target

[Service]
ExecStart=/home/ubuntu/salary-api/start.sh
WorkingDirectory=/home/ubuntu/salary-api
User=ubuntu
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/salary-api.service
sudo systemctl daemon-reload
sudo systemctl start salary-api
sudo systemctl enable salary-api
sudo systemctl status salary-api
sudo systemctl restart salary-api
