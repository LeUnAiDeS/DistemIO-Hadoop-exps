
#useradd hadoop --create-home
#su hadoop -c 'mkdir /home/hadoop/.ssh'

cd /home/hadoop
mv /root/hadoop-2.8.4.tar.gz .
tar -xzf hadoop-2.8.4.tar.gz
mv hadoop-2.8.4 hadoop
echo 'PATH=/home/hadoop/hadoop/bin:/root/hadoop/sbin:$PATH' >> /home/hadoop/.profile
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre' >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
#tail -n +2 /root/nodes > /home/hadoop/hadoop/etc/hadoop/slaves

mkdir /tmp/data
chmod 777 -R /tmp/data

chown hadoop:hadoop -R /home/hadoop/hadoop/
chmod 700 -R /home/hadoop/hadoop/
