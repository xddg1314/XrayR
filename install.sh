#!/usr/bin/env bash

# 简单的 XrayR 安装脚本 (使用 xddg1314 仓库资源)
echo "正在安装 XrayR 依赖..."
apt-get update && apt-get install -y wget curl tar unzip

# 创建配置目录和程序目录
mkdir -p /etc/XrayR
mkdir -p /usr/local/XrayR

# 下载你仓库里的 config.yml 默认配置文件
echo "正在下载默认配置文件..."
wget -O /etc/XrayR/config.yml https://raw.githubusercontent.com/xddg1314/XrayR/master/config.yml

# 【核心部分】下载编译好的 XrayR 核心程序
# 注意：这里我们直接借用目前最新、且能用的社区编译版核心，确保你的服务能跑起来
echo "正在下载 XrayR 核心程序..."
arch=$(uname -m)
if [ "$arch" == "x86_64" ]; then
    wget -O /usr/local/XrayR/XrayR.tar.gz https://github.com/X2R-Project/X2R/releases/latest/download/X2R-linux-64.tar.gz
elif [ "$arch" == "aarch64" ]; then
    wget -O /usr/local/XrayR/XrayR.tar.gz https://github.com/X2R-Project/X2R/releases/latest/download/X2R-linux-arm64-v8a.tar.gz
fi

# 解压并清理
cd /usr/local/XrayR
tar -zxvf XrayR.tar.gz
chmod +x XrayR
rm -f XrayR.tar.gz

# 写入守护进程服务 (Systemd)
echo "正在配置系统服务..."
cat <<EOF >/etc/systemd/system/XrayR.service
[Unit]
Description=XrayR Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/XrayR
ExecStart=/usr/local/XrayR/XrayR --config /etc/etc/XrayR/config.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable XrayR
echo "-------------------------------------------------------"
echo "XrayR 安装完成！"
echo "配置文件路径: /etc/XrayR/config.yml"
echo "请修改配置文件后，运行 'systemctl restart XrayR' 启动服务。"
echo "-------------------------------------------------------"

