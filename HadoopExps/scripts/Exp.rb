require 'cute'
require 'yaml'
require 'net/scp'


class Exp

G5K_SITE = 'rennes'
G5K_DEPLOY_DESC = 'http://public.rennes.grid5000.fr/~asaif/hadoopHome.desc'
G5K = Cute::G5K::API.new


def start(disk)

jobid = ENV['OAR_JOB_ID']
job = G5K.get_job(G5K_SITE, jobid)
nodes = `uniq $OAR_NODE_FILE`.split()

slaves = nodes[1..-1]
master = nodes[0]

G5K.deploy(job, :nodes => nodes, :env => G5K_DEPLOY_DESC, :wait => true)
File.open('nodes', 'w') { |file| file.write(nodes.join("\n")) }
sleep(60)

puts "mounting nfs on all machines "

nodes.each{ |n| `ssh root@#{n} "mkdir -p /home/asaif"` }
nodes.each{ |n| `ssh root@#{n} "mount nfs:/export/home/asaif /home/asaif"` }
#ssh = Net::SSH::Multi::Session::new
#nodes.each { |n| ssh.use "root@#{n}"}
#ssh.exec!('mount nfs:/export/home/asaif /home/asaif')


#### HDD or SSD
if disk == ""

else
puts "Partitioning and formating the selected data location"
device = disk
partition="#{device}1"

nodes.each { |n|
Net::SSH.start(n, "root") do |ssh|
        ssh.exec!("echo -e \"o\nd\nn\np\n1\n\n\nw\" | fdisk /dev/#{device}")
        ssh.exec!("mkfs -t ext4 /dev/#{partition}")
        ssh.exec!("umount -f /tmp")
        ssh.exec!("mount /dev/#{partition} /tmp")
end
}

end #if




Net::SCP.start(master, "root") do |scp|
	    scp.upload! 'nodes', '/root/nodes'
	        scp.upload! 'deploy_vnodes.rb', '/root/deploy_vnodes.rb'
end


puts "Deploying distem on the nodes..."
`./distem-bootstrap --debian-version stretch -g -U https://github.com/Ododo/distem.git`

puts "Deploying vnodes on all pnodes"

Net::SSH.start(master, "root") do |ssh|
	    ssh.exec!("ruby /root/deploy_vnodes.rb")
end


puts "Parametring pnodes..."

ssh = Net::SSH::Multi::Session::new

nodes.each { |n| ssh.use "root@#{n}"}


ssh.exec!('apt install -y netcat prometheus-node-exporter')
#ssh.exec!('apt install -y netcat')
#ssh.exec!('apt-get install -t testing -y netcat cadvisor')
ssh.exec!('echo "* soft nofile 16384" >> /etc/security/limits.conf')
ssh.exec!('echo "* hard nofile 16384" >> /etc/security/limits.conf')
ssh.exec!('echo "session required pam_limits.so" >> /etc/pam.d/common-session')


ssh = Net::SSH::Multi::Session::new

subnet = job['resources_by_type']['subnets'][0][0..-5]

puts "Saving previous ssh configuration to ~/.ssh/bkp_config"

`cp ~/.ssh/config ~/.ssh/bkp_config`

vnodes = {}

for i in 0..nodes.size-1
	    vnodes[nodes[i]] = "#{subnet}#{i+1}"
end

puts "Updating ~/.ssh/config to allow connexion to vnodes"

`echo -e "\nHost *\n\tStrictHostKeyChecking no\n\tHashKnownHosts no" >> ~/.ssh/config`
`echo -e "\nHost #{subnet}*\n\tUserKnownHostsFile=/dev/null" >> ~/.ssh/config`

`echo > slaves`

puts "OK till here"

nodes.each_with_index { |n, i|
	    `echo "node#{i+1}" >> slaves` if i != 0
	        `echo -e "\nHost #{vnodes[n]}\n\tUser root\n\tPort 22\n\tProxyCommand ssh root@#{n} nc %h %p" >> ~/.ssh/config`
		    ssh.use("root@#{vnodes[n]}")
}

puts "Parametring vnodes..."

ssh.exec!('echo "session required pam_limits.so" >> /etc/pam.d/common-session')
ssh.exec!('echo "* soft nofile 16384" >> /etc/security/limits.conf')
ssh.exec!('echo "* hard nofile 16384" >> /etc/security/limits.conf')
ssh.exec!("rm /etc/hosts")

for i in 1..nodes.size
	    ssh.exec!("echo -e '\n#{subnet}#{i} node#{i}' >> /etc/hosts")  
end

ssh.exec!("useradd hadoop --create-home")
ssh.exec!("su hadoop -c 'mkdir /home/hadoop/.ssh'")

