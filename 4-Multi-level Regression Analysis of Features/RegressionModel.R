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
d=read.table("FeatureDataHC_NEW.csv", header=TRUE, sep=",", strip.white = TRUE)


d = d[complete.cases(d),]
d = d[!d$SID%in%c(8,9),]

temp = as.data.frame(summarise(group_by(d,SID,Health,Stim,Channel,Trial,RT),
                               Feature_1 = mean(Feature_1),
                               Feature_2 = mean(Feature_2),
                               Feature_3 = mean(Feature_3),
                               Feature_4 = mean(Feature_4),
                               Feature_5 = mean(Feature_5),
                               Feature_6 = mean(Feature_6),
                               Feature_7 = mean(Feature_7),
                               Feature_8 = mean(Feature_8),
                               Feature_9 = mean(Feature_9),
                               Feature_10 = mean(Feature_10),
                               Feature_11 = mean(Feature_11),
                               Feature_12 = mean(Feature_12),
                               Feature_13 = mean(Feature_13),
                               Feature_14 = mean(Feature_14),
                               Feature_15 = mean(Feature_15),
                               Feature_16 = mean(Feature_16),
                               Feature_17 = mean(Feature_17),
                               Feature_18 = mean(Feature_18),
                               Feature_19 = mean(Feature_19),
                               Feature_20 = mean(Feature_20),
                               Feature_21 = mean(Feature_21),
                               Feature_22 = mean(Feature_22),
                               Feature_23 = mean(Feature_23),
                               Feature_24 = mean(Feature_24),
                               Feature_25 = mean(Feature_25),
                               Feature_26 = mean(Feature_26),
                               Feature_27 = mean(Feature_27),
                               Feature_28 = mean(Feature_28),
                               Feature_29 = mean(Feature_29),
                               Feature_30 = mean(Feature_30),
                               Feature_31 = mean(Feature_31),
                               Feature_32 = mean(Feature_32),
                               Feature_33 = mean(Feature_33),
                               Feature_34 = mean(Feature_34),
                               Feature_35 = mean(Feature_35),
                               Feature_36 = mean(Feature_36),
                               Feature_37 = mean(Feature_37),
                               Feature_38 = mean(Feature_38),
                               Feature_39 = mean(Feature_39),
                               Feature_40 = mean(Feature_40),
                               Feature_41 = mean(Feature_41),
                               Feature_42 = mean(Feature_42),
                               Feature_43 = mean(Feature_43),
                               Feature_44 = mean(Feature_44),
                               Feature_45 = mean(Feature_45),
                               Feature_46 = mean(Feature_46),
                               Feature_47 = mean(Feature_47),
                               Feature_48 = mean(Feature_48),
                               Feature_49 = mean(Feature_49),
                               Feature_50 = mean(Feature_50),
                               Feature_51 = mean(Feature_51),
                               Feature_52 = mean(Feature_52),
                               Feature_53 = mean(Feature_53),
                               Feature_54 = mean(Feature_54),
                               Feature_55 = mean(Feature_55),
                               Feature_56 = mean(Feature_56),
                               Feature_57 = mean(Feature_57),
                               Feature_58 = mean(Feature_58),
                               Feature_59 = mean(Feature_59),
                               Feature_60 = mean(Feature_60),
                               Feature_61 = mean(Feature_61),
                               Feature_62 = mean(Feature_62)))
write.csv(temp,file = "ForMatlabNormalization.csv",row.names = F)


#### Scaling by trials  Best results check outliers------
d=read.table("normalizedFeats.csv", header=TRUE, sep=",", strip.white = TRUE)


d = d[complete.cases(d),]
d = d[!d$SID%in%c(8,9),]
d = d[d$Stim =="Sham",]

datR_CH_S = d

