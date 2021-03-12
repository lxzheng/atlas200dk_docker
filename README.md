# 华为Atl200DK套件Docker开发环境

## 镜像下载

以下操作需使用docker，如果未安装，需要先[安装Docker](#安装Docker)。）

docker pull lxzheng/a200dk

## 启动容器

克隆代码

`git clone https://github.com/lxzheng/atlas200dk_docker.git`

用下面的命令启动容器，进入开发环境

- ./start-a200-dev-container.sh <docker_image> [bind_dir]
  - docker_image：镜像名字
  - bind_dir:主机上的目录，映射到容器，用于项目文件存储，同时也将配置文件保存到该目录。默认使用../Projects目录,若该目录不存在，将会自动创建。
- 例：./start-a200-dev-container.sh lxzheng/a200dk:latest ../Projects



## 软件及版本

镜像使用了以下软件

- ubuntu 18.04
- python-3.7.5
- cann-toolkit  X86_64/AARCH64 v20.2.alpha001
- MindStudio  v2.0.0-beta3
- A200dk-npu-driver v20.2

## 安装目录说明

所有的软件都安装在$HOME/Ascend目录，包括以下几个子目录

- MindStudio：MindStudio安装目录，已配置好环境变量，可以直接运行MindStudio.sh启动MindStudio

- ascend-toolkit：cann-toolkit 安装目录，包括X86_64和AARCH64两种CPU架构的包

- tools：昇腾工具仓库，其中makesd/for_20.2目录已下载了A200dk-npu-driver及arm64的ubuntu 18.04.5镜像，可直接用于烧录A200DK的TF卡。

  - 如果在制作sd卡出现错误：“Failed: qemu is broken or the version of qemu is not compatible”，请运行下面的命令注册aarch64架构（在容器内运行）

  `sudo update-binfmts --import qemu-aarch64`

## 用户名及密码

* 用户名，密码：xmu_atr:xmu_atr
* root用户密码：root

## 安装Docker

以下说明在ubuntu安装docker的方法

- 安装软件包，允许apt使用https

  ```
  $ sudo apt-get update
  
  $ sudo apt-get install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
  ```

- 添加Docker源的GPG key

  ```
  $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  ```

  此处的https://download.docker.com可以使用国内镜像源代替，比如用https://mirror.sjtu.edu.cn/docker-ce/替换，改成:

  ```
  curl -fsSL https://mirror.sjtu.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  ```

- 添加Docker源

  ```bash
  sudo add-apt-repository \
     "deb [arch=amd64] https://mirror.sjtu.edu.cn/docker-ce/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
  ```

- 安装Docker软件包

  ```
  sudo apt-get update
  sudo apt-get install docker-ce
  ```

- 添加国内docker HUB镜像

  添加docker HUB国内镜像，可以加速`docker pull`等需要下载镜像的命令

  编辑或新建`/etc/docker/daemon.json`文件，向其中添加`registry-mirrors`项，使最终配置为

  ```
  
  {
    "registry-mirrors": ["https://docker.mirrors.sjtug.sjtu.edu.cn"]
  }
  ```

  

## 制作Docker 镜像

- Dockerfile.cn 使用了上海交大的ubuntu及python的源镜像，从华为服务器下载相关软件包
- Dockerfile.local 如果已把cann-toolkit等软件都下载到本地，可以使用该文件制作。由于在Dockerfile中使用copy会浪费空间，导致镜像过大，它改用启动一个python的http服务用于镜像制作过程中下载相关软件。
  * 使用方法：./buildimage.sh <软件目录>
  * <软件目录>为存放cann-toolkit等软件包的目录
- Dockerfile 不使用ubuntu及python源镜像，希望从华为服务器下载软件包的使用

## License许可协议

项目使用[GNU General Public License v3.0](LICENSE)协议发布

