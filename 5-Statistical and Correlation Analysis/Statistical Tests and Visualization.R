
rm(list=ls(all=TRUE))

x = readline()
E:\Mirian\LSTM Model\Correlation Analyses
setwd(x)
#C:\Users\kazemi\Documents\My Files\PhD Research\Reports\HoneyBee
getwd()


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
       psych,
       Cairo, #alternate image writing package with superior performance.
       corrplot,
       knitr,
       PerformanceAnalytics,
       afex,
       ggpubr,
       readxl,
       export,
       stringr)


########################### New Load For Matlab 2021 single ##########################
Path = paste(getwd(),'/LSTM-RT-Results',sep = "")

Originals  = dir(pattern = "ORIGINAL", Path)
Subband  = dir(pattern = "SB", Path)
Full  = dir(pattern = "Full", Path)


DatAll = NULL
for(fInd in 1:length(Originals)){
        TrainOnFullFileName = paste(Path,Full[fInd],sep = "/")
        TrainOnSBFileName = paste(Path,Subband[fInd],sep = "/")
        RT = read_excel(paste(Path,Originals[fInd],sep = "/"))
        
        dat = RT
        sheetNames = excel_sheets(TrainOnFullFileName)
        for(ShName in sheetNames){
                temp      = read_excel(TrainOnFullFileName, sheet = ShName)
                names(temp) = c("Trial","EstRT")
                dat[,ShName]     = temp$EstRT
        }
        dat$Model = unique("Full")
        dat$Stim = case_when(grepl("GVS8",TrainOnFullFileName)~"GVS8",
                             grepl("GVS7",TrainOnFullFileName)~"GVS7", 
                             TRUE~"Sham")
        dat$Run = unique(str_extract(TrainOnFullFileName,"Run[0-9]+?(?=_)"))
        dat$FileName = unique(str_extract(TrainOnFullFileName,"Run.*"))
        DatAll = rbind(DatAll,dat)
        
        dat = RT
        dat$full = unique(NA)
        sheetNames = excel_sheets(TrainOnSBFileName)
        for(ShName in sheetNames){
                temp      = read_excel(TrainOnSBFileName, sheet = ShName)
                ShName = gsub("_","",ShName)
                names(temp) = c("Trial","EstRT")
                dat[,ShName]     = temp$EstRT
        }
        dat$Model = unique("Subband")
        dat$Stim = case_when(grepl("GVS8",TrainOnSBFileName)~"GVS8",
                             grepl("GVS7",TrainOnSBFileName)~"GVS7", 
                             TRUE~"Sham")
        dat$Run = unique(str_extract(TrainOnSBFileName,"Run[0-9]+?(?=_)"))
        dat$FileName = unique(str_extract(TrainOnSBFileName,"Run.*"))
        DatAll = rbind(DatAll,dat)
}
write.csv(DatAll, file = "AllRuns.csv",row.names = F)
TempDat = DatAll

temp = as.data.frame(summarise(group_by(DatAll,Run,Model,Stim),N=n()/2))
DatAll = merge(DatAll,temp)

DatAll$TrialIdx = as.numeric(gsub("Trial","",DatAll$Trials,ignore.case = T))
DatAll$TrialIdx = DatAll$TrialIdx%%DatAll$N
DatAll$TrialIdx[DatAll$TrialIdx==0]=unique(20)
DatAll$TrialIdx = paste("Trial",DatAll$TrialIdx,sep = "")

DatAll = DatAll[order(DatAll$Model,DatAll$Stim,DatAll$Run,DatAll$Trials),]

DatAll = as.data.frame(summarise(group_by(DatAll,Run,TrialIdx,Model,Stim),N=n(),
                                 RT = mean(RT),
                                 full = mean(full),
                                 Alpha = mean(Alpha),
                                 Beta = mean(Beta),
                                 Delta = mean(Delta),
                                 Gamma = mean(Gamma),
                                 Theta = mean(Theta),
                                 AlphaAmpFiltered = mean(AlphaAmpFiltered),
                                 AlphaPhaseFiltered = mean(AlphaPhaseFiltered),
                                 BetaAmpFiltered = mean(BetaAmpFiltered),
                                 BetaPhaseFiltered = mean(BetaPhaseFiltered),
                                 DeltaAmpFiltered = mean(DeltaAmpFiltered),
                                 DeltaPhaseFiltered = mean(DeltaPhaseFiltered),
                                 GammaAmpFiltered = mean(GammaAmpFiltered),
                                 GammaPhaseFiltered = mean(GammaPhaseFiltered),
                                 ThetaAmpFiltered = mean(ThetaAmpFiltered),
                                 ThetaPhaseFiltered = mean(ThetaPhaseFiltered)))

