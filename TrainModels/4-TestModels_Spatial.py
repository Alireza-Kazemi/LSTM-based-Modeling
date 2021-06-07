import MyUtils_new
import numpy as np
import xlsxwriter 
import pandas as pd


 
Health = "HC"
Med    = "Off"

Stim1 = "sham"
Stim7 = "gvs7"
Stim8 = "gvs8"
good_eeg1, good_beh1 = MyUtils_new.GetData_full(Med, Health, Stim1)
#good_eeg7, good_beh7 = MyUtils_new.GetData_full(Med, Health, Stim7)
#good_eeg8, good_beh8 = MyUtils_new.GetData_full(Med, Health, Stim8)


good_eeg1_sub, good_beh1_sub = MyUtils_new.GetData_subband(Med, Health, Stim1)
#good_eeg7_sub, good_beh7_sub = MyUtils_new.GetData_subband(Med, Health, Stim7)
#good_eeg8_sub, good_beh8_sub = MyUtils_new.GetData_subband(Med, Health, Stim8)


for run in range (2):
    
    PATH = 'Run'+str(run+1)+"/Models/"
    df = pd.read_excel (r'Trials4Test_All.xlsx')
    all = np.array(df)
    Trials4Test = all[run]
    print ("run=")
    print(run)
    print(Trials4Test)
    
    
    
    #------------------- Train on sub-bands, Test on Sub-----------------------
    SBs = ['Alpha', 'Delta']
    #workbook_sub  = xlsxwriter.Workbook('Run'+str(run+1)+'/TrainOnSB.xlsx') 
    workbook_sub  = xlsxwriter.Workbook('Run'+str(run+1)+'_TrainOnSB_SP.xlsx') 
    
    for sb in SBs:
            subband = 'band' + sb  
            DatCode = Health + '_' + Med + '_' + Stim1  + '_' + subband
            worksheet      = workbook_sub.add_worksheet(sb) 
             
            bestmodel_name = PATH +'BestModel_' + DatCode + '.h5'
            X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1_sub, good_beh1_sub,"sham", Health, Med, subband, Trials4Test, run)
            
            rt_orig, rt_pred, MAE_Test = list(MyUtils_new.NewTest_ReturnValue_Spatial(bestmodel_name, X_extended_sham, y_sham))  # Train: Full - Test: Full
     
            row = 1
            column = 1
            for item in MAE_Test: 
                worksheet.write(row, column, item) 
                row += 1

               
    
    #------------------- Train on sub-bands, test on filtered subband-----------------------
    SBs    = ['Alpha', 'Delta']
    Things = ['Amp', 'Phase']
    #workbook = xlsxwriter.Workbook('TrainOnSB2.xlsx') 
    for sb in SBs:
            subband = 'band' + sb   
    
            DatCode = Health + '_' + Med + '_' + Stim1  + '_' + subband
            bestmodel_name = PATH +'BestModel_' + DatCode + '.h5'
            
            for what in Things:
                worksheet = workbook_sub.add_worksheet(sb+what+'_Filtered') 
                X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1_sub, good_beh1_sub, "sham", Health, Med, subband + '_'+ what + 'Filtered', Trials4Test, run)
              
                rt_orig,rt_pred, MAE_Test = list(MyUtils_new.NewTest_ReturnValue_Spatial(bestmodel_name, X_extended_sham, y_sham))  # Train: Full - Test: Full

                row = 1
                column = 1
                for item in MAE_Test: 
                    worksheet.write(row, column, item) 
                    row += 1

    workbook_sub.close() 
   