datR_NoCH_S = as.data.frame(summarise(group_by(datR_CH_S,SID,Health,Stim,Trial,RT),
                                  Feature_1 = mean(Feature_1),
                                  Feature_2 = mean(Feature_2),
                                  Feature_3 = mean(Feature_3),
                                  Feature_4 = mean(Feature_4),
                                  Feature_5 = mean(Feature_5),
                                  Feature_6 = mean(Feature_6),
                                  Feature_7 = mean(Feature_7),
                                  Feature_8 = mean(Feature_8),
                                  Feature_9 = mean(Feature_9),
                                  Feature_10 = mean(Feature_10),
                                  Feature_11 = mean(Feature_11),
                                  Feature_12 = mean(Feature_12),
                                  Feature_13 = mean(Feature_13),
                                  Feature_14 = mean(Feature_14),
                                  Feature_15 = mean(Feature_15),
                                  Feature_16 = mean(Feature_16),
                                  Feature_17 = mean(Feature_17),
                                  Feature_18 = mean(Feature_18),
                                  Feature_19 = mean(Feature_19),
                                  Feature_20 = mean(Feature_20),
                                  Feature_21 = mean(Feature_21),
                                  Feature_22 = mean(Feature_22),
                                  Feature_23 = mean(Feature_23),
                                  Feature_24 = mean(Feature_24),
                                  Feature_25 = mean(Feature_25),
                                  Feature_26 = mean(Feature_26),
                                  Feature_27 = mean(Feature_27),
                                  Feature_28 = mean(Feature_28),
                                  Feature_29 = mean(Feature_29),
                                  Feature_30 = mean(Feature_30),
                                  Feature_31 = mean(Feature_31),
                                  Feature_32 = mean(Feature_32),
                                  Feature_33 = mean(Feature_33),
                                  Feature_34 = mean(Feature_34),
                                  Feature_35 = mean(Feature_35),
                                  Feature_36 = mean(Feature_36),
                                  Feature_37 = mean(Feature_37),
                                  Feature_38 = mean(Feature_38),
                                  Feature_39 = mean(Feature_39),
                                  Feature_40 = mean(Feature_40),
                                  Feature_41 = mean(Feature_41),
                                  Feature_42 = mean(Feature_42),
                                  Feature_43 = mean(Feature_43),
                                  Feature_44 = mean(Feature_44),
                                  Feature_45 = mean(Feature_45),
                                  Feature_46 = mean(Feature_46),
                                  Feature_47 = mean(Feature_47),
                                  Feature_48 = mean(Feature_48),
                                  Feature_49 = mean(Feature_49),
                                  Feature_50 = mean(Feature_50),
                                  Feature_51 = mean(Feature_51),
                                  Feature_52 = mean(Feature_52),
                                  Feature_53 = mean(Feature_53),
                                  Feature_54 = mean(Feature_54),
                                  Feature_55 = mean(Feature_55),
                                  Feature_56 = mean(Feature_56),
                                  Feature_57 = mean(Feature_57),
                                  Feature_58 = mean(Feature_58),
                                  Feature_59 = mean(Feature_59),
                                  Feature_60 = mean(Feature_60),
                                  Feature_61 = mean(Feature_61),
                                  Feature_62 = mean(Feature_62)))



########################## Check Different Channels ------------
########################## RSP features -----
fit <- lmer( RT ~ Feature_1 + Feature_2 + Feature_3 + Feature_4 + Feature_5 +
                  Feature_6 + Feature_7 + Feature_8 + Feature_9 + Feature_10 +
                  Feature_11 + 
                  + (1|SID) , data=datR)
summary(fit)

fit <- lmer( RT ~ Feature_1 + Feature_2 + Feature_3 + Feature_4 + Feature_5 +
                     Feature_6 + Feature_7 + Feature_8 + Feature_9 + Feature_10 +
                     Feature_11 +
                     + (1|SID) , data=datR_SO)
summary(fit)

fit <- lmer( RT ~ Feature_1 + Feature_2 + Feature_3 + Feature_4 + Feature_5 +
               Feature_6 + Feature_7 + Feature_8 + Feature_9 + Feature_10 +
               Feature_11 + 
               + (1|SID) , data=datR_NoCH_S)
summary(fit)

model_performance(fit)


graphdat = melt(datR_NoCH_S, id.vars = c("SID", "Health","Stim","Trial","RT"),
                variable.name = "Features")

DesiredSIDs = c(1,2,3,4)
DesiredFeatures = c("Feature_1","Feature_2","Feature_11")
        # c("Feature_1","Feature_2","Feature_3","Feature_4","Feature_5",
        #             "Feature_6","Feature_7","Feature_8","Feature_9","Feature_10")
ggplot(graphdat[graphdat$SID %in% DesiredSIDs & graphdat$Features %in% DesiredFeatures,],
       aes(x=value, y=RT, color=as.factor(Features))) + 
        geom_point(shape=20) + 
        geom_smooth(method=lm,alpha=0)+
        facet_wrap(~SID, ncol = 2)
        theme(legend.position = "none") 
        
