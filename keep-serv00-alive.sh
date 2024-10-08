#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # 没有颜色

echo -e "${GREEN}Serv00 Socks5/NeZha Agent 保活脚本${NC}"
echo ""
echo -e "${GREEN}该脚本是由 hkfires/Keep-Serv00-Alive 的二次开发的${NC}"
echo -e "${GREEN}我们深知开源社区的繁荣离不开每一位贡献者的辛勤付出和智慧结晶。${NC}"
echo -e "${GREEN}作为原项目的二次开发者，我们郑重声明：我们尊重原作者，因此保留原作者信息。${NC}"
echo ""

# 提示确保服务是否正在运行
echo -e "${RED}请确保 Socks5/NeZha Agent 正在运行，否则保活可能运行失败。如果重新运行此脚本将会删除原有配置信息！${NC}"

# 输入 Serv00 网站域名
read -p "请输入您在 Serv00 设置的网站域名: " serv00_domain
if [ -z "$serv00_domain" ]; then
    echo -e "${RED}域名不能为空，请重试。${NC}"
    exit 1
fi

# app.js 文件
cd ~/domains/${serv00_domain}/public_nodejs/ || { echo -e "${RED}目录不存在，请检查域名。${NC}"; exit 1; }
echo "删除原配置文件"
rm -rf app.js
echo "将静态默认修改为动态默认"
mv public static
echo "安装npm express"
npm22 install express
echo "下载保活文件"
wget https://raw.githubusercontent.com/ZedWAre-NEOFTT/Keep-Serv00-Alive/refs/heads/main/app.js
    
# 设置 Socks5 保活
read -p "是否设置 Socks5 保活？[y/N] " setup_socks5
if [[ "$setup_socks5" =~ ^[Yy]$ ]]; then

    # 输入 Serv00 登陆用户名
    read -p "请输入您的 Serv00 登陆用户名: " serv00_user
    if [ -z "$serv00_user" ]; then
        echo -e "${RED}用户名不能为空，请重试。${NC}"
        exit 1
    fi
    
    # 处理特殊字符转义
    serv00_user_escaped=$(echo "${serv00_user}" | sed 's/[&/\]/\\&/g')

    # 修改 app.js 文件中的第7行，将 SERV00_USERNAME 修改为输入的用户名
    sed -i '' "7s/SERV00_USERNAME/${serv00_user_escaped}/" app.js
    echo -e "${GREEN}Socks5 保活设置完成。${NC}"
else
    echo -e "${RED}跳过 Socks5 保活设置。${NC}"
fi

# 设置 NeZha Agent 保活
read -p "是否设置 NeZha Agent 保活？[y/N] " setup_nezha
if [[ "$setup_nezha" =~ ^[Yy]$ ]]; then
    echo "NeZha Agent 建议直接填入 IP 而不是解析了Agent的域名，否则 Serv00 可能会把你的域名解析到127.0.0.11"
    echo "这就是为什么面板没有任何反应的原因 (不排除其他设置问题)"
    echo -e "如何查看我的域名有没有被 Serv00 解析到本地？输入${GREEN}cat /etc/hosts | grep '127.0.0.11'${NC}"
    read -p "请输入您的 NeZha Agent 对端，格式为 IP:Port: " nezha_endpoint
    read -p "请输入您的 NeZha Agent 对端密钥: " nezha_key
    if [ -z "$nezha_endpoint" ] || [ -z "$nezha_key" ]; then
        echo -e "${RED}NeZha Agent 对端或密钥不能为空，请重试。${NC}"
        exit 1
    fi
    
    # 处理特殊字符转义
    nezha_endpoint_escaped=$(echo "${nezha_endpoint}" | sed 's/[&/\]/\\&/g')
    nezha_key_escaped=$(echo "${nezha_key}" | sed 's/[&/\]/\\&/g')
    
    # 修改 app.js 文件中的第8，9行，将 NEZHA_AGENT 和 NEZHA_AGENT_PASSWORD 替换为输入的值
    sed -i '' "8s/NEZHA_AGENT/${nezha_endpoint_escaped}/" app.js
    sed -i '' "9s/NEZHA_AGENT_PASSWORD/${nezha_key_escaped}/" app.js
    echo -e "${GREEN}NeZha Agent 保活设置完成。${NC}"
else
    echo -e "${RED}跳过 NeZha Agent 保活设置。${NC}"
fi

# No Reason.
curl -sk https://${serv00_domain} > /dev/null 2>&1

# 完成提示
echo -e "${GREEN}已经设置完成，感谢使用！${NC}"
echo -e "${GREEN}日志文件查看：'tail -f ~/domains/${serv00_domain}/logs/error.log'"
echo -e "${GREEN}问题汇报：TG @ZedWAre6667890${NC}"
