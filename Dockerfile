FROM ubuntu:18.04
LABEL maintainer="Lingxiang Zheng<lxzheng@xmu.edu.cn>"				   \
      ventor="ATR Lab, Xiamen University" 

ARG python_url=https://mirrors.huaweicloud.com/python/3.7.5/Python-3.7.5.tgz	   \
    OBS_URL=https://obs-9be7.obs.cn-east-2.myhuaweicloud.com/turing/resource	   \
    MS_VER=2.0.0-beta3								   \
    MR_URL=https://mirrors.huaweicloud.com/ascend/autoarchive/CANN 		   \
    CANN_URL_VER=CANN%20V100R020C20						   \
    CANN_VER=20.2.alpha001							   \
    NDR_VER=20.2

ARG MS_NAME=MindStudio_${MS_VER}_linux.tar.gz					   \
    CANN_X86_NAME=Ascend-cann-toolkit_${CANN_VER}_linux-x86_64.run		   \
    CANN_ARM_NAME=Ascend-cann-toolkit_${CANN_VER}_linux-aarch64.run		   \
    NDR_NAME=A200dk-npu-driver-${NDR_VER}.0-ubuntu18.04-aarch64-minirc.tar.gz

ARG mindstudio_url=${OBS_URL}/mindstudio/${MS_VER}/${MS_NAME}				   \
    cann_toolkit_x86_url=${MR_URL}/${CANN_URL_VER}/${CANN_X86_NAME}		   \
    cann_toolkit_aarch64_url=${MR_URL}/${CANN_URL_VER}/${CANN_ARM_NAME}		   \
    npu_driver_url=${OBS_URL}/atlas200dk/${NDR_VER}/${NDR_NAME}			
    
ARG repo_url=http://cdimage.ubuntu.com/releases/18.04.4/release			   \
    ubuntu_cd_name=ubuntu-18.04.5-server-arm64.iso				   \
    HOME=/home/xmu_atr

