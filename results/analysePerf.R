
require(ggplot2)
require(Rmisc)
library(cowplot)


# Use dose as a factor rather than numeric
d <- read.table("data", header=TRUE, sep=",")

tgc <- summarySE(d, measurevar="ExecTime", groupvars=c("Stockage","Experiment"))
tgc2 <- tgc
#tgc2$Experiment <- factor(d$Experiment)


pdf("results_errorsSDM.pdf",onefile=FALSE, height=5, width=10)
# Error bars represent standard error of the mean
ggplot(tgc2, aes(x=Experiment, y=ExecTime, fill=Stockage)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=ExecTime-se, ymax=ExecTime+se),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+ labs(x = "Experiments ", y ="Execution time (min)", fill="Storage support") + theme(text = element_text(size = 18), strip.text = element_text(size=18), axis.text= element_text(size=18), axis.title.x = element_text(size= 18), axis.title.y = element_text(size= 18))


pdf("results_errorsCI95.pdf",onefile=FALSE, height=5,width=10)
# Use 95% confidence intervals instead of SEM
ggplot(tgc2, aes(x=Experiment, y=ExecTime, fill=Stockage)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=ExecTime-ci, ymax=ExecTime+ci),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9))+labs(x = "Experiments ", y ="Execution time (min)", fill="Storage support") + theme(text = element_text(size = 18), strip.text = element_text(size=18), axis.text= element_text(size=18), axis.title.x = element_text(size= 18), axis.title.y = element_text(size= 18))



