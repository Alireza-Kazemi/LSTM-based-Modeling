########################### Initialization ##########################
rm(list=ls(all=TRUE))


library(pacman)
p_load(reshape2,
       ez,
       lme4,
       lmerTest,
       ggplot2,
       grid,
       tidyr,
       plyr,
       dplyr,
       effects,
       gridExtra,
       DescTools,
       Cairo, #alternate image writing package with superior performance.
       corrplot,
       knitr,
       PerformanceAnalytics,
       afex,
       ggpubr,
       readxl,
       officer,
       psych,
       rstatix,
       emmeans,
       standardize,
       performance)


###################################################### Load data -----
d=read.table("ML_Results.csv", header=TRUE, sep=",", strip.white = TRUE)

d$RES = as.factor(d$RES)
d$Subspace = as.factor(d$Subspace)
d$Method = as.factor(d$Method)
d$RUN = as.factor(d$RUN)
graphdat = d

ggplot(graphdat, aes(x=Method, y=ACC, fill=Subspace)) + 
    geom_bar(stat="summary",fun="mean",position="dodge")+
    stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~RES)
        
        
