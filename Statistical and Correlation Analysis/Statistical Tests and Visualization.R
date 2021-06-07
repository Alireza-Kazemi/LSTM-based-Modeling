
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
        RT = read_xlsx(paste(Path,Originals[fInd],sep = "/"))
        
        dat = RT
        sheetNames = excel_sheets(TrainOnFullFileName)
        for(ShName in sheetNames){
                temp      = read_xlsx(TrainOnFullFileName, sheet = ShName)
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
                temp      = read_xlsx(TrainOnSBFileName, sheet = ShName)
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



########################################### Correaltion plots ################################
Model = c("Full")
Stim = "Sham"
Run = "Run1"
DesiredVars = c("RT","full","Alpha", "Beta", "Delta", "Gamma","Theta")
# "Trials", "RT","full", "Alpha", "Beta", "Delta", "Gamma",
# "Theta", "AlphaAmpFiltered", "AlphaPhaseFiltered", "BetaAmpFiltered", "BetaPhaseFiltered",
# "DeltaAmpFiltered", "DeltaPhaseFiltered"
# "GammaAmpFiltered", "GammaPhaseFiltered", "ThetaAmpFiltered", "ThetaPhaseFiltered", "Model", "Stim", "Run"


dat = DatAll[DatAll$Model%in%Model & DatAll$Stim==Stim & DatAll$Run==Run, DesiredVars]
pairs.panels(dat, scale=F,cex.labels=1.5,cex.cor = 2,stars = T)


########################################### Results ################################
Dat = Cordat[Cordat$full>0.0 | is.na(Cordat$full),]

names(Dat) = gsub("Filtered", "Perturbed", names(Dat), ignore.case = FALSE, perl = FALSE,
                    fixed = FALSE, useBytes = FALSE)
Dat = melt(Dat,variable.name = "Test",value.name="Corval",id.vars = c("Run","Model","Stim","N"))
Dat$Perturb = case_when(grepl("PhasePerturbed",Dat$Test, ignore.case = TRUE) ~ "Phase",
                        grepl("AmpPerturbed",Dat$Test, ignore.case = TRUE) ~ "Amp",
                      TRUE ~ "Original") 
Dat$Test = case_when(grepl("Alpha",Dat$Test, ignore.case = TRUE) ~ "Alpha",
                     grepl("Beta",Dat$Test, ignore.case = TRUE) ~ "Beta",
                     grepl("Delta",Dat$Test, ignore.case = TRUE) ~ "Delta",
                     grepl("Theta",Dat$Test, ignore.case = TRUE) ~ "Theta",
                     grepl("Gamma",Dat$Test, ignore.case = TRUE) ~ "Gamma",
                     grepl("Full",Dat$Test, ignore.case = TRUE) ~ "Full")

# ggplot(Dat[Dat$Perturb == "Original",],aes(x=Test, y=Corval, fill = Test)) + 
#         geom_bar(stat="summary",fun.y="mean",position="dodge")+
#         stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
#         facet_grid(~Model)+
#         theme(strip.text.x = element_text(size=16, face="bold"))+
#         labs(x="",y="", size=16)+
#         ggtitle("Data RT")+
#         theme(axis.title.y = element_text(size = 18))+
#         theme(axis.text.x = element_text(size = 16))+
#         theme(strip.text.x = element_text(size=16, face="bold"),
#               strip.text.y = element_text(size=16, face="bold"))

ggplot(Dat[Dat$Perturb == "Original",],aes(x=Test, y=Corval, fill = Test)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_grid(Stim~Model)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))

ggplot(Dat,aes(x=Test, y=Corval, fill = Perturb)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_grid(Stim~Model)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))





####################################################################################



Dat$Test = case_when(grepl("Alpha",Dat$Test, ignore.case = TRUE) ~ "Alpha",
                    grepl("Beta",Dat$Test, ignore.case = TRUE) ~ "Beta",
                    grepl("Delta",Dat$Test, ignore.case = TRUE) ~ "Delta",
                    grepl("Theta",Dat$Test, ignore.case = TRUE) ~ "Theta",
                    grepl("Gamma",Dat$Test, ignore.case = TRUE) ~ "Gamma",
                    grepl("Full",Dat$Test, ignore.case = TRUE) ~ "Full")

Dat$Test = as.factor(Dat$Test)
Dat$Phase = as.factor(Dat$Phase)
Dat$Model = as.factor(Dat$Model)

DataAvg = Dat;
DataAvg$MeanRTDiff = DataAvg$DeltaRT;#abs(DataAvg$DeltaRT^2)

ggplot(DataAvg,aes(x=Model, y=MeanRTDiff, fill = Phase)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))

# -----------------------> identical Model and test
DatAnova = DataAvg[DataAvg$Phase %in% c("Original"),]
DatAnova = DatAnova[DatAnova$Test %in% c("Full") & DatAnova$Model %in% c("Full") | DatAnova$Model %in% c("Subband"),]

