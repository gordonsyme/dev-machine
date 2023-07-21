#!/bin/bash
set -exu

echo "bootstrapping"

UBUNTU_CODENAME=$(lsb_release --codename --short)

# Configure swap
#fallocate -l 4096M /swapfile
#chmod 0600 /swapfile
#mkswap /swapfile
#swapon /swapfile
#echo '/swapfile none swap defaults 0 0' >> /etc/fstab
cat /proc/swaps

# Configure mirrors
#    apt-get update
#    apt-get install --yes software-properties-common
#
#    add-apt-repository --yes "deb http://ftp.heanet.ie/pub/ubuntu/ ${UBUNTU_CODENAME} main"
#    add-apt-repository --yes "deb mirror://mirrors.ubuntu.com/mirrors.txt ${UBUNTU_CODENAME} main restricted universe multiverse"
#    add-apt-repository --yes "deb mirror://mirrors.ubuntu.com/mirrors.txt ${UBUNTU_CODENAME}-updates main restricted universe multiverse"
#    add-apt-repository --yes "deb mirror://mirrors.ubuntu.com/mirrors.txt ${UBUNTU_CODENAME}-backports main restricted universe multiverse"
#    add-apt-repository --yes "deb mirror://mirrors.ubuntu.com/mirrors.txt ${UBUNTU_CODENAME}-security main restricted universe multiverse"
#    add-apt-repository ppa:webupd8team/java

# Install packages
apt-get update
apt-get install --quiet --yes \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  gnupg2 \
  pinentry-curses \
  python-pip \
  socat \
  software-properties-common
apt-get --yes upgrade

# Install java
curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
apt-get update
apt-get install temurin-11-jdk

# Install docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get --yes install docker-ce \
                      docker-ce-cli \
                      containerd.io \
                      docker-buildx-plugin \
                      docker-compose-plugin

groupadd docker || true
usermod --append --groups docker ubuntu
cp /usr/share/bash-completion/completions/docker /etc/bash_completion.d/docker

# Tidy up installed packages
apt-get remove --yes --purge command-not-found
apt-get autoremove --yes --purge

# Install Leingingen
curl --silent --output /usr/local/bin/lein "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein"
chmod a+x /usr/local/bin/lein

# Install gordonsyme/docker-tools
curl --location --output /usr/bin/yq "https://github.com/mikefarah/yq/releases/v4.34.2/download/yq_linux_arm64"
chmod a+x /usr/bin/yq
sudo --set-home --user=ubuntu mkdir /home/ubuntu/bin
sudo --set-home --user=ubuntu curl \
  --location \
  --output /home/ubuntu/.bash_completion \
  "https://raw.githubusercontent.com/gordonsyme/docker-tools/master/bash_completion"

sudo --set-home --user=ubuntu curl \
  --location \
  --output /home/ubuntu/bin/d \
  "https://raw.githubusercontent.com/gordonsyme/docker-tools/master/bin/d"

sudo --set-home --user=ubuntu curl \
  --location \
  --output /home/ubuntu/bin/dc \
  "https://raw.githubusercontent.com/gordonsyme/docker-tools/master/bin/dc"

sudo --set-home --user=ubuntu chmod u+x /home/ubuntu/bin/d
sudo --set-home --user=ubuntu chmod u+x /home/ubuntu/bin/dc

# Set up the ubuntu user's bashrc
BASHRC=/home/ubuntu/.bashrc

cat << _EOF >> ${BASHRC}
export PS1="[\\u@\\[\\e[0;35m\\]\\h\\[\\e[0m\\] \\w]$ "

export LEIN_GPG=/usr/bin/gpg2

export GOROOT=\${HOME}/go
export PATH=\${PATH}:\${GOROOT}/bin
export CDPATH=:/home/ubuntu/Development

if ! shopt -oq posix; then
  if [ -e ~/.bash_completion ]; then
    . ~/.bash_completion
  fi
fi

if [ -e ~/.iterm2_shell_integration.bash ]; then
  . ~/.iterm2_shell_integration.bash
fi
_EOF

echo "bootstrap finished"