########################## Channel search RSP ----
SigFeatures = NULL
summaries = list()        
for (i in unique(datR_CH_S$Channel)){
        
        datTemp = datR_CH_S[datR_CH_S$Channel==i,]
        
        model <- lmer( RT ~ Feature_1 + Feature_2 + Feature_3 + Feature_4 + Feature_5 +
                             Feature_6 + Feature_7 + Feature_8 + Feature_9 + Feature_10 +
                             Feature_11 + 
                             + (1|SID) , data=datTemp, REML=FALSE)
        smodel = summary(model)
        A  = smodel$coefficients[-1,4]<0.05
        A[A=="True"]=1
        A = as.data.frame(rbind(A,A))
        A = A[1,]
        A$Channel = i
        A = cbind(A,model_performance(model))
        SigFeatures = rbind(SigFeatures,A)
}

write.csv(SigFeatures,"SigFeatureChannel_RSP.csv",row.names = F)        
    

########################## Channel search HP features ----
datTemp = datR_CH_S[datR_CH_S$Channel==1,]

model <- lmer( RT ~ Feature_12 + Feature_13 + Feature_14 + Feature_15 + Feature_16 + Feature_17 +
                       Feature_18 + Feature_19 + Feature_20 + Feature_21 + Feature_22 + Feature_23 +
                       Feature_24 + Feature_25 + Feature_26 + 
                       + (1|SID) , data=datTemp, REML=FALSE)
smodel = summary(model)
A  = smodel$coefficients[-1,4]<0.05
A[A=="True"]=1
A = as.data.frame(rbind(A,A))
A = A[1,]
A$Channel = i
A = cbind(A,model_performance(model))
SigFeatures = A
for (i in unique(datR_CH_S$Channel)){
        
        datTemp = datR_CH_S[datR_CH_S$Channel==i,]
        
        model <- lmer( RT ~ Feature_12 + Feature_13 + Feature_14 + Feature_15 + Feature_16 + Feature_17 +
                               Feature_18 + Feature_19 + Feature_20 + Feature_21 + Feature_22 + Feature_23 +
                               Feature_24 + Feature_25 + Feature_26 + 
                               + (1|SID) , data=datTemp, REML=FALSE)
        smodel = summary(model)
        A  = smodel$coefficients[-1,4]<0.05
        A[A=="True"]=1
        A = as.data.frame(rbind(A,A))
        A = A[1,]
        A$Channel = i
        A = cbind(A,model_performance(model))
        SigFeatures = merge(SigFeatures,A,all = T, all.x = T,all.y = T)
}
graphdat = SigFeatures[,c("AIC","Channel")]
graphdat$Alpha1 = SigFeatures$Feature_14
graphdat$Alpha2 = SigFeatures$Feature_19
graphdat$Alpha3 = SigFeatures$Feature_24
graphdat$Delta1 = SigFeatures$Feature_12
graphdat$Delta2 = SigFeatures$Feature_17
graphdat$Delta3 = SigFeatures$Feature_22

graphdat$Alpha = SigFeatures$Feature_14 + SigFeatures$Feature_19 + SigFeatures$Feature_24
graphdat$Delta = SigFeatures$Feature_12 + SigFeatures$Feature_17 + SigFeatures$Feature_22

graphdat = melt(graphdat, id.vars = c("Channel","AIC"),
                variable.name = "Band")
