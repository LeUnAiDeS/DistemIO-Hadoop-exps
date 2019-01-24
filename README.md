# Preambule
This repository includes the validation experiments (scripts and results) of adding the I/O limitation service into the Distem emulator. It also includes the results and necessary scripts for reproducing the Hadoop experiments described in the DistemIO paper.

## Validation Expierments



## Hadoop Experimemnts

### Experiments repoducibility
To reproduce these experiments, you should install the Distem emulator (http://distem.gforge.inria.fr/) on your infrastructure. It is noticable that Distem can be on several testbeds including Grid'5000, CloudLab, and Chameleon. 

If reproducing on a tesbted, you should firstly reserve yor machines. For example, the following code reserves 30 machine on the Grid'5000 for two hours starting from 2019-01-18 16:00:00

```
$ oarsub -t deploy -l slash_22=1+{"cluster='parasilo' and type='disk' or type='default' and disk_reservation_count > 0"}nodes=30,walltime=2:00:00 -r "2019-1-1 20:30:00"

```

Then, you should pull that repository and gets into the scripts folder. You should enusre that the terminal is connected to the job that your reserved. This could be done on the Grid'5000 testbed by execution this command: 

```
$ oarsub -C JOB_NUMBER
```

The last step is to run the Launcher scrip as follows. This will run the script at the background, deploying the Distem environemnt on the reserved nodes and performing the experiments in the paper. 

```
nohup ruby Launcher.rb & 
```

A new directory called results will be created. It will contain the results of all runs in separated files. You can also refer to the experiment log (nohup.out) file to have an an idea about the execution progress. 





### Experiment results
The results folder contain several results used in the experiment section in the described paper. It also contails two scripts that serve to prepare exploitable results (CloneDataFromFiles.rb) and an R script to generate the figures (analysePerf.R). To regenrate the figures from the existing results. You should execute these commands from inside the results directory

```
.../results$ ruby CloneDataFromFiles.r > data  // this create the data file which will be exploited by the analysis script
.../results$ Rscript analysePerf.R             // this will generate the experiments figures
``` 








