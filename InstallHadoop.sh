#!/usr/bin/env bash

# InstallHadoop.sh
# Bash Script
# For rudimentary Hadoop Installation (Single-Node Cluster)
#
# To run:
#  open terminal,
#  change directory to this script's location,
#    $ cd <link to InstallHadoop.sh parent directory>
#  give execute permission to the script,
#    $ sudo chmod +x InstallHadoop.sh
#  then execute the script,
#    $ ./InstallHadoop.sh
#
# Online Tutorial
# https://youtu.be/gWkbPVNER5k
#
# Ashesh Kumar Singh <user501254@gmail.com>


# Make sure that the script is not being run as root
if [[ "$EUID" -eq 0 ]]; then
    echo -e "\e[31mDon't run this script as root, check installation script. \nExiting.\n\e[0m"
    exit
fi

set -e
set -o pipefail



clear
echo -e "\e[32mSTEP (1 of 6): Installing Java, OpenSSH, rsync\e[0m"
echo -e "\e[32m##############################################\n\e[0m"
sleep 2s

if [ -f /etc/redhat-release ]; then
  sudo yum install -y java-*-openjdk-devel openssh rsync
elif [ -f /etc/debian_version ]; then
  sudo apt-get install -y default-jdk openssh-server rsync
else
  lsb_release -si
  echo "\e[31mCan't use yum or apt-get, check installation script.\n\e[0m"
  exit
fi

sleep 1s
echo -e "\n\n"



clear
echo -e "\e[32mSTEP  (2 of 6): Setting up SSH keys\e[0m"
echo -e "\e[32m###################################\n\e[0m"
sleep 2s

echo -e  'y\n' | ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
sudo systemctl restart sshd.service || sudo service ssh restart

sleep 1s
echo -e "\n\n"



clear
echo -e "\e[32mSTEP  (3 of 6): Downloading and Extracting Hadoop archive\e[0m"
echo -e "\e[32m#########################################################\n\e[0m"
sleep 2s

FILE=$(wget "http://www.eu.apache.org/dist/hadoop/common/stable/" -O - | grep -Po "hadoop-[0-9].[0-9].[0-9].tar.gz" | head -n 1)
URL=http://www.eu.apache.org/dist/hadoop/common/stable/$FILE
wget -c "$URL" -O "$FILE"
wget -c "$URL.mds" -O - | sed '7,$ d' | tr -d " \t\n\r" | tr ":" " " | awk '{t=$1;$1=$NF;$NF=t}1' | awk '$1=$1' OFS="  " | cut -c 5- | md5sum -c
sudo tar xfz "$FILE" -C /usr/local 
sudo mv /usr/local/hadoop-*/ /usr/local/hadoop
CURRENT=$USER
sudo chown -R $CURRENT:$CURRENT /usr/local/hadoop
ls -las /usr/local

sleep 1s
echo -e "\n\n"



clear
echo -e "\e[32mSTEP  (4 of 6): Editing Configuration Files\e[0m"
echo -e "\e[32m###########################################\n\e[0m"

sudo update-alternatives --auto java
cp ~/.bashrc ~/.bashrc.bak
cat << 'EOT' >> ~/.bashrc
#SET JDK
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:jre/bin/java::")
#HADOOP VARIABLES START
export HADOOP_INSTALL=/usr/local/hadoop
export PATH=$PATH:$HADOOP_INSTALL/bin
export PATH=$PATH:$HADOOP_INSTALL/sbin
export HADOOP_MAPRED_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_HOME=$HADOOP_INSTALL
export HADOOP_HDFS_HOME=$HADOOP_INSTALL
export YARN_HOME=$HADOOP_INSTALL
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"
#HADOOP VARIABLES END
EOT
source ~/.bashrc
java -version
javac -version
sed -i.bak -e 's/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=$(readlink -f \/usr\/bin\/java | sed "s:jre\/bin\/java::")/g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh

sed -n -i.bak '/<configuration>/q;p'  /usr/local/hadoop/etc/hadoop/core-site.xml
cat << EOT >> /usr/local/hadoop/etc/hadoop/core-site.xml
<configuration>
  <property>
     <name>fs.default.name</name>
     <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOT

sed -n -i.bak '/<configuration>/q;p' /usr/local/hadoop/etc/hadoop/yarn-site.xml
cat << EOT >> /usr/local/hadoop/etc/hadoop/yarn-site.xml
<configuration>
  <property>
     <name>yarn.nodemanager.aux-services</name>
     <value>mapreduce_shuffle</value>
  </property>
  <property>
     <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
     <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>
</configuration>
EOT

cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
sed -n -i.bak '/<configuration>/q;p'  /usr/local/hadoop/etc/hadoop/mapred-site.xml
cat << EOT >> /usr/local/hadoop/etc/hadoop/mapred-site.xml
<configuration>
  <property>
     <name>mapreduce.framework.name</name>
     <value>yarn</value>
  </property>
</configuration>
EOT

mkdir -p /home/$USER/hadoop_store/hdfs/namenode
mkdir -p /home/$USER/hadoop_store/hdfs/datanode
sed -n -i.bak '/<configuration>/q;p'  /usr/local/hadoop/etc/hadoop/hdfs-site.xml
cat << EOT >> /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
     <name>dfs.replication</name>
     <value>1</value>
  </property>
  <property>
     <name>dfs.namenode.name.dir</name>
     <value>file:/home/$USER/hadoop_store/hdfs/namenode</value>
  </property>
  <property>
     <name>dfs.datanode.data.dir</name>
     <value>file:/home/$USER/hadoop_store/hdfs/datanode</value>
  </property>
</configuration>
EOT

sleep 2s
echo -e "\n\n"



clear
echo -e "\e[32mSTEP  (5 of 6): Formatting HDFS (namenode directory)\e[0m"
echo -e "\e[32m####################################################\n\e[0m"
sleep 2s

/usr/local/hadoop/bin/hdfs namenode -format

sleep 1s
echo -e "\n\n"



clear
echo -e "\e[32mSTEP  (6 of 6): Strating Hadoop daemons\e[0m"
echo -e "\e[32m#######################################\n\e[0m"
sleep 2s

/usr/local/hadoop/sbin/start-dfs.sh
/usr/local/hadoop/sbin/start-yarn.sh

sleep 1s
echo -e "\n\n"



clear
jps
google-chrome http://$HOSTNAME:50070 || firefox http://$HOSTNAME:50070 || midori http://$HOSTNAME:50070
echo -e "\n\n"



echo -e "Stopping Hadoop daemons\n"
/usr/local/hadoop/sbin/stop-dfs.sh
/usr/local/hadoop/sbin/stop-yarn.sh
