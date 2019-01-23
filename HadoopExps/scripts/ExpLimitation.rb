#!/usr/bin/ruby

require 'cute'
require 'net/ssh'
require 'cute/net-ssh'
require 'net/scp'



class ExpLimitation 

@g5k_SITE
@jobid
@g5k
@nodes
@slaves
@subnet
@nameNomde

@mappers
@reducers

@mappers_vnNames
@reducers_vnNames
@mappers_vn
@reducers_vn
@approxThroughput

def initialize()

@g5k_SITE = 'rennes'
@jobid = ENV['OAR_JOB_ID']
@g5k = Cute::G5K::API.new
@job = @g5k.get_job(@g5k_SITE, @jobid)


#approxThroughput
@approxThroughput=120000000 

#nodes phisiques
@nodes = `uniq $OAR_NODE_FILE`.split()
@slaves = @nodes[1..-1]
puts "the participated ndes in this experiment are #{@nodes}"
#subnet
@subnet = @job['resources_by_type']['subnets'][0][0..-5]
puts "the subnet is #{@subnet}"

#namenode
@nameNode="#{@subnet}1"
puts "The nameNode is #{@nameNode}"

#datanodes
@datanodes_ip = []
@datanodes = []

@mappers  = []
@reducers = []

@mappers_vnNames = []
@reducers_vnNames = []

@mappers_vn = []
@reducers_vn = []


for i in 0..@slaves.size-1
    if i % 2 == 0

            @datanodes_ip.push("#{@subnet}#{i+2}")
            @datanodes.push("node#{i+2}")
            @mappers_vnNames.push("node#{i+2}")
            @mappers.push("#{@slaves[i]}")
            @mappers_vn.push("#{@subnet}#{i+2}")

    else

        @datanodes_ip.push("#{@subnet}#{i+2}")
        @datanodes.push("node#{i+2}")
        @reducers_vnNames.push("node#{i+2}")
        @reducers.push("#{@slaves[i]}")
        @reducers_vn.push("#{@subnet}#{i+2}")
    end
end
puts "the mappers are #{@mappers}"
puts "mappers virtual nodes are #{@mappers_vn}"

puts "the reducers are #{@reducers}"
puts "reducers virtual nodes are #{@reducers_vn}"

end # initialize




def start_exp(run, expNo, diskType, disk, file)



Net::SSH::Multi.start do |cord|
    cord.use("root@#{@nameNode}")
    p cord.exec!("chsh -s /bin/bash hadoop ")
    break
end


#trying with 5G for SSD
data = (@datanodes.size)*50_000_000


puts "Hadoop is going to generate #{data} GB"

Net::SSH::Multi.start do |dnode|
         dnode.use("hadoop@#{@nameNode}")
         puts "clearing the input-output folders if found .."
         dnode.exec!("./hadoop/bin/hdfs dfs -rm -r /input")
         dnode.exec!("./hadoop/bin/hdfs dfs -rm -r /output")
         dnode.exec!("sleep 60")
	 cmd = "./hadoop/bin/yarn jar hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.4.jar teragen -Dmapreduce.job.maps=#{@datanodes.size} -D mapred.reduce.tasks=#{@datanodes.size/2} #{data} /input"
         puts cmd
	 p dnode.exec!(cmd)
	 puts "Hadoop  data is is well generated"
         break
end


puts "the like-real throughput is #{@approxThroughput} KB"

 


sleep(150)
# restart hadoop instances ..
    Net::SSH::Multi.start do |dnode|
        dnode.use("hadoop@#{@nameNode}")
    puts "stopping Hadoop"
    dnode.exec!("./hadoop/sbin/stop-all.sh")
    puts "Hadoop is stopped successfully"
    break
end

#clean cache of all nodes including the cordinator

puts "clear the cache of all nodes"
@nodes.each{ |n| `ssh root@#{n} "echo 3 > /proc/sys/vm/drop_caches"` }


#start hadoop again
Net::SSH::Multi.start do |dnode|
        dnode.use("hadoop@#{@nameNode}")
    puts "restarting hadoop ecosystem"
    dnode.exec!("./hadoop/sbin/start-all.sh")
    puts "Hadoop is started successfully"
    break
end


sleep(200) # to be sure that the datanodes are activated

