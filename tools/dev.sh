#!/bin/bash

# 微信小程序开发工具脚本
# 用于快速开始和常用操作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 显示帮助信息
show_help() {
    echo -e "${GREEN}微信小程序开发工具脚本${NC}"
    echo ""
    echo "使用方法: ./tools/dev.sh [命令]"
    echo ""
    echo "可用命令:"
    echo "  help      显示此帮助信息"
    echo "  init      初始化开发环境"
    echo "  preview   启动网页预览"
    echo "  docs      打开开发文档"
    echo "  check     检查代码规范"
    echo "  backup    备份项目代码"
    echo "  deploy    部署到GitHub Pages"
    echo ""
}

# 初始化开发环境
init_env() {
    echo -e "${BLUE}正在初始化开发环境...${NC}"
    
    # 检查必要工具
    echo "检查必要工具..."
    command -v git >/dev/null 2>&1 || { echo -e "${RED}错误: git未安装${NC}"; exit 1; }
    command -v node >/dev/null 2>&1 || { echo -e "${YELLOW}警告: Node.js未安装，某些功能可能无法使用${NC}"; }
    
    # 创建必要的目录
    echo "创建项目目录..."
    mkdir -p "${PROJECT_ROOT}/miniprogram/pages"
    mkdir -p "${PROJECT_ROOT}/miniprogram/utils"
    mkdir -p "${PROJECT_ROOT}/miniprogram/components"
    mkdir -p "${PROJECT_ROOT}/docs"
    mkdir -p "${PROJECT_ROOT}/examples"
    
    # 创建基础配置文件
    if [ ! -f "${PROJECT_ROOT}/package.json" ]; then
        echo "创建package.json..."
        cat > "${PROJECT_ROOT}/package.json" << EOF
{
  "name": "wechat-reminder-miniprogram",
  "version": "0.1.0",
  "description": "微信提醒工具小程序",
  "scripts": {
    "dev": "echo '请使用微信开发者工具打开miniprogram目录'",
    "preview": "open ${PROJECT_ROOT}/web-preview/index.html || xdg-open ${PROJECT_ROOT}/web-preview/index.html || echo '请在浏览器中打开web-preview/index.html'",
    "docs": "echo '开发文档位于 docs/ 目录'"
  }
}
EOF
    fi
    
    echo -e "${GREEN}开发环境初始化完成！${NC}"
    echo ""
    echo "下一步："
    echo "1. 下载微信开发者工具"
    echo "2. 导入 ${PROJECT_ROOT}/miniprogram 目录"
    echo "3. 开始开发"
}

# 启动网页预览
start_preview() {
    echo -e "${BLUE}启动网页预览...${NC}"
    
    if [ ! -f "${PROJECT_ROOT}/web-preview/index.html" ]; then
        echo -e "${RED}错误: 预览文件不存在${NC}"
        echo "请先运行 './tools/dev.sh init' 初始化项目"
        exit 1
    fi
    
    # 尝试用不同方式打开网页
    if command -v open >/dev/null 2>&1; then
        # macOS
        open "${PROJECT_ROOT}/web-preview/index.html"
    elif command -v xdg-open >/dev/null 2>&1; then
        # Linux
        xdg-open "${PROJECT_ROOT}/web-preview/index.html"
    elif command -v start >/dev/null 2>&1; then
        # Windows (Git Bash)
        start "${PROJECT_ROOT}/web-preview/index.html"
    else
        echo -e "${YELLOW}无法自动打开浏览器，请手动打开文件：${NC}"
        echo "${PROJECT_ROOT}/web-preview/index.html"
    fi
    
    echo -e "${GREEN}网页预览已启动${NC}"
}

# 打开开发文档
open_docs() {
    echo -e "${BLUE}开发文档目录：${NC}"
    echo "${PROJECT_ROOT}/docs/"
    
    ls -la "${PROJECT_ROOT}/docs/" | grep -E '\.md$' | while read line; do
        filename=$(echo "$line" | awk '{print $9}')
        echo "  📄 $filename"
    done
    
    echo ""
    echo "主要文档："
    echo "  📘 docs/从零开始开发指南.md - 完整学习路径"
    echo "  📙 docs/功能需求分析.md - 功能规格说明"
    echo "  📗 docs/环境搭建指南.md - 开发环境配置"
}