ListofComparisons = list(c("Full","Gamma"),
                         c("Full","Alpha"),
                         c("Full","Beta"),
                         c("Full","Delta"),
                         c("Full","Theta"))

ggplot(DatAnova,aes(x=Test, y=MeanRTDiff, fill = Test)) + 
        geom_bar(stat="summary",fun="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        # facet_wrap(~Stim)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Identical Model and Test: Full on Full and sub on sub ")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))
        # stat_compare_means( comparisons = ListofComparisons,
        #                     label = "p.format",paired = T,method = "t.test")
# -----------------------> Between Models
DatAnova = DataAvg[!DataAvg$Test %in% c("Full","Theta","Alpha","Beta"),]

ggplot(DatAnova,aes(x=Model, y=MeanRTDiff, fill = Test)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Phase)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))

        # stat_compare_means( comparisons = list(c("Original","Perturbed")),
        #                         label = "p.signif",paired = T)

results=as.data.frame(ezANOVA(data=DatAnova
                              , dv=MeanRTDiff,wid=.(ID),within=.(Model,Test,Phase),
                              ,type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

ggplot(DatAnova,aes(x=Model, y=MeanRTDiff, fill = Test)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))

# -----------------------> Within Full Model
DatAnova = DataAvg[!DataAvg$Test %in% c("Full"),]
DatAnova = DatAnova[DatAnova$Model %in% c("Full"),]

ggplot(DatAnova,aes(x=Phase, y=MeanRTDiff, fill = Phase)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT Full Model Test on Subbands")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))+
 stat_compare_means( comparisons = list(c("Original","Perturbed")),
                         label = "p.signif",paired = T)

results=as.data.frame(ezANOVA(data=DatAnova
                              , dv=MeanRTDiff,wid=.(ID),within=.(Test,Phase),
                              ,type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

DatAnova = DataAvg[DataAvg$Model %in% c("Full"),]
DatAnova = DatAnova[DatAnova$Phase %in% c("Original"),]

ListofComparisons = list(c("Full","Gamma"),
                         c("Full","Alpha"),
                         c("Full","Beta"),
                         c("Full","Delta"),
                         c("Full","Theta"))

ggplot(DatAnova,aes(x=Test, y=MeanRTDiff, fill = Test)) + 
        geom_bar(stat="summary",fun="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        # facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT Model Full test on Original phases")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))
stat_compare_means( comparisons = ListofComparisons,
                         label = "p.format",paired = T,method = "t.test")


graph2ppt(file="Fig2.pptx",width = 8, height = 5)

Model = aov(MeanRTDiff~Test
            ,data = DatAnova)
summary(Model)

# -----------------------> Within Subband Model
DatAnova = DataAvg[!DataAvg$Test %in% c("Full"),]
DatAnova = DatAnova[DatAnova$Model %in% c("Subband"),]

ggplot(DatAnova,aes(x=Phase, y=MeanRTDiff, fill = Phase)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT Model Subband test on subband")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))+

stat_compare_means( comparisons = list(c("Original","Perturbed")),
                        label = "p.signif",paired = T)

results=as.data.frame(ezANOVA(data=DatAnova
                              , dv=MeanRTDiff,wid=.(ID),within=.(Test,Phase),
                              ,type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

DatAnova = DatAnova[DatAnova$Phase %in% c("Original"),]

ggplot(DatAnova,aes(x=Test, y=MeanRTDiff, fill = Test)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        # facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT Model subband test on subband Original phase")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))

# -----------------------> Within Original
DatAnova = DataAvg[!DataAvg$Test %in% c("Full"),]
DatAnova = DatAnova[DatAnova$Phase %in% c("Original"),]

ggplot(DatAnova,aes(x=Model, y=MeanRTDiff, fill = Model)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT Full vs Subband Original Phase")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))+
stat_compare_means( comparisons = list(c("Full","Subband")),
                        label = "p.signif",paired = T)

results=as.data.frame(ezANOVA(data=DatAnova
                              , dv=MeanRTDiff,wid=.(ID),within=.(Test,Model),
                              ,type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

# -----------------------> Within Perturbed
DatAnova = DataAvg[!DataAvg$Test %in% c("Full"),]
DatAnova = DatAnova[DatAnova$Phase %in% c("Perturbed"),]

ggplot(DatAnova,aes(x=Model, y=MeanRTDiff, fill = Model)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
        facet_wrap(~Test)+
        theme(strip.text.x = element_text(size=16, face="bold"))+
        labs(x="",y="", size=16)+
        ggtitle("Data RT Full vs Subband on perturbed phase")+
        theme(axis.title.y = element_text(size = 18))+
        theme(axis.text.x = element_text(size = 16))+
        theme(strip.text.x = element_text(size=16, face="bold"),
              strip.text.y = element_text(size=16, face="bold"))+
        stat_compare_means( comparisons = list(c("Full","Subband")),
                            label = "p.signif",paired = T)

# ggplot(DatAnova,aes(x=Model, y=MeanRTDiff, fill = Test)) + 
#         geom_bar(stat="summary",fun="mean",position="dodge")+
#         stat_summary(fun.data = "mean_se", geom="errorbar",position="dodge")+
#         # geom_jitter(position = position_jitterdodge(),aes(colour = Model))+
#         facet_wrap(~Phase)+
#         theme(strip.text.x = element_text(size=10, face="bold"))+
#         labs(x="Trained on",y="MSE", size=10)+
#         ggtitle("Data RT Full vs Subband on perturbed phase")+
#         theme(axis.title.y = element_text(size = 10))+
#         theme(axis.text.x = element_text(size = 10))+
#         theme(strip.text.x = element_text(size=10, face="bold"),
#               strip.text.y = element_text(size=10, face="bold"))
# stat_compare_means( comparisons = list(c("Full","Subband")),
#                         label = "p.format",paired = F,label.y = 0.5)
graph2ppt(file="Fig3.pptx",width = 8, height = 5)
results=as.data.frame(ezANOVA(data=DatAnova
                              , dv=MeanRTDiff,wid=.(ID),within=.(Test,Model,Phase),
                              ,type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

as.data.frame(summarise(group_by(DatAnova,Model),M = round(mean(MeanRTDiff),digits = 2),SD = round(sd(MeanRTDiff),digits = 2)))
t.test(DatAnova$MeanRTDiff[DatAnova$Model=="Full"],DatAnova$MeanRTDiff[DatAnova$Model=="Subband"])


# A[abs(scale(A, center=TRUE, scale=TRUE))>3]=NA
# B[abs(scale(B, center=TRUE, scale=TRUE))>3]=NA
wilcox.test(MeanRTDiff~Model , data = DatAnova[DatAnova$Test=="Gamma" & DatAnova$Phase == "Perturbed",],paired = F)
wilcox.test(MeanRTDiff~Model , data = DatAnova[DatAnova$Test=="Gamma" & DatAnova$Phase == "Original",],paired = F)
wilcox.test(MeanRTDiff~Model , data = DatAnova[DatAnova$Test=="Delta" & DatAnova$Phase == "Perturbed",],paired = F)
wilcox.test(MeanRTDiff~Model , data = DatAnova[DatAnova$Test=="Delta" & DatAnova$Phase == "Original",],paired = F)

as.data.frame(summarise(group_by(DatAnova,Model,Test,Phase),M = round(mean(MeanRTDiff),digits = 2),SD = round(sd(MeanRTDiff),digits = 2)))
t.test(DatAnova$MeanRTDiff[DatAnova$Model=="Full" & DatAnova$Test=="Delta" & DatAnova$Phase == "Original"],
       DatAnova$MeanRTDiff[DatAnova$Model=="Subband"& DatAnova$Test=="Delta" & DatAnova$Phase == "Original"],paired = T)
t.test(DatAnova$MeanRTDiff[DatAnova$Model=="Full" & DatAnova$Test=="Gamma" & DatAnova$Phase == "Original"],
       DatAnova$MeanRTDiff[DatAnova$Model=="Subband"& DatAnova$Test=="Gamma" & DatAnova$Phase == "Original"],paired = T)
t.test(DatAnova$MeanRTDiff[DatAnova$Model=="Full" & DatAnova$Test=="Delta" & DatAnova$Phase == "Perturbed"],
       DatAnova$MeanRTDiff[DatAnova$Model=="Subband"& DatAnova$Test=="Delta" & DatAnova$Phase == "Perturbed"], paired = T)


# ----------->  ttests
Fulldat = DataAvg$MeanRTDiff[DataAvg$Test=="Full"]
BandDat_Orig = DataAvg$MeanRTDiff[DataAvg$Model=="Full" & DataAvg$Test=="Alpha" & DataAvg$Phase == "Original"]
BandDat_Pert = DataAvg$MeanRTDiff[DataAvg$Model=="Full" & DataAvg$Test=="Alpha" & DataAvg$Phase == "Perturbed"]
t.test(Fulldat,BandDat_Orig)
t.test(BandDat_Orig,BandDat_Pert)
BandDat_Orig = DataAvg$MeanRTDiff[DataAvg$Model=="Full" & DataAvg$Test=="Gamma" & DataAvg$Phase == "Original"]
BandDat_Pert = DataAvg$MeanRTDiff[DataAvg$Model=="Full" & DataAvg$Test=="Gamma" & DataAvg$Phase == "Perturbed"]
t.test(BandDat_Orig,BandDat_Pert)

