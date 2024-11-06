#!/bin/bash

# 사용자 및 그룹 생성 (root 권한 필요)
sudo groupadd --system exporter_group
sudo useradd --system --no-create-home --shell /usr/sbin/nologin -g exporter_group exporter_user

# 필요한 디렉토리 생성 및 파일 이동
sudo mkdir -p /etc/exporters

# Exporters 다운로드
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.14.0/mysqld_exporter-0.14.0.linux-amd64.tar.gz
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.11.0/apache_exporter-0.11.0.linux-amd64.tar.gz

# Exporters 압축 해제
tar xf mysqld_exporter-0.14.0.linux-amd64.tar.gz
tar xf node_exporter-1.3.1.linux-amd64.tar.gz
tar xf apache_exporter-0.11.0.linux-amd64.tar.gz

# 압축 파일 삭제
rm -f *.tar.gz

# 디렉토리 이동
sudo mv mysqld_exporter-0.14.0.linux-amd64 /etc/exporters/mysqld_exporter
sudo mv node_exporter-1.3.1.linux-amd64 /etc/exporters/node_exporter
sudo mv apache_exporter-0.11.0.linux-amd64 /etc/exporters/apache_exporter

# 소유권 변경
sudo chown -R exporter_user:exporter_group /etc/exporters

# Node Exporter 서비스 등록
sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=exporter_user
Group=exporter_group
ExecStart=/etc/exporters/node_exporter/node_exporter

[Install]
WantedBy=default.target
EOF'

# Apache Exporter 서비스 등록
sudo bash -c 'cat <<EOF > /etc/systemd/system/apache_exporter.service
[Unit]
Description=Prometheus Apache Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=exporter_user
Group=exporter_group
ExecStart=/etc/exporters/apache_exporter/apache_exporter

[Install]
WantedBy=default.target
EOF'

# systemd 데몬 리로드 및 Exporters 시작
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl start apache_exporter.service
