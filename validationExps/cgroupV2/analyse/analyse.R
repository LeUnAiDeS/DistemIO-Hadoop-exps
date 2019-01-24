# measured data with first col. as  (experiment config).
datahdd <- read.table("resultHDD", header=TRUE,sep="_")
datassd <- read.table("resultsSSD", header=TRUE,sep="_")
#readData = ObservedData[ , -grep("^write*", colnames(ObservedData))]
#writeData =  ObservedData[ , -grep("^read*", colnames(ObservedData))]


#######################
###### PLOTS ##########
#######################
require(plotrix)
library(ggplot2)
require(cowplot)


datahdd$filesize <- gsub("M", " MB", datahdd$filesize)
datassd$filesize <- gsub("M", " MB", datassd$filesize)

index1 <-  datassd$filesize =="1024 MB"
index2 <-  datassd$filesize =="2048 MB"

datassd$filesize[index1] <- "1 GB"
datassd$filesize[index2] <- "2 GB"
datassd$filesize


####### percentage 
percentage = (datahdd$throughput / datahdd$ideal) * 100 
datahdd$percentage = percentage
datahdd$percentageIdeal = 100
datahdd$percentage
index <- datahdd$percentage > 130

datahdd$percentage[index] <- 130


percentage = (datassd$throughput / datassd$ideal) * 100 
datassd$percentage = percentage
datassd$percentageIdeal = 100


index <- datassd$percentage > 130

datassd$percentage[index] <- 130



#figures


pdf("sync_read_direct.pdf",onefile=FALSE, height=6, width=6)
dir_sync_hdd <- subset (datahdd, IOengine=="sync" & syscall=="read" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data = dir_sync_hdd, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s","32 MB/s", "64 MB/s", "128 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A) HDD_sync_read_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())




pdf("sync_write_direct.pdf",onefile=FALSE, height=6, width=6)
dir_sync_hdd_w <- subset (datahdd, IOengine=="sync" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data = dir_sync_hdd_w, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s","32 MB/s", "64 MB/s", "128 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A) HDD_sync_write_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 9), axis.title.y = element_text(size= 9))


dir_sync_ssd_w <- subset (datassd, IOengine=="sync" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_w, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())




pdf("article_mmap_write_direct.pdf",onefile=FALSE, height=2, width=12)
dir_sync_hdd_w <- subset (datahdd, IOengine=="mmap" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data = dir_sync_hdd_w, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s","32 MB/s", "64 MB/s", "128 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "a) Mamp - write - direct - HDD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12)) + theme(plot.title = element_text(size=10)) 


dir_sync_ssd_w <- subset (datassd, IOengine=="mmap" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_w, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "b) Mmap - write - direct - SSD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12)) + theme(plot.title = element_text(size=10)) 

plot_grid(tp1, tp2, ncol=2)

invisible(dev.off())






pdf("article_sync_read_bufdir.pdf",onefile=FALSE, height=2, width=12)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB"))))  + ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "a) Sync - read - direct - SSD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12)) + theme(plot.title = element_text(size=10))




dir_sync_ssd_b <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) + labs(title= "b) Sync - read - buffered - SSD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12)) + theme(plot.title = element_text(size=10)) 

 
plot_grid(tp1, tp2, ncol=2)

invisible(dev.off())



pdf("mmap_write_direct.pdf",onefile=FALSE, height=6, width=6)
dir_sync_hdd_w <- subset (datahdd, IOengine=="mmap" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data = dir_sync_hdd_w, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s","32 MB/s", "64 MB/s", "128 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "64 MB", "128 MB", "256 MB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A) HDD_mmap_write_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_w <- subset (datassd, IOengine=="mmap" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_w, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())

pdf("sync_write_bufdir.pdf",onefile=FALSE, height=6, width=6)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A)  SSD_sync_write_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_b <- subset (datassd, IOengine=="sync" & syscall=="write" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD_sync_write_buffered", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())



pdf("sync_read_bufdir.pdf",onefile=FALSE, height=6, width=6)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A)  SSD_sync_read_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_b <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD_sync_read_buffered", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())


pdf("syncmmap_read_buffered.pdf",onefile=FALSE, height=6, width=6)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A)  SSD_sync_read_buffered", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_b <- subset (datassd, IOengine=="mmap" & syscall=="read" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD_mmap_read_buffered", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())






pdf("syncmmap_read_direct.pdf",onefile=FALSE, height=6, width=6)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="read" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A)  SSD_sync_read_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_b <- subset (datassd, IOengine=="mmap" & syscall=="read" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD_mmap_read_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())






pdf("syncmmap_write_buffered.pdf",onefile=FALSE, height=6, width=6)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="write" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A)  SSD_sync_write_buffered", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_b <- subset (datassd, IOengine=="mmap" & syscall=="write" & type =="buffered" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD_mmap_write_buffered", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())






pdf("syncmmap_write_direct.pdf",onefile=FALSE, height=6, width=6)
dir_sync_ssd_d <- subset (datassd, IOengine=="sync" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp1<- ggplot(data= dir_sync_ssd_d, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "A)  SSD_sync_write_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))


dir_sync_ssd_b <- subset (datassd, IOengine=="mmap" & syscall=="write" & type =="direct" & filesize!="1 MB" , select=IOengine:percentageIdeal)
tp2<-ggplot(data= dir_sync_ssd_b, aes(x= factor(limitation, levels=c("512 KB/s", "1 MB/s", "64 MB/s", "128 MB/s", "256 MB/s", "512 MB/s", "1 GB/s")), y = percentage, group = filesize))+ geom_line(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) + geom_point(aes(colour= factor(filesize, levels=c("1 MB", "10 MB", "256 MB", "1 GB", "2 GB")))) +  ylim(0,130) + geom_hline(yintercept=100) + geom_hline(yintercept=130, color="gray", lty=2) +labs(title= "B) SSD_mmap_write_direct", x = "I/O Limitations ", y ="Precision (%)", color = "File size") + theme(text = element_text(size = 10), strip.text = element_text(size=10), axis.text= element_text(size=9), axis.title.x = element_text(size= 12), axis.title.y = element_text(size= 12))

plot_grid(tp1, tp2, ncol=1)

invisible(dev.off())





