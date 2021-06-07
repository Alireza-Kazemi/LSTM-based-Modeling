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
# good_eeg7, good_beh7 = MyUtils_new.GetData_full(Med, Health, Stim7)
# good_eeg8, good_beh8 = MyUtils_new.GetData_full(Med, Health, Stim8)


good_eeg1_sub, good_beh1_sub = MyUtils_new.GetData_subband(Med, Health, Stim1)
# good_eeg7_sub, good_beh7_sub = MyUtils_new.GetData_subband(Med, Health, Stim7)
# good_eeg8_sub, good_beh8_sub = MyUtils_new.GetData_subband(Med, Health, Stim8)


for run in range (40):
    
    PATH = 'Run'+str(run+1)+"/Models/"
    df = pd.read_excel (r'Trials4Test_All.xlsx')
    all = np.array(df)
    Trials4Test = all[run]
    print ("run=")
    print(run)
    print(Trials4Test)
    
    #------------------- Train on Full, Test on Full and Sub-----------------------
    SBs = ['full', 'Alpha', 'Beta', 'Delta', 'Gamma', 'Theta']
    workbook_full = xlsxwriter.Workbook('Run'+str(run+1)+'_TrainOnFull.xlsx') 
    workbook_orig = xlsxwriter.Workbook('Run'+str(run+1)+'_ORIGINAL.xlsx') 
    workbook_Elham = xlsxwriter.Workbook('Run'+str(run+1)+'_FinalTestMAEs.xlsx') 
    worksheet_MAE = workbook_Elham.add_worksheet('1') 
    ROW = 0
        
    for sb in SBs:
            subband = 'band' + sb
            worksheet      = workbook_full.add_worksheet(sb) 
            worksheet_orig = workbook_orig.add_worksheet(sb)
            
            DatCode = Health + '_' + Med + '_' + Stim1  + '_' + 'bandfull'
            
            bestmodel_name = PATH +'BestModel_' + DatCode + '.h5'
                 
            if sb == 'full':
                X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1, good_beh1, Stim1, Health, Med, subband, Trials4Test, run)
            else:
                X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1_sub, good_beh1_sub, Stim1, Health, Med, subband, Trials4Test, run)
            # X,X_extended_gvs7, y_gvs7 = MyUtils_new.PrepareTestData(good_eeg7, good_beh7, Stim7, Health, Med, subband, Trials4Test, run)
       
            # X,X_extended_gvs8, y_gvs8 = MyUtils_new.PrepareTestData(good_eeg8, good_beh8, Stim8, Health, Med, subband, Trials4Test, run)
            
            # full_X_extended = np.concatenate((X_extended_sham, X_extended_gvs7, X_extended_gvs8),axis = 0)
            # full_y =          np.concatenate((y_sham,          y_gvs7,          y_gvs8),axis = 0)
    
            
            rt_orig,rt_pred, MAE_Test = list(MyUtils_new.NewTest_ReturnValue(bestmodel_name, X_extended_sham, y_sham))  # Train: Full - Test: Full
            row = 1
            column = 1
            for item in rt_pred: 
                worksheet.write(row, column, item) 
                worksheet.write(row, 0, "Trial" + str(row))
                row += 1
            worksheet.write(0, 1, "RT") 
            worksheet.write(0, 0, "Trials") 
            row = 1
            column = 1
            for item in rt_orig: 
                worksheet_orig.write(row, column, item) 
                worksheet_orig.write(row, 0, "Trial" + str(row))
                row += 1
            worksheet_orig.write(0, 1, "RT") 
            worksheet_orig.write(0, 0, "Trials") 
            worksheet_MAE.write(0,ROW, MAE_Test)
            ROW = ROW + 1
    #------------------- Train on Full, test on filtered subband-----------------------
    SBs    = ['Alpha', 'Beta','Delta', 'Gamma', 'Theta']
    Things = ['Amp', 'Phase']
    #workbook = xlsxwriter.Workbook('TrainOnFull2.xlsx') 
    for sb in SBs:
            subband = 'band' + sb    
    
            DatCode = Health + '_' + Med + '_' + Stim1  + '_' + 'bandfull'
          
            bestmodel_name = PATH +'BestModel_' + DatCode + '.h5'
            for what in Things:
                worksheet = workbook_full.add_worksheet(sb+what+'Filtered') 
                
                X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1_sub, good_beh1_sub, "sham", Health, Med,subband + '_'+ what + 'Filtered', Trials4Test, run)
                
                rt_orig,rt_pred, MAE_Test = list(MyUtils_new.NewTest_ReturnValue(bestmodel_name, X_extended_sham, y_sham))  # Train: Full - Test: Full
                row = 1
                column = 1
                for item in rt_pred: 
                    worksheet.write(row, column, item) 
                    worksheet.write(row, 0, "Trial" + str(row))
                    row += 1
                worksheet.write(0, 1, "RT") 
                worksheet.write(0, 0, "Trials") 
                worksheet_MAE.write(0,ROW, MAE_Test)
                ROW = ROW + 1
    
    #------------------- Train on sub-bands, Test on Sub-----------------------
    SBs = ['Alpha', 'Beta', 'Delta', 'Gamma', 'Theta']
    #workbook_sub  = xlsxwriter.Workbook('Run'+str(run+1)+'/TrainOnSB.xlsx') 
    workbook_sub  = xlsxwriter.Workbook('Run'+str(run+1)+'_TrainOnSB.xlsx') 
    
    for sb in SBs:
            subband = 'band' + sb  
            DatCode = Health + '_' + Med + '_' + Stim1  + '_' + subband
            worksheet      = workbook_sub.add_worksheet(sb) 
             
            bestmodel_name = PATH +'BestModel_' + DatCode + '.h5'
            X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1_sub, good_beh1_sub,"sham", Health, Med, subband, Trials4Test, run)
            
            rt_orig, rt_pred, MAE_Test = list(MyUtils_new.NewTest_ReturnValue(bestmodel_name, X_extended_sham, y_sham))  # Train: Full - Test: Full
     
     
            row = 1
            column = 1
            for item in rt_pred: 
                worksheet.write(row, column, item) 
                worksheet.write(row, 0, "Trial" + str(row))
                row += 1
            worksheet.write(0, 1, "RT") 
            worksheet.write(0, 0, "Trials") 
            worksheet_MAE.write(0,ROW, MAE_Test)
            ROW = ROW + 1
               
    
    #------------------- Train on sub-bands, test on filtered subband-----------------------
    SBs    = ['Alpha', 'Beta','Delta', 'Gamma', 'Theta']
    Things = ['Amp', 'Phase']
    #workbook = xlsxwriter.Workbook('TrainOnSB2.xlsx') 
    for sb in SBs:
            subband = 'band' + sb   
    
            DatCode = Health + '_' + Med + '_' + Stim1 + '_' + subband
            bestmodel_name = PATH +'BestModel_' + DatCode + '.h5'
            
            for what in Things:
                worksheet = workbook_sub.add_worksheet(sb+what+'_Filtered') 
                X,X_extended_sham, y_sham = MyUtils_new.PrepareTestData(good_eeg1_sub, good_beh1_sub, "sham", Health, Med, subband + '_'+ what + 'Filtered', Trials4Test, run)
              
                rt_orig,rt_pred, MAE_Test = list(MyUtils_new.NewTest_ReturnValue(bestmodel_name, X_extended_sham, y_sham))  # Train: Full - Test: Full
                row = 1
                column = 1
                for item in rt_pred: 
                    worksheet.write(row, column, item) 
                    worksheet.write(row, 0, "Trial" + str(row))
                    row += 1
                worksheet.write(0, 1, "RT") 
                worksheet.write(0, 0, "Trials") 
                worksheet_MAE.write(0,ROW, MAE_Test)
                ROW = ROW + 1
            
    workbook_orig.close() 
    workbook_full.close() 
    workbook_sub.close() 
    workbook_Elham.close()




   