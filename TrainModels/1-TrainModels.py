import MyUtils_new
import numpy as np
import random

import pandas as pd
import xlsxwriter 


 
Health = "HC"
Med    = "Off"

workbook  = xlsxwriter.Workbook('Trials4Test_All.xlsx') 
worksheet = workbook.add_worksheet('1') 

Stim1 = "sham"
Stim7 = "gvs7"
Stim8 = "gvs8"
good_eeg1, good_beh1 = MyUtils_new.GetData_full(Med, Health, Stim1)
good_eeg7, good_beh7 = MyUtils_new.GetData_full(Med, Health, Stim7)
good_eeg8, good_beh8 = MyUtils_new.GetData_full(Med, Health, Stim8)


good_eeg1_sub, good_beh1_sub = MyUtils_new.GetData_subband(Med, Health, Stim1)
good_eeg7_sub, good_beh7_sub = MyUtils_new.GetData_subband(Med, Health, Stim7)
good_eeg8_sub, good_beh8_sub = MyUtils_new.GetData_subband(Med, Health, Stim8)




for run in range (4):
    
    subband = 'bandfull'
    Trials4Test = [random.randint(0,9) for _ in range(20)]
    print ("run=")
    print(run)
  
    print (Trials4Test)

    row = run+1
    column = 0
    for item in Trials4Test: 
        worksheet.write(row, column, item) 
        column += 1
    
    PATH = 'Run'+str(run+1)+"/Models/"
    
   
    X,X_extended_sham, y_sham = MyUtils_new.PrepareTrainingData(good_eeg1, good_beh1, Stim1, Health, Med, subband, Trials4Test, run)
    
    X,X_extended_gvs7, y_gvs7 = MyUtils_new.PrepareTrainingData(good_eeg7, good_beh7, Stim7, Health, Med, subband, Trials4Test, run)
       
    X,X_extended_gvs8, y_gvs8 = MyUtils_new.PrepareTrainingData(good_eeg8, good_beh8, Stim8, Health, Med, subband, Trials4Test, run)
    
    full_X_extended = np.concatenate((X_extended_sham, X_extended_gvs7, X_extended_gvs8),axis = 0)
    full_y =          np.concatenate((y_sham,          y_gvs7,          y_gvs8),axis = 0)
     
    
    # # test model only with sham not all stim codes
    DatCode = Health + '_' + Med + '_' + Stim1 + '_' + subband
      
    MyUtils_new.TrainValidate(full_X_extended, full_y, DatCode, run)
   
      
        
    SBs = ['bandAlpha', 'bandBeta', 'bandDelta', 'bandGamma', 'bandTheta']
    for sb in SBs:
        subband = sb    

        X,X_extended_sham, y_sham = MyUtils_new.PrepareTrainingData(good_eeg1_sub, good_beh1_sub, Stim1, Health, Med, subband, Trials4Test, run)
     
        X,X_extended_gvs7, y_gvs7 = MyUtils_new.PrepareTrainingData(good_eeg7_sub, good_beh7_sub, Stim7, Health, Med, subband, Trials4Test, run)
       
        X,X_extended_gvs8, y_gvs8 = MyUtils_new.PrepareTrainingData(good_eeg8_sub, good_beh8_sub, Stim8, Health, Med, subband, Trials4Test, run)
    
        full_X_extended = np.concatenate((X_extended_sham, X_extended_gvs7, X_extended_gvs8),axis = 0)
        full_y =          np.concatenate((y_sham,          y_gvs7,          y_gvs8),axis = 0)
     
        DatCode = Health + '_' + Med + '_' + Stim1  + '_' + subband
      
        MyUtils_new.TrainValidate(full_X_extended, full_y, DatCode, run) # Train: sub - Test: sub
    
workbook.close()


  