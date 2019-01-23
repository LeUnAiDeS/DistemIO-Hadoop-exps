# measured data with first col. as  (experiment config).
data <- read.table("dataV1", header=TRUE,sep="_")
#readData = ObservedData[ , -grep("^write*", colnames(ObservedData))]
#writeData =  ObservedData[ , -grep("^read*", colnames(ObservedData))]


#######################
###### PLOTS ##########
#######################
require(plotrix)
library(ggplot2)
require(cowplot)

percentage = (data$throughput / data$ideal) * 100 
data$percentage = percentage
data$percentageIdeal = 100


data$percentage
index <- data$percentage > 500
index
data$percentage[index] <- 500
data$percentage



dir_sync <- subset (data, IOengine=="mmap" & syscall=="write" & type =="direct" , select=IOengine:percentageIdeal)





pdf("plot.pdf",onefile=FALSE, height=3, width=6)
ggplot(data= dir_sync, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "32 MB/s", "64 MB/s", "128 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1M", "10M", "100M", "1024M")))) + geom_point(aes(colour= factor(filesize, levels=c("1M", "10M", "100M", "1024M")))) +  ylim(0,500) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(x = "I/O Limitations ", y ="Percentage (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))




