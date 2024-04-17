# install dependencies

sudo apt update && \
sudo apt upgrade -y

sudo apt install build-essential libpcap-dev libpcre3-dev \
libnet1-dev zlib1g-dev luajit hwloc libdnet-dev \
libdumbnet-dev bison flex liblzma-dev openssl \
libssl-dev pkg-config libhwloc-dev cmake cpputest \
libsqlite3-dev uuid-dev libcmocka-dev \
libnetfilter-queue-dev libmnl-dev autotools-dev \
libluajit-5.1-dev libunwind-dev libfl-dev git -y

# prep

mkdir ~/snort_src && cd ~/snort_src

# install Snort DAQ

git clone https://github.com/snort3/libdaq.git
cd libdaq
./bootstrap
./configure
make
sudo make install

# install gperftools

cd ../
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
tar xzf gperftools-2.9.1.tar.gz
cd gperftools-2.9.1/
./configure
make
sudo make install

# install snort

cd ../
wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
unzip master.zip
cd snort3-master
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
cd ./build
make
sudo make install
sudo ldconfig