Cordat = as.data.frame(summarise(group_by(DatAll,Run,Model,Stim),N=n(),
                                 full = cor(RT,full),
                                 Alpha = cor(RT,Alpha),
                                 Beta = cor(RT,Beta),
                                 Delta = cor(RT,Delta),
                                 Gamma = cor(RT,Gamma),
                                 Theta = cor(RT,Theta),
                                 AlphaAmpFiltered = cor(RT,AlphaAmpFiltered),
                                 AlphaPhaseFiltered = cor(RT,AlphaPhaseFiltered),
                                 BetaAmpFiltered = cor(RT,BetaAmpFiltered),
                                 BetaPhaseFiltered = cor(RT,BetaPhaseFiltered),
                                 DeltaAmpFiltered = cor(RT,DeltaAmpFiltered),
                                 DeltaPhaseFiltered = cor(RT,DeltaPhaseFiltered),
                                 GammaAmpFiltered = cor(RT,GammaAmpFiltered),
                                 GammaPhaseFiltered = cor(RT,GammaPhaseFiltered),
                                 ThetaAmpFiltered = cor(RT,ThetaAmpFiltered),
                                 ThetaPhaseFiltered = cor(RT,ThetaPhaseFiltered)))


#### -------------------------- Figure 1 -----------
 
Testdat = Dat[Dat$Stim=="Sham",]
Testdat = Testdat[complete.cases(Testdat),]
Testdat = Testdat[(Testdat$Model=="Full" & Testdat$Test=="Full") | (Testdat$Model=="Subband"),]
Testdat$Test = factor(Testdat$Test,levels = c("Full","Delta","Theta","Alpha","Beta","Gamma"),
                       labels = c("Broadband","Delta","Theta","Alpha","Beta","Gamma"))

ggplot(Testdat[Testdat$Perturb=="Original",],aes(x=Test, y=Corval)) + 
        geom_bar(stat="summary",fun="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        # facet_grid(~Perturb)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="Model",y="Mean Correlation", size=16)+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))



#### -------------------------- Result GVS -----------

Testdat = Dat[Dat$Stim=="GVS8",]
Testdat = Testdat[complete.cases(Testdat),]
Testdat = Testdat[(Testdat$Model=="Full" & Testdat$Test=="Full") | (Testdat$Model=="Subband"),]
Testdat$Test = factor(Testdat$Test,levels = c("Full","Delta","Theta","Alpha","Beta","Gamma"),
                      labels = c("Broadband","Delta","Theta","Alpha","Beta","Gamma"))


#### -------------------------- Figure 2 -----------

Testdat = Dat[Dat$Stim=="Sham",]
Testdat = Testdat[complete.cases(Testdat),]
Testdat = Testdat[(Testdat$Model=="Subband") & Testdat$Test %in% c("Alpha","Delta"),]
Testdat$Test = factor(Testdat$Test,levels = c("Full","Delta","Theta","Alpha","Beta","Gamma"),
                      labels = c("Broadband","Delta","Theta","Alpha","Beta","Gamma"))


ggplot(Testdat[Testdat$Perturb!="Original",],aes(x=Test, y=Corval, fill = Perturb)) + 
        geom_bar(stat="summary",fun="mean",position="dodge")+
        # geom_point(position = "jitter",aes(color=Perturb, fill=Perturb))
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        # facet_grid(~Perturb)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="Model",y="Mean correlation", size=16)+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))


#### -------------------------- Figure 3 -----------

Testdat = Dat[Dat$Stim%in%c("Sham","GVS7","GVS8"),]
Testdat = Testdat[complete.cases(Testdat),]
Testdat = Testdat[(Testdat$Model=="Subband") & Testdat$Test %in% c("Delta","Theta","Alpha","Beta","Gamma"),]
Testdat$Test = factor(Testdat$Test,levels = c("Full","Delta","Theta","Alpha","Beta","Gamma"),
                      labels = c("Broadband","Delta","Theta","Alpha","Beta","Gamma"))


ggplot(Testdat[Testdat$Perturb=="Original",],aes(x=Test, y=Corval, fill = Perturb)) + 
        geom_bar(stat="summary",fun="mean",position="dodge")+
        # geom_point(position = "jitter",aes(color=Perturb, fill=Perturb))
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Stim,nrow=3)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="Model",y="Mean correlation", size=16)+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))

####################################################################################
