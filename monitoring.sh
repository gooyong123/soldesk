#!/bin/bash

# Prometheus 설치
wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
tar xf prometheus-2.37.0.linux-amd64.tar.gz

# Prometheus 디렉토리 생성 및 파일 이동
mkdir -p /etc/prometheus
cd prometheus-2.37.0.linux-amd64
mv prometheus console_libraries prometheus.yml consoles /etc/prometheus

# Prometheus 유저 및 그룹 생성
groupadd --system prometheus
useradd --system -s /usr/sbin/nologin -g prometheus prometheus

# 디렉토리 소유권 변경
chown prometheus:prometheus /etc/prometheus -R

# /var/lib/prometheus 디렉토리 생성 및 소유권 변경
mkdir -p /var/lib/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Prometheus systemd 서비스 파일 생성
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Restart=on-failure
ExecStart=/etc/prometheus/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/var/lib/prometheus \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries \\
    --web.listen-address=0.0.0.0:9090 \\
    --web.external-url=

[Install]
WantedBy=multi-user.target
EOF

# systemd 데몬 리로드 및 Prometheus 시작
systemctl daemon-reload
systemctl start prometheus.service
systemctl enable prometheus.service

# Grafana 설치
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.2.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-10.2.2.linux-amd64.tar.gz

# Grafana 디렉토리 생성 및 파일 이동
mkdir -p /etc/grafana
mv grafana-v10.2.2/* /etc/grafana

# Grafana 유저 및 그룹 생성
groupadd --system grafana
useradd --system -s /usr/sbin/nologin -g grafana grafana

# Grafana 디렉토리 소유권 변경
chown grafana:grafana /etc/grafana -R

# Grafana systemd 서비스 파일 생성
cat <<EOF > /etc/systemd/system/grafana-server.service
[Unit]
Description=Grafana Enterprise Server
After=network.target

[Service]
ExecStart=/etc/grafana/bin/grafana-server
WorkingDirectory=/etc/grafana
User=grafana
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# systemd 데몬 리로드 및 Grafana 시작
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server
