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
        
        
testDat = graphdat[graphdat$Subspace %in% c("AllperCh","LSTM","LSTM_Reg","AllChPCA")
                   & graphdat$RES==3 & graphdat$Method == "RF",]        

testDat$Subspace = factor(testDat$Subspace, levels = c("AllperCh","AllChPCA","LSTM","LSTM_Reg"),
                          labels = c("AllPerCh_Feats","PCA_Feats","LSTM_Feats","LSTM_LMM_Feats"))
ggplot(testDat, aes(x=Subspace, y=ACC, fill=Subspace)) + 
    geom_bar(stat="summary",fun="mean",position="dodge")+
    stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
    labs(x="Feature Subspace",y="3-level RT Classification Accuracy", size=16)

graph2ppt(file="Fig4.pptx",width = 9, height = 5)