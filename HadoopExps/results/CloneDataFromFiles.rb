#!/user/bin/ruby 

class CloneDataFromFiles

#from file 
attr_accessor:files_names
def initialize() 
@files_names=Array.new
end 

# I select all in files, if there is some change, it will be here and in (cloneData) to select the raws !
def takeFilesNames
Dir['result*.*'].each do |file_name|
 @files_names.push(file_name)
end
end


#allow the factor with triple values, 
def cloneDataPerf
raws = Array.new 
line = "Stockage,Experiment,ExecTime"
raws.push(line)

for i in 0..@files_names.size-1 
temp = `less #{@files_names[i]} | grep overall` 
extension = @files_names[i].split(/\.(\S*)/)
arrExp = temp.split("\n")
  for j in 0..arrExp.size-1
	line = ""
	exps = arrExp[j].split(/(Exp\s\s[1-9]), overall time taken is (\d*)\sm\s(\d*)/)
	line ="#{extension[1].upcase},#{exps[1]},#{exps[2]}.#{exps[3]}"
	raws.push(line) if !line.empty?
  end #exp

end # files
puts raws.join("\n")


end #method 

end #class 



####################
s = CloneDataFromFiles.new
s.takeFilesNames
s.cloneDataPerf