graphdat$Channel = as.factor(graphdat$Channel)
ggplot(graphdat, aes(x=Channel, y=value, fill=Channel)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        facet_wrap(~Band, ncol = 1)

write.csv(SigFeatures,"SigFeatureChannel_HP.csv",row.names = F) 

########################## HP features -----
fit <- lmer( RT ~ Feature_12 + Feature_13 + Feature_14 + Feature_15 + Feature_16 + Feature_17 +
                     Feature_18 + Feature_19 + Feature_20 + Feature_21 + Feature_22 + Feature_23 +
                     Feature_24 + Feature_25 + Feature_26 + 
                     + (1|SID) , data=datR_NoCH_S)
summary(fit)


########################## BTS Amp. features ----
datTemp = datR_CH_S[datR_CH_S$Channel==1,]

model <- lmer( RT ~ Feature_35 + Feature_36 + Feature_37 + Feature_38 + Feature_39+
                       Feature_40 + Feature_41 + Feature_42 + Feature_43 + Feature_44 
                       + (1|SID) , data=datTemp, REML=FALSE)
smodel = summary(model)
A  = smodel$coefficients[-1,4]<0.05
A[A=="True"]=1
A = as.data.frame(rbind(A,A))
A = A[1,]
A$Channel = i
A = cbind(A,model_performance(model))
SigFeatures = A
for (i in unique(datR_CH_S$Channel)){
        
        datTemp = datR_CH_S[datR_CH_S$Channel==i,]
        
        model <- lmer( RT ~ Feature_35 + Feature_36 + Feature_37 + Feature_38 + Feature_39+
                               Feature_40 + Feature_41 + Feature_42 + Feature_43 + Feature_44 
                               + (1|SID) , data=datTemp, REML=FALSE)
        smodel = summary(model)
        A  = smodel$coefficients[-1,4]<0.05
        A[A=="True"]=1
        A = as.data.frame(rbind(A,A))
        A = A[1,]
        A$Channel = i
        A = cbind(A,model_performance(model))
        SigFeatures = merge(SigFeatures,A,all = T, all.x = T,all.y = T)
}
graphdat = SigFeatures[,c("AIC","Channel")]

graphdat$Alpha = SigFeatures$Feature_39 + SigFeatures$Feature_40 + SigFeatures$Feature_41
graphdat$Delta = SigFeatures$Feature_35 + SigFeatures$Feature_36 

graphdat = melt(graphdat, id.vars = c("Channel","AIC"),
                variable.name = "Band")
graphdat$Channel = as.factor(graphdat$Channel)
ggplot(graphdat, aes(x=Channel, y=value, fill=Channel)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        facet_wrap(~Band, ncol = 1)


########################## BTS Amp. features -----
fit <- lmer( RT ~ Feature_35 + Feature_36 + Feature_37 + Feature_38 + Feature_39+
                     Feature_40 + Feature_41 + Feature_42 + Feature_43 + Feature_44
                    + (1|SID) , data=datR_NoCH_S)
summary(fit)

########################## BTS Phase. features ----
datTemp = datR_CH_S[datR_CH_S$Channel==1,]

model <- lmer( RT ~ Feature_45 + Feature_46 + Feature_47 + Feature_48 + Feature_49+
                       Feature_50 + Feature_51 + Feature_52 + Feature_53 + Feature_54 
               + (1|SID) , data=datTemp, REML=FALSE)
smodel = summary(model)
A  = smodel$coefficients[-1,4]<0.05
A[A=="True"]=1
A = as.data.frame(rbind(A,A))
A = A[1,]
A$Channel = i
A = cbind(A,model_performance(model))
SigFeatures = A
for (i in unique(datR_CH_S$Channel)){
        
        datTemp = datR_CH_S[datR_CH_S$Channel==i,]
        
        model <- lmer( RT ~ Feature_45 + Feature_46 + Feature_47 + Feature_48 + Feature_49+
                               Feature_50 + Feature_51 + Feature_52 + Feature_53 + Feature_54 
                       + (1|SID) , data=datTemp, REML=FALSE)
        smodel = summary(model)
        A  = smodel$coefficients[-1,4]<0.05
        A[A=="True"]=1
        A = as.data.frame(rbind(A,A))
        A = A[1,]
        A$Channel = i
        A = cbind(A,model_performance(model))
        SigFeatures = merge(SigFeatures,A,all = T, all.x = T,all.y = T)
}
graphdat = SigFeatures[,c("AIC","Channel")]

graphdat$Alpha = SigFeatures$Feature_49 + SigFeatures$Feature_50 + SigFeatures$Feature_51
graphdat$Delta = SigFeatures$Feature_45 + SigFeatures$Feature_46 

graphdat = melt(graphdat, id.vars = c("Channel","AIC"),
                variable.name = "Band")
graphdat$Channel = as.factor(graphdat$Channel)
ggplot(graphdat, aes(x=Channel, y=value, fill=Channel)) + 
        geom_bar(stat="summary",fun.y="mean",position="dodge")+
        facet_wrap(~Band, ncol = 1)


########################## BTS Phase features -----
fit <- lmer( RT ~ Feature_45 + Feature_46 + Feature_47 + Feature_48 + Feature_49+
                     Feature_50 + Feature_51 + Feature_52 + Feature_53 + Feature_54
                   + (1|SID) , data=datR_NoCH_S)
summary(fit)