RUN apt update 		      							&& \
    apt upgrade -yq 	      							&& \
    apt install -y gcc make cmake unzip zlib1g zlib1g-dev libsqlite3-dev 	   \
                   openssl libssl-dev libffi-dev pciutils net-tools     	   \
                   g++-5-aarch64-linux-gnu xterm g++ openjdk-8-jdk       	   \
                   fonts-wqy-zenhei fonts-wqy-microhei fonts-arphic-ukai   	   \
                   fonts-arphic-uming git iputils-ping vim sudo ssh 		   \
		   g++-aarch64-linux-gnu qemu-user-static binfmt-support 	   \
		   python3-yaml gcc-aarch64-linux-gnu g++-aarch64-linux-gnu	   \
		   autoconf automake libtool ca-certificates firefox xdg-utils 	   \
		   fonts-droid-fallback gnome-keyring squashfs-tools		&& \
    apt clean 		      							&& \
    rm -rf /var/lib/apt/lists/*	/tmp/* 						&& \
    echo "root:root" | chpasswd 						&& \
    useradd -d ${HOME} -m xmu_atr 						&& \
    echo "xmu_atr:xmu_atr" | chpasswd 						&& \
    chmod 750 ${HOME}								&& \
    usermod -aG sudo xmu_atr

RUN cd ${HOME}									&& \
    wget -q $python_url								&& \
    tar -zxvf Python-3.7.5.tgz							&& \
    cd Python-3.7.5								&& \
    ./configure --prefix=/usr/local/python3.7.5 --enable-shared			&& \
    make -j8									&& \
    make install								&& \
    cd ${HOME}									&& \
    rm -rf Python-3.7.5*

RUN ln -s /usr/local/python3.7.5/lib/libpython3.7m.so.1.0 /usr/lib		&& \
    rm /usr/bin/python3								&& \
    ln -s /usr/local/python3.7.5/bin/python3 /usr/bin/python3			&& \
    ln -s /usr/local/python3.7.5/bin/pip3 /usr/bin/pip3				&& \
    ln -s /usr/local/python3.7.5/bin/python3 /usr/bin/python3.7			&& \
    ln -s /usr/local/python3.7.5/bin/pip3 /usr/bin/pip3.7			&& \
    ln -s /usr/local/python3.7.5/bin/python3 /usr/bin/python3.7.5		&& \
    ln -s /usr/local/python3.7.5/bin/pip3 /usr/bin/pip3.7.5			&& \
    ln -s /usr/lib/python3/dist-packages/lsb_release.py 			   \
	  /usr/local/python3.7.5/lib/python3.7/


# 安装时检查是否存在用户HwHiAiUser，尽管能在安装时指定用户名绕过这个坑，
# 但只有root用户能在安装时指定用户名，在安装过程中又要检查安装路径的所有权
# 是否是运行安装程序的用户，所以root用户只能将软件安装在root为所有者的目录，
# root实际上并不能为普通用户安装，那为什么还要检查用户名，这是什么鬼设计啊！
RUN wget -q ${cann_toolkit_x86_url}						&& \
    chmod +x ./${CANN_X86_NAME}							&& \
    ./${CANN_X86_NAME} --install				 		   \
      --install-username=xmu_atr --install-usergroup=xmu_atr			   \
      --install-for-all --install-path=/usr/local/Ascend			&& \
    rm ./${CANN_X86_NAME}							&& \
    wget -q ${cann_toolkit_aarch64_url}						&& \
    chmod +x ${CANN_ARM_NAME}							&& \
    ./${CANN_ARM_NAME} --install				 		   \
      --install-username=xmu_atr --install-usergroup=xmu_atr			   \
      --install-for-all --install-path=/usr/local/Ascend			&& \
    rm ./${CANN_ARM_NAME}							&& \
    mv /usr/local/Ascend $HOME/							&& \
    chown xmu_atr:xmu_atr $HOME/Ascend -R
    

RUN pip3.7 --no-cache-dir install attrs psutil decorator numpy                     \
		scipy sympy cffi grpcio grpcio-tools requests coverage             \
		gnureadline pylint matplotlib PyQt5==5.14.0 	                   \
		pyyaml tornado protobuf==3.11.3 pandas xlrd absl-py

COPY qemu-aarch64 /usr/share/binfmts/
USER xmu_atr
WORKDIR ${HOME}

RUN git clone --depth 1 https://gitee.com/ascend/tools.git ./Ascend/tools	&& \
    wget -q ${repo_url}/${ubuntu_cd_name}					&& \
    wget -q ${mindstudio_url}							&& \
    tar xzf ${MS_NAME} -C ./Ascend						&& \
    rm ./${MS_NAME}								&& \
    cd Ascend/tools/makesd/for_${NDR_VER}					&& \
    ln ${HOME}/${ubuntu_cd_name} .					   	&& \
    wget -q ${npu_driver_url} 

ENV DDK_PATH=${HOME}/Ascend/ascend-toolkit/${CANN_VER}/acllib_linux.aarch64	   \
PATH=${PATH}:/usr/local/python3.7.5/bin:${HOME}/Ascend/MindStudio/bin:\
${HOME}/Ascend/ascend-toolkit/latest/toolkit/bin:\
${HOME}/Ascend/ascend-toolkit/latest/fwkacllib/ccec_compiler/bin:\
${HOME}/Ascend/ascend-toolkit/latest/fwkacllib/bin:\
${HOME}/Ascend/ascend-toolkit/latest/atc/ccec_compiler/bin:\
${HOME}/Ascend/ascend-toolkit/latest/atc/bin					   \
LD_LIBRARY_PATH=${HOME}/Ascend/ascend-toolkit/latest/acllib/lib64:\
${HOME}/Ascend/ascend-toolkit/latest/fwkacllib/lib64:\
${HOME}/Ascend/ascend-toolkit/latest/atc/lib64				 	   \
PYTHONPATH=${HOME}/Ascend/ascend-toolkit/latest/pyACL/python/site-packages/acl:\
${HOME}/Ascend/ascend-toolkit/latest/fwkacllib/python/site-packages:\
${HOME}/Ascend/ascend-toolkit/latest/atc/python/site-packages:\
${HOME}/Ascend/ascend-toolkit/latest/toolkit/python/site-packages		   \
ASCEND_AICPU_PATH=${HOME}/Ascend/ascend-toolkit/latest			   	   \
ASCEND_OPP_PATH=${HOME}/Ascend/ascend-toolkit/latest/opp			   \
TOOLCHAIN_HOME=${HOME}/Ascend/ascend-toolkit/latest/toolkit			   \
ASCEND_AICPU_PATH=${HOME}/Ascend/ascend-toolkit/latest				   \
PRJ_HOME=${HOME}/AscendProject

RUN for dir in 'modelzoo' '.cache' '.config' '.local' '.mindstudio' '.ssh';do	   \
        ln -s ${PRJ_HOME}/${dir} ${HOME}/${dir};done

