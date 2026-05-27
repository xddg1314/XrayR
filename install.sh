#!/usr/bin/env bash

# xddg1314 专属 XrayR v0.9.4 经典菜单一键安装与管理脚本

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 检查 root 权限
[[ $EUID -ne 0 ]] && echo -e "${red}错误：${plain} 必须使用 root 用户运行此脚本！\n" && exit 1

# 安装与配置核心函数
install_xrayr() {
    echo -e "${green}正在安装基础依赖环境...${plain}"
    apt-get update && apt-get install -y wget curl unzip nano

    mkdir -p /etc/XrayR
    mkdir -p /usr/local/XrayR

    echo -e "${green}正在下载你仓库中的默认配置文件...${plain}"
    wget -O /etc/XrayR/config.yml https://raw.githubusercontent.com/xddg1314/XrayR/master/config.yml

    # 【核心下载】精准下载你刚刚上传到自己 Release 里的安装包
    echo -e "${green}正在从你的 Release 下载 XrayR-linux-64.zip...${plain}"
    wget -O /usr/local/XrayR/XrayR.zip https://github.com/xddg1314/XrayR/releases/download/v0.9.4/XrayR-linux-64.zip

    echo -e "${green}正在解压并配置权限...${plain}"
    cd /usr/local/XrayR
    unzip -o XrayR.zip
    chmod +x XrayR
    rm -f XrayR.zip

    # 写入系统守护服务
    cat <<EOF >/etc/systemd/system/XrayR.service
[Unit]
Description=XrayR Service by xddg1314
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/XrayR
ExecStart=/usr/local/XrayR/XrayR --config /etc/XrayR/config.yml
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable XrayR

    # 【核心注入】把当前管理脚本下载到服务器，让你以后敲 xrayr 就能直接唤醒菜单
    wget -O /usr/bin/xrayr https://raw.githubusercontent.com/xddg1314/XrayR/master/install.sh
    chmod +x /usr/bin/xrayr

    echo -e "${green}=================================================${plain}"
    echo -e "${green}🎉 XrayR 安装完成，快捷管理命令: xrayr ${plain}"
    echo -e "${green}📄 配置文件路径: /etc/XrayR/config.yml ${plain}"
    echo -e "${green}=================================================${plain}"
}

# 卸载函数
uninstall_xrayr() {
    systemctl stop XrayR
    systemctl disable XrayR
    rm -f /etc/systemd/system/XrayR.service
    systemctl daemon-reload
    rm -rf /usr/local/XrayR
    rm -rf /etc/XrayR
    rm -f /usr/bin/xrayr
    echo -e "${green}XrayR 卸载成功！${plain}"
}

# 获取状态
get_status() {
    if systemctl is-active XrayR &>/dev/null; then
        status_text="${green}已运行${plain}"
    else
        status_text="${red}未运行${plain}"
    fi
    if systemctl is-enabled XrayR &>/dev/null; then
        enable_text="${green}是${plain}"
    else
        enable_text="${red}否${plain}"
    fi
}

# 唤醒经典管理菜单
show_menu() {
    clear
    get_status
    echo -e "  ${green}XrayR 后端管理脚本，不适用于docker${plain}"
    echo -e "--- https://github.com/xddg1314/XrayR ---"
    echo -e "  ${green}0.${plain} 修改配置"
    echo -e "------------------------"
    echo -e "  ${green}1.${plain} 安装 XrayR"
    echo -e "  ${green}2.${plain} 更新 XrayR"
    echo -e "  ${green}3.${plain} 卸载 XrayR"
    echo -e "------------------------"
    echo -e "  ${green}4.${plain} 启动 XrayR"
    echo -e "  ${green}5.${plain} 停止 XrayR"
    echo -e "  ${green}6.${plain} 重启 XrayR"
    echo -e "  ${green}7.${plain} 查看 XrayR 状态"
    echo -e "  ${green}8.${plain} 查看 XrayR 日志"
    echo -e "------------------------"
    echo -e "  ${green}9.${plain} 设置 XrayR 开机自启"
    echo -e " ${green}10.${plain} 取消 XrayR 开机自启"
    echo -e "------------------------"
    echo -e " ${green}11.${plain} 一键安装 bbr (最新内核)"
    echo -e " ${green}12.${plain} 查看 XrayR 版本"
    echo -e " ${green}13.${plain} 升级维护脚本"
    echo -e ""
    echo -e "XrayR状态: $status_text"
    echo -e "是否开机自启: $enable_text"
    echo -e ""
    read -p "请输入选择 [0-13]: " num
    case "$num" in
        0) nano /etc/XrayR/config.yml ;;
        1) install_xrayr ;;
        2) install_xrayr ;;
        3) uninstall_xrayr ;;
        4) systemctl start XrayR && echo -e "${green}启动成功${plain}" ;;
        5) systemctl stop XrayR && echo -e "${green}停止成功${plain}" ;;
        6) systemctl restart XrayR && echo -e "${green}重启成功${plain}" ;;
        7) systemctl status XrayR ;;
        8) journalctl -u XrayR --no-pager -n 50 ;;
        9) systemctl enable XrayR && echo -e "${green}设置开机自启成功${plain}" ;;
        10) systemctl disable XrayR && echo -e "${green}取消开机自启成功${plain}" ;;
        11) bash <(curl -L -s https://raw.githubusercontent.com/teddysun/across/master/bbr.sh) ;;
        12) /usr/local/XrayR/XrayR --version ;;
        13) wget -O /usr/bin/xrayr https://raw.githubusercontent.com/xddg1314/XrayR/master/install.sh && chmod +x /usr/bin/xrayr && echo -e "${green}脚本升级成功${plain}" ;;
        *) echo -e "${red}请输入正确的数字 [0-13]${plain}" ;;
    esac
}

# 判断是初次一键下载执行，还是后续直接输入 xrayr 运行
if [[ "$0" == *install.sh ]]; then
    install_xrayr
else
    show_menu
fi