# 检查代码规范
check_code() {
    echo -e "${BLUE}检查代码规范...${NC}"
    
    # 检查文件结构
    echo "检查文件结构..."
    if [ ! -f "${PROJECT_ROOT}/miniprogram/app.js" ]; then
        echo -e "${YELLOW}警告: app.js 文件不存在${NC}"
    fi
    
    if [ ! -f "${PROJECT_ROOT}/miniprogram/app.json" ]; then
        echo -e "${YELLOW}警告: app.json 文件不存在${NC}"
    fi
    
    # 检查页面文件
    echo "检查页面文件..."
    for page in index reminder/create reminder/list; do
        page_dir="${PROJECT_ROOT}/miniprogram/pages/${page}"
        if [ -d "$page_dir" ]; then
            if [ ! -f "${page_dir}/${page##*/}.js" ] || \
               [ ! -f "${page_dir}/${page##*/}.wxml" ] || \
               [ ! -f "${page_dir}/${page##*/}.wxss" ] || \
               [ ! -f "${page_dir}/${page##*/}.json" ]; then
                echo -e "${YELLOW}警告: 页面 ${page} 文件不完整${NC}"
            else
                echo -e "${GREEN}页面 ${page} 文件完整${NC}"
            fi
        else
            echo -e "${YELLOW}警告: 页面 ${page} 目录不存在${NC}"
        fi
    done
    
    echo -e "${GREEN}代码检查完成${NC}"
}

# 备份项目代码
backup_project() {
    echo -e "${BLUE}备份项目代码...${NC}"
    
    BACKUP_DIR="${PROJECT_ROOT}/backup"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="${BACKUP_DIR}/wechat-reminder_${TIMESTAMP}.tar.gz"
    
    mkdir -p "$BACKUP_DIR"
    
    # 排除不需要备份的文件
    tar --exclude='backup' \
        --exclude='node_modules' \
        --exclude='.*' \
        -czf "$BACKUP_FILE" \
        -C "${PROJECT_ROOT}" .
    
    if [ $? -eq 0 ]; then
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}备份完成: ${BACKUP_FILE} (${BACKUP_SIZE})${NC}"
        
        # 清理旧的备份文件（保留最近5个）
        echo "清理旧备份..."
        ls -t "${BACKUP_DIR}"/*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm
    else
        echo -e "${RED}备份失败${NC}"
        exit 1
    fi
}

# 部署到GitHub Pages
deploy_pages() {
    echo -e "${BLUE}部署到GitHub Pages...${NC}"
    
    if [ ! -d "${PROJECT_ROOT}/.git" ]; then
        echo -e "${RED}错误: 这不是一个Git仓库${NC}"
        echo "请先初始化Git仓库："
        echo "  git init"
        echo "  git add ."
        echo "  git commit -m '初始提交'"
        exit 1
    fi
    
    # 检查是否配置了GitHub远程仓库
    REMOTE_URL=$(git -C "${PROJECT_ROOT}" remote get-url origin 2>/dev/null || true)
    
    if [ -z "$REMOTE_URL" ]; then
        echo -e "${YELLOW}未配置GitHub远程仓库${NC}"
        echo "请先添加远程仓库："
        echo "  git remote add origin https://github.com/用户名/仓库名.git"
        exit 1
    fi
    
    echo "远程仓库: $REMOTE_URL"
    
    # 推送到GitHub
    echo "推送代码到GitHub..."
    git -C "${PROJECT_ROOT}" push origin main
    
    echo -e "${GREEN}部署完成！${NC}"
    echo "GitHub Pages 地址："
    echo "  https://[用户名].github.io/[仓库名]/"
}

# 主程序
main() {
    case "$1" in
        help)
            show_help
            ;;
        init)
            init_env
            ;;
        preview)
            start_preview
            ;;
        docs)
            open_docs
            ;;
        check)
            check_code
            ;;
        backup)
            backup_project
            ;;
        deploy)
            deploy_pages
            ;;
        *)
            echo -e "${RED}未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行主程序
main "$@"