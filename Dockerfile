FROM ubuntu:18.04
LABEL maintainer="Lingxiang Zheng<lxzheng@xmu.edu.cn>"				   \
      ventor="ATR Lab, Xiamen University" 

ARG installer_url=172.17.0.1:8000 						   \
    python_url=https://mirrors.huaweicloud.com/python/3.7.5/Python-3.7.5.tgz	   \
    mindstudio_url=https://obs-9be7.obs.cn-east-2.myhuaweicloud.com/turing/\
resource/mindstudio/2.0.0-beta3/MindStudio_2.0.0-beta3_linux.tar.gz		   \
    cann_toolkit_x86_url=https://mirrors.huaweicloud.com/ascend/autoarchive/CANN/\
CANN%20V100R020C20/Ascend-cann-toolkit_20.2.alpha001_linux-x86_64.run		   \
    cann_toolkit_aarch64_url=https://mirrors.huaweicloud.com/ascend/autoarchive/\
CANN/CANN%20V100R020C20/Ascend-cann-toolkit_20.2.alpha001_linux-aarch64.run	   \
    npu_driver_url=https://obs-9be7.obs.cn-east-2.myhuaweicloud.com/turing/\
resource/atlas200dk/20.1/A200dk-npu-driver-20.1.0-ubuntu18.04-aarch64-minirc.tar.gz

    