puts "Sharing ssh keys..."

`./share_keys.sh`

ssh.exec!("chown hadoop:hadoop -R /home/hadoop/.ssh/")
ssh.exec!("chmod 700 -R /home/hadoop/.ssh/")

puts "Installing hadoop 2.8.4 ..."

s1 = File.open("snippet_1.sh", "r").read
ssh.exec!(s1)


puts "Upload config files ..."

confpath = '/tmp/distem/rootfs-unique/*/home/hadoop/hadoop/etc/hadoop'



# copy the config file to the master (node1)
  `scp conf/core-site.xml root@#{master}:#{confpath}`
  `scp conf/hdfs-site.xml root@#{master}:#{confpath}`
  `scp conf/mapred-site.xml root@#{master}:#{confpath}`
  `scp conf/yarn-site.xml root@#{master}:#{confpath}`
  `scp slaves root@#{master}:#{confpath}`

# keeping track of mappers_reducers
mappers = []
reducers = []

for i in 0 .. slaves.size-1
	 if i % 2 == 0  # mapper   "mapred-site file is different
		  `scp conf/core-site.xml root@#{slaves[i]}:#{confpath}`
		  `scp conf/hdfs-site.xml root@#{slaves[i]}:#{confpath}`
		  `scp conf/mapred-site_m.xml root@#{slaves[i]}:#{confpath}`
		  `scp conf/yarn-site.xml root@#{slaves[i]}:#{confpath}`
		  `scp slaves root@#{slaves[i]}:#{confpath}`
		   mappers.push("#{slaves[i]}")
	else
		   `scp conf/core-site.xml root@#{slaves[i]}:#{confpath}`
                  `scp conf/hdfs-site.xml root@#{slaves[i]}:#{confpath}`
                  `scp conf/mapred-site_r.xml root@#{slaves[i]}:#{confpath}`
                  `scp conf/yarn-site.xml root@#{slaves[i]}:#{confpath}`
                  `scp slaves root@#{slaves[i]}:#{confpath}`
                   reducers.push("#{slaves[i]}")
	end

end 


puts "hadoop mappers are #{mappers}"
puts "haoop reducers are #{reducers}"

################## comments
=begin
nodes.each{ |n|
	    `scp conf/core-site.xml root@#{n}:#{confpath}`
	        `scp conf/hdfs-site.xml root@#{n}:#{confpath}`
		    `scp conf/mapred-site.xml root@#{n}:#{confpath}`
		        `scp conf/yarn-site.xml root@#{n}:#{confpath}`
			    `scp slaves root@#{n}:#{confpath}`
}
=end 
######################## end comment

ssh.exec!("chown hadoop:hadoop -R /home/hadoop/hadoop/")
ssh.exec!("chmod 700 -R /home/hadoop/hadoop/")

puts "Format hdfs, start Hadoop ..."

ssh = Net::SSH::Multi::Session::new
ssh.use("hadoop@#{vnodes[master]}")
ssh.exec!("/home/hadoop/hadoop/bin/hdfs namenode -format")
ssh.exec!("/home/hadoop/hadoop/sbin/start-dfs.sh")
ssh.exec!("/home/hadoop/hadoop/sbin/start-yarn.sh")
 

# prometheus et grafana seront lancés ailleurs   

=begin
 
puts "Installing prometheus & grafana ..."
   
f = File::open('conf/prometheus.yml', 'r+')

text = f.read.delete("\u0000")

y = YAML.load(text)
targets = nodes.map { |n| "#{n}:9100" }
y["scrape_configs"][0]["static_configs"][0]['targets'] = targets
f.truncate(0)
f.write(y.to_yaml)
f.close

`./clean_prometheus.yml`

Net::SSH.start(master, "root") do |ssh|
	    ssh.exec!("apt install -y prometheus && service prometheus stop")
	        `scp conf/prometheus.yml root@#{master}:/etc/prometheus/prometheus.yml`
		    ssh.exec!("prometheus -web.listen-address :80 &")
		        ssh.exec!("wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.2.2_amd64.deb")
			    ssh.exec!("dpkg -i grafana_5.2.2_amd64.deb")
			        ssh.exec!("sed -i '/http_port/c\http_port=8080' /etc/grafana/grafana.ini")
				    ssh.exec!("systemctl start grafana-server")
end


puts "End of deployment"
base = master[0..-12]
puts "Namenode/distem-coordinator = #{master}"
puts "Prometheus runs at #{base}proxy-http.grid5000.fr"
puts "Grafana runs at #{base}proxy-http8080.grid5000.fr"


=end

end #method

end # class