if expNo == 1 
puts "First experiment : no limitation is applied"
elsif expNo == 2 
puts "Second experiment : one node (a mapper) is limited to 5MB"
limitation(1, [@mappers_vnNames.shuffle.first], 5000000, @nodes.first, disk)
elsif expNo == 3 
puts "Third Experiment : All nodes are limited to 0.5 of throughout"
limitation(@datanodes.size, @datanodes, @approxThroughput/2, @nodes.first, disk)
elsif expNo == 4  
puts "Forth experiment : All nodes are limited to 0.25 of throughput"
limitation(@datanodes.size, @datanodes, @approxThroughput/4, @nodes.first, disk)
elsif expNo == 5
puts "Half of nodes are limited to 0.5 of throughput, the other half are limited to 0.25 of throughput"
firstHalf = @datanodes[0..(@datanodes.size-1)/2]
secondHalf = @datanodes[(@datanodes.size)/2..@datanodes.size-1]

limitation(firstHalf.size, firstHalf,  @approxThroughput/2, @nodes.first, disk) #50% ->50, 50% ->25
limitation(secondHalf.size, secondHalf,  @approxThroughput/4, @nodes.first, disk)
end # if


flagSafeMode = false
safeModeR = ""
while flagSafeMode == false 
Net::SSH::Multi.start do |cord|
    cord.use("hadoop@#{@nameNode}")
    safeModeR = cord.exec!("./hadoop/bin/hdfs dfsadmin -safemode get")   
    break
end# do ssh 

puts("safemode ?  #{safeModeR}")
if safeModeR.include? "is ON"
       sleep(100)
else
   flagSafeMode = true
end # if

end #while


sleep(100)


res = ""
exactTimeTaken = ""
ressync = ""

# execute the workload
file.puts "Exp  #{expNo} started at  #{Time.now}"
puts "Exp #{expNo} started at  #{Time.now}"
Net::SSH::Multi.start do |dnode|
        dnode.use("hadoop@#{@nameNode}")
        #dnode.exec!("./hadoop/bin/hdfs dfsadmin -safemode leave") # added to avoid can't delete output folder, name nnode is in safe mode 
        dnode.exec!("./hadoop/bin/hdfs dfs -rm -r /output")
        res = dnode.exec!("time ./hadoop/bin/yarn jar hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.4.jar terasort -Dmapreduce.job.maps=#{@datanodes.size} -Dmapred.reduce.tasks=#{@datanodes.size/2} /input /output")
   
       break
end  #do 
    variabeletempo  = res.to_s
    element = variabeletempo.scan(/real\\t(\d+)\S(\d+\.*\d*)\S/).first        
    #exactTimeTaken = element.at(0).to_i * 60 + element.at(1).to_f
    exactTimeTaken = "#{element.at(0)} m #{element.at(1)} s"
file.puts "Exp #{expNo}'s result is #{res}"
file.puts "Exp  #{expNo}, overall time taken is #{exactTimeTaken}"
file.puts "Exp  #{expNo} termintated at #{Time.now}"
puts "Exp #{expNo} terminated at #{Time.now}"


#try to sync the written data on all nodes

sleep(350)

file.puts ""
file.flush




end #func





#### Function limitation
def limitation(sizeN,nodes, value, cordinator, device) 

puts (sizeN)
puts (nodes)
puts (value) 
puts (cordinator)
puts (device)


#write the script
fpath = File.expand_path('limit.rb')
File.open(fpath, "w") { |s|
s.puts("require 'distem' ")
s.puts("	Distem.client do |cl|")
for i in 0..sizeN-1
s.puts("cl.vfilesystem_update('#{nodes[i]}', {'disk_throttling' =>")
s.puts("                     {'hierarchy' => 'v2',")
s.puts("                        'limits' =>")
s.puts("                            [{'device' => '/dev/#{device}', 'read_limit' => #{value},'write_limit' => #{value}}]")
s.puts("		                          }         }) ")

end #for
s.puts("end")
}

#transfer it 
Net::SCP.start("#{cordinator}", "root") do |scp| #without pass, using keys
      scp.upload! "limit.rb", "limit.rb"
  end

#execute it
Net::SSH::Multi.start do |dnode|
        dnode.use("root@#{cordinator}")
        dnode.exec!("ruby limit.rb")
end #ssh

#delete the script file
`rm limit.rb`

end #func


end #class 

