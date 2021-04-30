bind_dir=$PWD/../Projects
c_home=/home/xmu_atr

if [ -n "$2" ]; then
   bind_dir=$2
fi

for dir in 'modelzoo' '.cache' '.config' '.local' '.mindstudio' '.ssh' 
do
    if [ ! -d "$bind_dir/$dir" ]; then
	mkdir -p $bind_dir/$dir
    fi
done

if [ -n "$1" ]; then
docker run -it --rm -e DISPLAY=$DISPLAY -v /dev/:/dev -v /tmp/:/tmp/ -v $bind_dir:${c_home}/AscendProjects --privileged $1 bash
else
   echo "Run error, Usage:$0 <docker_image> [bind_dir]"
fi
