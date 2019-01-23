#!/usr/bin/ruby

require 'cute'
require 'net/ssh'
require 'cute/net-ssh'
require 'net/scp'


load 'Exp.rb'
load 'ExpLimitation.rb'


class Launcher 



def start_exps

`mkdir results`

exp = Exp.new

for i in 1..4 do

`rm ~/.ssh/config`

if i == 1 or i == 3
exp.start("")
limitation("hdd","sda",i)
else
exp.start("sdf")
limitation("ssd","sdf",i)
end
end # for





end #start_exp


##########################
###########################
##########################

def limitation(diskType, disk, run)

@filesCursor = File.open("./results/result#{run}.#{diskType}", "w")

limit = ExpLimitation.new

for j in 1..5 do   # five sub-experiments

sleep(50)

limit.start_exp(run,j, diskType, disk, @filesCursor)

end # for


@filesCursor.close()


end  #limitation_hdd


end #class




c = Launcher.new
c.start_exps()