RUN sed -i s@/archive.ubuntu.com/@/ftp.sjtu.edu.cn/@g /etc/apt/sources.list 	&& \
    sed -i s@/security.ubuntu.com/@/ftp.sjtu.edu.cn/@g /etc/apt/sources.list 	&& \
    apt update 		      							&& \
    apt upgrade -yq 	      							&& \
    apt install -y gcc make cmake unzip zlib1g zlib1g-dev libsqlite3-dev 	   \
                   openssl libssl-dev libffi-dev pciutils net-tools     	   \
                   g++-5-aarch64-linux-gnu xterm g++ openjdk-8-jdk       	   \
                   fonts-wqy-zenhei fonts-wqy-microhei fonts-arphic-ukai   	   \
                   fonts-arphic-uming git iputils-ping vim sudo ssh 		   \
		   g++-aarch64-linux-gnu qemu-user-static binfmt-support 	   \
		   python3-yaml gcc-aarch64-linux-gnu g++-aarch64-linux-gnu	   \
		   autoconf automake libtool ca-certificates firefox xdg-utils 	   \
		   fonts-droid-fallback gnome-keyring	 			&& \
    apt clean 		      							&& \
    rm -rf /var/lib/apt/lists/*	/tmp/* 						&& \
    echo "root:root" | chpasswd 						&& \
    useradd -d /home/xmu_atr -m xmu_atr 					&& \
    echo "xmu_atr:xmu_atr" | chpasswd 						&& \
    chmod 750 /home/xmu_atr							&& \
    usermod -aG sudo xmu_atr

RUN cd /home/xmu_atr								&& \
    wget  $python_url								&& \
    tar -zxvf Python-3.7.5.tgz							&& \
    cd Python-3.7.5								&& \
    ./configure --prefix=/usr/local/python3.7.5 --enable-shared			&& \
    make -j8									&& \
    make install								&& \
    cd /home/xmu_atr								&& \
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


RUN wget  ${cann_toolkit_x86_url}						&& \
    chmod +x Ascend-cann-toolkit_20.2.alpha001_linux-x86_64.run			&& \
    ./Ascend-cann-toolkit_20.2.alpha001_linux-x86_64.run --install 		   \
      --install-username=xmu_atr --install-usergroup=xmu_atr			   \
      --install-for-all --install-path=/usr/local/Ascend			&& \
    rm ./Ascend-cann-toolkit_20.2.alpha001_linux-x86_64.run			&& \
    wget  ${cann_toolkit_aarch64_url}						&& \
    chmod +x Ascend-cann-toolkit_20.2.alpha001_linux-aarch64.run		&& \
    ./Ascend-cann-toolkit_20.2.alpha001_linux-aarch64.run --install 		   \
      --install-username=xmu_atr --install-usergroup=xmu_atr			   \
      --install-for-all --install-path=/usr/local/Ascend			&& \
    rm ./Ascend-cann-toolkit_20.2.alpha001_linux-aarch64.run			&& \
    wget  ${npu_driver_url} && \
    tar xzf A200dk-npu-driver-20.1.0-ubuntu18.04-aarch64-minirc.tar.gz 		   \
	    -C /usr/local/Ascend						&& \
    rm ./A200dk-npu-driver-20.1.0-ubuntu18.04-aarch64-minirc.tar.gz		&& \
    wget  ${mindstudio_url}							&& \
    tar xzf MindStudio_2.0.0-beta3_linux.tar.gz -C /usr/local/Ascend		&& \
    rm ./MindStudio_2.0.0-beta3_linux.tar.gz					&& \
    cd /usr/local/Ascend/							&& \
    chmod a+r * -R								&& \
    find ./* -perm /+x -exec chmod a+x {} \;					&& \
    chmod a+x ./MindStudio/tools/llvm/scripts/StartClangd.sh 

RUN pip3.7 config set --global global.index-url                                    \
                https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple               && \
    pip3.7 config set --global global.trusted-host                                 \
                https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple		&& \
    pip3.7 --no-cache-dir install attrs psutil decorator numpy                     \
		scipy sympy cffi grpcio grpcio-tools requests coverage             \
		gnureadline pylint matplotlib PyQt5==5.14.0 	                   \
		pyyaml tornado protobuf==3.11.3 pandas xlrd absl-py

USER xmu_atr
WORKDIR /home/xmu_atr/


ENV DDK_PATH=/usr/local/Ascend/ascend-toolkit/20.2.alpha001/acllib_linux.aarch64   \
PATH=${PATH}:/usr/local/python3.7.5/bin:/usr/local/Ascend/MindStudio/bin:\
/usr/local/Ascend/ascend-toolkit/latest/toolkit/bin:\
/usr/local/Ascend/ascend-toolkit/latest/fwkacllib/ccec_compiler/bin:\
/usr/local/Ascend/ascend-toolkit/latest/fwkacllib/bin:\
/usr/local/Ascend/ascend-toolkit/latest/atc/ccec_compiler/bin:\
/usr/local/Ascend/ascend-toolkit/latest/atc/bin					   \
LD_LIBRARY_PATH=/usr/local/Ascend/ascend-toolkit/latest/acllib/lib64:\
/usr/local/Ascend/ascend-toolkit/latest/fwkacllib/lib64:\
/usr/local/Ascend/ascend-toolkit/latest/atc/lib64				   \
PYTHONPATH=/usr/local/Ascend/ascend-toolkit/latest/pyACL/python/site-packages/acl:\
/usr/local/Ascend/ascend-toolkit/latest/fwkacllib/python/site-packages:\
/usr/local/Ascend/ascend-toolkit/latest/atc/python/site-packages:\
/usr/local/Ascend/ascend-toolkit/latest/toolkit/python/site-packages		   \
ASCEND_AICPU_PATH=/usr/local/Ascend/ascend-toolkit/latest			   \
ASCEND_OPP_PATH=/usr/local/Ascend/ascend-toolkit/latest/opp			   \
TOOLCHAIN_HOME=/usr/local/Ascend/ascend-toolkit/latest/toolkit			   \
ASCEND_AICPU_PATH=/usr/local/Ascend/ascend-toolkit/latest

RUN mkdir -p .mindstudio/configure						&& \
    cd .mindstudio/configure							&& \
    echo "adk_install_root_path=/usr/local/Ascend/ascend-toolkit/20.2.alpha001"    \
	>mindstudio.properties							&& \
    echo "adk_version=1.77.T10.0.B100" >>mindstudio.properties


