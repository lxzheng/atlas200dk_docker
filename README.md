# 华为Atl200DK套件Docker开发环境

## 镜像下载

docker pull lxzheng/a200dk

## 启动容器

克隆代码

`git clone https://github.com/lxzheng/atlas200dk_docker.git`

用下面的命令启动容器，进入开发环境

- ./start-a200-dev-container.sh <docker_image> [bind_dir]
  - docker_image：镜像名字
  - bind_dir:主机上的目录，映射到容器，用于项目文件存储，同时也将配置文件保存到该目录。默认使用../Projects目录,若该目录不存在，将会自动创建。
- 例：./start-a200-dev-container.sh lxzheng/a200dk:20.2.a01 ../Projects



## 软件及版本

镜像使用了以下软件

- ubuntu 18.04
- python-3.7.5
- cann-toolkit  X86_64/AARCH64 v20.2.alpha001
- MindStudio  v2.0.0-beta3
- A200dk-npu-driver v20.2

## 制作Docker 镜像

- Dockerfile.cn 使用了上海交大的ubuntu及python的源镜像，从华为服务器下载相关软件包
- Dockerfile.local 如果已把cann-toolkit等软件都下载到本地，可以使用该文件制作。由于在Dockerfile中使用copy会浪费空间，导致镜像过大，它改用启动一个python的http服务用于镜像制作过程中下载相关软件。
  * 使用方法：./buildimage.sh <软件目录>
  * <软件目录>为存放cann-toolkit等软件包的目录
- Dockerfile 不使用ubuntu及python源镜像，希望从华为服务器下载软件包的使用

## 其他问题

* 用户名，密码：xmu_atr:xmu_atr
* root用户密码：root
* 如果在容器中制作sd卡出现错误：“Failed: qemu is broken or the version of qemu is not compatible”，请运行下面的命令注册aarch64架构（在容器内运行）

`sudo update-binfmts --import qemu-aarch64`

## License许可协议

项目使用[GNU General Public License v3.0](LICENSE)协议发布

