#!/bin/bash

# 设置环境变量
REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"
CONFIG_FILE="$HOME/nanopi-r5s/configs/rockchip.config"
EXTRA_CONFIG="$HOME/nanopi-r5s/configs/extra.config"
DIY_SCRIPT="$HOME/nanopi-r5s/diy-script.sh"
CLASH_KERNEL="arm64"
TZ="Asia/Shanghai"
OPENWRT_PATH="$HOME/lede"
FIRMWARE_TAG="Rockchip"
FILE_DATE=$(date +"%Y.%m.%d")

# 设置时区
sudo timedatectl set-timezone "$TZ"

# 检查磁盘空间
echo "检查磁盘空间..."
df -hT

# 克隆源码
if [ ! -d "$OPENWRT_PATH" ]; then
    echo "克隆 OpenWrt 源码..."
    git clone $REPO_URL -b $REPO_BRANCH $OPENWRT_PATH
else
    echo "源码已存在，更新源码..."
    cd $OPENWRT_PATH
    git pull
fi

# 进入 OpenWrt 源码目录
cd $OPENWRT_PATH

# 获取源码信息
COMMIT_AUTHOR=$(git show -s --date=short --format="作者: %an")
COMMIT_DATE=$(git show -s --date=short --format="时间: %ci")
COMMIT_MESSAGE=$(git show -s --date=short --format="内容: %s")
COMMIT_HASH=$(git show -s --date=short --format="hash: %H")

# 应用配置文件
echo "应用配置文件..."
if [ -f "$CONFIG_FILE" ]; then
    cp $CONFIG_FILE .config
else
    echo "错误：未找到配置文件 $CONFIG_FILE"
    exit 1
fi
if [ -f "$EXTRA_CONFIG" ]; then
    cat $EXTRA_CONFIG >> .config
else
    echo "警告：未找到额外配置文件 $EXTRA_CONFIG"
fi

# 生成设备信息
make defconfig > /dev/null 2>&1
SOURCE_REPO=$(echo $REPO_URL | awk -F '/' '{print $(NF)}')
DEVICE_TARGET=$(cat .config | grep CONFIG_TARGET_BOARD | awk -F '"' '{print $2}')
DEVICE_SUBTARGET=$(cat .config | grep CONFIG_TARGET_SUBTARGET | awk -F '"' '{print $2}')

# 更新和安装 feeds
echo "更新和安装 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 执行 DIY 脚本（仅限 diy-script.sh）
if [ -f "$DIY_SCRIPT" ]; then
    echo "执行 DIY 脚本..."
    chmod +x $DIY_SCRIPT
    $DIY_SCRIPT
else
    echo "警告：未找到 DIY 脚本 $DIY_SCRIPT"
fi

# 下载依赖包
echo "下载依赖包..."
make defconfig
make download -j8
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;

# 编译固件
echo "开始编译固件，使用 $(nproc) 线程..."
mkdir -p files/etc/uci-defaults
make -j$(nproc) || make -j1 || make -j1 V=s

# 检查编译状态
if [ $? -eq 0 ]; then
    echo "固件编译成功！"
    status="success"
else
    echo "固件编译失败！"
    exit 1
fi

# 整理文件
if [ "$status" = "success" ]; then
    echo "整理编译输出文件..."
    cd $OPENWRT_PATH/bin/targets/*/*
    cat sha256sums
    cp $OPENWRT_PATH/.config build.config
    mkdir -p packages
    mv -f $OPENWRT_PATH/bin/packages/*/*/*.ipk packages
    tar -zcf Packages.tar.gz packages
    rm -rf packages feeds.buildinfo version.buildinfo
    KERNEL=$(cat *.manifest | grep ^kernel | cut -d- -f2 | tr -d ' ')
    FIRMWARE_PATH=$PWD

    # 输出固件信息
    echo "固件信息："
    echo "平台架构: $DEVICE_TARGET-$DEVICE_SUBTARGET (rk33xx, rk35xx)"
    echo "固件源码: $REPO_URL"
    echo "源码分支: $REPO_BRANCH"
    echo "内核版本: $KERNEL"
    echo "默认地址: 192.168.1.1"
    echo "默认密码: password"
    echo "$COMMIT_AUTHOR"
    echo "$COMMIT_DATE"
    echo "$COMMIT_MESSAGE"
    echo "$COMMIT_HASH"
    echo "固件路径: $FIRMWARE_PATH"
fi

# 检查磁盘使用情况
echo "检查磁盘使用情况..."
df -hT

exit 0