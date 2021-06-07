import scipy.io as sio
import scipy as sp
from scipy.signal import savgol_filter
from scipy import signal
import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as img
import mat73

from tensorflow.keras.models import Sequential
from tensorflow.keras.models import load_model
from tensorflow.keras.layers import Dense, LSTM, Activation, Flatten, TimeDistributed, AveragePooling1D
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
from tensorflow.keras.wrappers.scikit_learn import KerasRegressor
from tensorflow.keras import optimizers


from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score 
from sklearn.linear_model import Lasso
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold

import mne.viz as mv
from scipy.fftpack import rfft, irfft

#import tensorflow as tf
from tensorflow.keras import backend as K
from numpy import mean
from numpy import std
import xlsxwriter 
from scipy.stats import pearsonr



def stim2Index (stim):
    switcher = {
            'sham' : 0,
            'gvs7': 6,
            'gvs8': 7,

            }
    return switcher.get(stim)

def GetBadPatientsID (Health):
    if (Health == 'HC'):
        tobedeleted = [7,8] #[7,8,9,13]
    else:
        tobedeleted = [2,6] #[2,6,7,11]
    return (tobedeleted)

def GetData_full ( Med, Health, Stim):
    behdata_filename = 'hc_behav_normalized_gvsstim' + str(stim2Index(Stim)+1) + '.mat'

    eegdata = mat73.loadmat('dataTaskNormalized.mat')
   
    

    if Health == 'HC':
       mydata = eegdata['dataHCTask'][stim2Index(Stim)]
       behdata = sio.loadmat(behdata_filename)['hc_norm']
       
    if (Health == 'PD' and Med == 'Off'):
       mydata = eegdata['dataPD1Task'][stim2Index(Stim)]
       behdata = sio.loadmat(behdata_filename)['pdoffmed']
       
    if (Health == 'PD' and Med == 'On'):
       mydata = eegdata['dataPD2Task'][stim2Index(Stim)]
       behdata = sio.loadmat(behdata_filename)['pdonmed']
    return (mydata, behdata)
        
def GetData_full4Saliency_NoNormalized ( Med, Health, Stim):
    behdata_filename = 'behav_gvsstim' + str(stim2Index(Stim)+1) + '.mat'

    eegdata = mat73.loadmat('dataTaskNormalized.mat')
   
    

    if Health == 'HC':
       mydata = eegdata['dataHCTask'][stim2Index(Stim)]
       behdata = sio.loadmat(behdata_filename)['hc']
       
    if (Health == 'PD' and Med == 'Off'):
       mydata = eegdata['dataPD1Task'][stim2Index(Stim)]
       behdata = sio.loadmat(behdata_filename)['pdoffmed']
       
    if (Health == 'PD' and Med == 'On'):
       mydata = eegdata['dataPD2Task'][stim2Index(Stim)]
       behdata = sio.loadmat(behdata_filename)['pdonmed']
    return (mydata, behdata) 
 
    return mydata, behdata

def GetData_subband (Med, Health, Stim):
    behdata_filename = 'hc_behav_normalized_gvsstim' + str(stim2Index(Stim)+1) + '.mat'
            
    if Health == 'HC':
       eegfilename = 'DataHC_StimIndex' + str(stim2Index(Stim)+1)+ '_NoiseFiltered.mat'
       eegdata = sio.loadmat(eegfilename)
       mydata = eegdata
       behdata = sio.loadmat(behdata_filename)['hc_norm']
       
    if (Health == 'PD' and Med == 'Off'):
       eegfilename = 'DataPDOff_StimIndex' +  str(stim2Index(Stim)+1)+ '.mat'
       eegdata = sio.loadmat(eegfilename)
       mydata = eegdata
       behdata = sio.loadmat(behdata_filename)['pdoffmed']
       
    if (Health == 'PD' and Med == 'On'):
       eegfilename = 'DataPDOn_StimIndex' +  str(stim2Index(Stim)+1)+ '.mat'
       eegdata = sio.loadmat(eegfilename)
       mydata = eegdata
       behdata = sio.loadmat(behdata_filename)['pdonmed']
    return (mydata, behdata)
        
 
    return mydata, behdata
def PrepareTrainingData (good_eeg, good_beh, Stim, Health, Med, subband, Trials4Test, run):
    
    num_chans = 27 
    time_steps = 1000
    num_trials = 10
    
    
    if Health == 'HC':
        IDs = list(range(0, 22))
    else:
        IDs = list(range(0, 20))
 
    badIDs = GetBadPatientsID(Health) 
    
    
    #good_eeg, good_beh = GetData(subband, Med, Health, Stim)
    
    
    # # # # # Load the EEG data of good_eeg # # # # # 
    #num_chans,time_steps,num_trials = good_eeg[0].shape
   
    
    
    X_good_eeg = np.zeros((len(IDs),num_chans,time_steps,num_trials)) #len (IDs) = number of subjects
    
    for pt in IDs: 
        #print ("pt= " + str(pt+1))
        if subband == 'bandfull': #the way it is saved in full is different!
           x = good_eeg[pt]
        else: # the way it is saved in subband => we need to seperate cases to read
           x = good_eeg[subband][0,pt]
        X_good_eeg[pt,:,:,:] = x[:,0:time_steps,:]
    
    # Remove bad subjects data 
    X_good_eeg = np.delete(X_good_eeg, badIDs[0],     axis = 0)
    X_good_eeg = np.delete(X_good_eeg, badIDs[1] - 1, axis = 0)
 
    
     # # # # # Load the EEG data labels of good_eeg # # # # # 
    num_trials, num_behvars = good_beh[0,1].shape
    y = np.zeros((len(IDs), num_trials,1))            
    for pt in IDs:
        #print ("pt= " + str(pt+1))
        for tr in range (num_trials):
            i = 0 # index of Reaction Time (Change the index to look other Behavior measures)
            y[pt,tr] = good_beh[0,pt][tr,i]
        
    # Remove bad subjects y
    y = np.delete(y, badIDs[0], axis = 0)
    y = np.delete(y, badIDs[0] - 1, axis = 0)
    

            
   
    
    #---------------- HERE I have to remove subject-trials kept for test (Wyatt Helped here) ------------
    trial_mask = np.ones((20,10),dtype=bool) # all True matrix, we will set the ones we want to remove to False
    for pt, t in enumerate(Trials4Test):
        trial_mask[pt,t] = False
    # We need to change the axes of the matrix so that we can use this mask on it
    # We change it so that trial is the second axis
    result_matrix = np.transpose(X_good_eeg,[0,3,1,2]) # (20x27x1000x10) -> (20x10x27x1000)
    # print(result_matrix.shape)
    # print(trial_mask.shape)
    # Apply mask to reshaped matrix
    result_matrix = result_matrix[trial_mask]
    # Reshape matrix
    # IMPORTANT: this step will cause trials to be assigned to the wrong patients if you remove an unequal number from each patient.
    # It takes the set of 180 patient-trials and evenly divides them into groups of 9- so they need to retain their order.
    result_matrix = result_matrix.reshape(20,9,27,1000) 
    
    result_matrix_new = np.transpose(result_matrix,[0,2,3,1]) # (20x9x27x1000) -> (20x27x1000,9)
    
    X_good_eeg = result_matrix_new
    #-------------------SAME to Y for removing Trials-------------------------------------
    Yresult_matrix = y[trial_mask]
    #-------------------------------------------------------------------------------------
        
    # Data transpose     
    X_good_eeg = np.transpose(X_good_eeg, (0, 3, 2, 1))        
    # Data dimensions          
    p,m,n,d = X_good_eeg.shape
    # Data reshape     
    X_good_eeg =  X_good_eeg.reshape(p* m,n,d)  
    
    # p = number of subjects after removing bad subjects    
    y = np.reshape(Yresult_matrix, (p*m, 1)) 
    
    
  
  
    # # # # # Data augmentation (Down-sampling by 2) # # # # # 
    X_good_eeg_DS1=X_good_eeg[:,0::2,:]
    X_good_eeg_DS2=X_good_eeg[:,1::2,:]
    X_good_eeg_DS = np.concatenate((X_good_eeg_DS1,X_good_eeg_DS2))
    # labels
    y_DS = np.concatenate((y,y))
    
    # # # # # Shuffle the data - all patients # # # # # 
    from random import shuffle
    N = X_good_eeg_DS.shape[0]
    indices = [i for i in range(N)]
    shuffle(indices)
    X_good_eeg_DS  = X_good_eeg_DS[indices, :,:]
    y_DS = y_DS[indices,]
    
    # Sanity Check: Exclude labels with NaN values
    # Indices of nan and inf values
    idx = np.where((np.isnan(y_DS)==False) & (np.isinf(y_DS)==False))
    filtered_X_good_eeg_DS = X_good_eeg_DS[idx[0],:,:]
    filtered_y_DS = y_DS[idx[0]]
    

    
    X = filtered_X_good_eeg_DS
    y = filtered_y_DS
    
    # Make X and y as float 32
    X = X.astype('float32')
    y = y.astype('float32')
    
   
    
    # -------------Extend with Codes---------------------
    m,n,d = np.shape(X)
    if Stim == 'sham': 
        Stim_Code_unit = [0, 0, 1]
    elif Stim =='gvs7': 
        Stim_Code_unit = [0, 1, 0]
    elif Stim =='gvs8': 
        Stim_Code_unit = [1, 0 ,0]
    else:
        Stim_Code_unit = "NONE"
        
        
    # if Health == 'HC':
    #      Health_Code_unit = [0, 1]
    # else: #PD
    #      Health_Code_unit = [1, 0]

    # if Med == 'Off':
    #     Med_Code_unit  = [0 ,1]
    # else: #On
    #     Med_Code_unit  = [1, 0]
        
    Stim_code =   np.reshape([Stim_Code_unit   *n for y in range(m)], [m, n, 3])
    # Health_code = np.reshape([Health_Code_unit *n for y in range(m)], [m, n, 2])
    # Med_code    = np.reshape([Med_Code_unit    *n for y in range(m)], [m, n, 2])

    # full_code   = np.concatenate((Stim_code, Health_code, Med_code),axis = 2)
    # X_extended  = np.concatenate((X,full_code),axis=2)
        
    X_extended = np.concatenate((X,Stim_code),axis=2)
    
    data = {'X':X, 'y': y}
    path = 'Run'+str(run+1)+"/"
    sp.io.savemat(path + Stim +'_Train_XY.mat', data)
  
    return (X, X_extended, y)

def PrepareTestData (good_eeg, good_beh,Stim, Health, Med, subband, Trials4Test, run):
    
    num_chans = 27 
    time_steps = 1000
    num_trials = 10
    
    
    if Health == 'HC':
        IDs = list(range(0, 22))
    else:
        IDs = list(range(0, 20))
 
    badIDs = GetBadPatientsID(Health) 
    
    
    #good_eeg, good_beh = GetData(subband, Med, Health, Stim)
    
    
    # # # # # Load the EEG data of good_eeg # # # # # 
    #num_chans,time_steps,num_trials = good_eeg[0].shape
   
    
    
    X_good_eeg = np.zeros((len(IDs),num_chans,time_steps,num_trials)) #len (IDs) = number of subjects
    
    for pt in IDs: 
        #print ("pt= " + str(pt+1))
        if subband == 'bandfull': #the way it is saved in full is different!
           x = good_eeg[pt]
        else: # the way it is saved in subband => we need to seperate cases to read
           x = good_eeg[subband][0,pt]
        X_good_eeg[pt,:,:,:] = x[:,0:time_steps,:]
    
    # Remove bad subjects data 
    X_good_eeg = np.delete(X_good_eeg, badIDs[0],     axis = 0)
    X_good_eeg = np.delete(X_good_eeg, badIDs[1] - 1, axis = 0)
 
    
     # # # # # Load the EEG data labels of good_eeg # # # # # 
    num_trials, num_behvars = good_beh[0,1].shape
    y = np.zeros((len(IDs), num_trials,1))            
    for pt in IDs:
        #print ("pt= " + str(pt+1))
        for tr in range (num_trials):
            i = 0 # index of Reaction Time (Change the index to look other Behavior measures)
            y[pt,tr] = good_beh[0,pt][tr,i]
        
    # Remove bad subjects y
    y = np.delete(y, badIDs[0], axis = 0)
    y = np.delete(y, badIDs[0] - 1, axis = 0)
    
        
    #---------------- HERE I have to remove subject-trials kept for test (Wyatt Helped here) ------------
    trial_mask = np.zeros((20,10),dtype=bool) # all True matrix, we will set the ones we want to remove to False
    for pt, t in enumerate(Trials4Test):
        trial_mask[pt,t] = True
    # We need to change the axes of the matrix so that we can use this mask on it
    # We change it so that trial is the second axis
    result_matrix = np.transpose(X_good_eeg,[0,3,1,2]) # (20x27x1000x10) -> (20x10x27x1000)
    # print(result_matrix.shape)
    # print(trial_mask.shape)
    # Apply mask to reshaped matrix
    result_matrix = result_matrix[trial_mask]
    # Reshape matrix
    # IMPORTANT: this step will cause trials to be assigned to the wrong patients if you remove an unequal number from each patient.
    # It takes the set of 180 patient-trials and evenly divides them into groups of 9- so they need to retain their order.
    result_matrix = result_matrix.reshape(20,1,27,1000) 
    
    result_matrix_new = np.transpose(result_matrix,[0,2,3,1]) # (20x9x27x1000) -> (20x27x1000,9)
    
    X_good_eeg = result_matrix_new
    #-------------------SAME to Y for removing Trials-------------------------------------
    Yresult_matrix = y[trial_mask]
    #-------------------------------------------------------------------------------------
        
    # Data transpose     
    X_good_eeg = np.transpose(X_good_eeg, (0, 3, 2, 1))        
    # Data dimensions          
    p,m,n,d = X_good_eeg.shape
    # Data reshape     
    X_good_eeg =  X_good_eeg.reshape(p* m,n,d)  
    
    # p = number of subjects after removing bad subjects    
    y = np.reshape(Yresult_matrix, (p*m, 1)) 
    
    
 
    # # # # # Data augmentation (Down-sampling by 2) # # # # # 
    X_good_eeg_DS1=X_good_eeg[:,0::2,:]
    X_good_eeg_DS2=X_good_eeg[:,1::2,:]
    X_good_eeg_DS = np.concatenate((X_good_eeg_DS1,X_good_eeg_DS2))
    # labels
    y_DS = np.concatenate((y,y))
    
    # # # # # Shuffle the data - all patients # # # # # 
    from random import shuffle
    N = X_good_eeg_DS.shape[0]
    indices = [i for i in range(N)]
    #shuffle(indices)
    X_good_eeg_DS  = X_good_eeg_DS[indices, :,:]
    y_DS = y_DS[indices,]
    
    # Sanity Check: Exclude labels with NaN values
    # Indices of nan and inf values
    idx = np.where((np.isnan(y_DS)==False) & (np.isinf(y_DS)==False))
    filtered_X_good_eeg_DS = X_good_eeg_DS[idx[0],:,:]
    filtered_y_DS = y_DS[idx[0]]
    

    
    X = filtered_X_good_eeg_DS
    y = filtered_y_DS
    
    # # Make X and y as float 32
    X = X.astype('float32')
    y = y.astype('float32')
    
   
    
    # -------------Extend with Codes---------------------
    m,n,d = np.shape(X)
    

        
    if Stim == 'sham': 
        Stim_Code_unit = [0, 0, 1]
    elif Stim =='gvs7': 
        Stim_Code_unit = [0, 1, 0]
    elif Stim =='gvs8': 
        Stim_Code_unit = [1, 0 ,0]
    else:
        Stim_Code_unit = "NONE"

        
    # if Health == 'HC':
    #      Health_Code_unit = [0, 1]
    # else: #PD
    #      Health_Code_unit = [1, 0]

    # if Med == 'Off':
    #     Med_Code_unit  = [0 ,1]
    # else: #On
    #     Med_Code_unit  = [1, 0]
        
    Stim_code =   np.reshape([Stim_Code_unit   *n for y in range(m)], [m, n, 3])
    # Health_code = np.reshape([Health_Code_unit *n for y in range(m)], [m, n, 2])
    # Med_code    = np.reshape([Med_Code_unit    *n for y in range(m)], [m, n, 2])

    # full_code   = np.concatenate((Stim_code, Health_code, Med_code),axis = 2)
    # X_extended  = np.concatenate((X,full_code),axis=2)
        
    X_extended = np.concatenate((X,Stim_code),axis=2)
    
    data = {'X':X, 'y':y}
    path = 'Run'+str(run+1)+"/"
    sp.io.savemat(path + Stim +'_Test_XY.mat', data)

    return (X, X_extended, y)

def PrepareTestData_4Saliency_NoNormalized (good_eeg, good_beh,Stim, Health, Med, subband, Trials4Test, run):
    
    num_chans = 27 
    time_steps = 1000
    num_trials = 10
    
    
    if Health == 'HC':
        IDs = list(range(0, 22))
    else:
        IDs = list(range(0, 20))
 
    badIDs = GetBadPatientsID(Health) 
    
    
    #good_eeg, good_beh = GetData(subband, Med, Health, Stim)
    
    
    # # # # # Load the EEG data of good_eeg # # # # # 
    #num_chans,time_steps,num_trials = good_eeg[0].shape
   
    
    
    X_good_eeg = np.zeros((len(IDs),num_chans,time_steps,num_trials)) #len (IDs) = number of subjects
    
    for pt in IDs: 
        #print ("pt= " + str(pt+1))
        if subband == 'bandfull': #the way it is saved in full is different!
           x = good_eeg[pt]
        else: # the way it is saved in subband => we need to seperate cases to read
           x = good_eeg[subband][0,pt]
        X_good_eeg[pt,:,:,:] = x[:,0:time_steps,:]
    
    # Remove bad subjects data 
    X_good_eeg = np.delete(X_good_eeg, badIDs[0],     axis = 0)
    X_good_eeg = np.delete(X_good_eeg, badIDs[1] - 1, axis = 0)
 
    
     # # # # # Load the EEG data labels of good_eeg # # # # # 
    num_trials, num_behvars = good_beh[0,1].shape
    y = np.zeros((len(IDs), num_trials,1))            
    for pt in IDs:
        #print ("pt= " + str(pt+1))
        for tr in range (num_trials):
            i = 0 # index of Reaction Time (Change the index to look other Behavior measures)
            y[pt,tr] = good_beh[0,pt][tr,i]
        
    # Remove bad subjects y
    y = np.delete(y, badIDs[0], axis = 0)
    y = np.delete(y, badIDs[0] - 1, axis = 0)
    
        
    #---------------- HERE I have to remove subject-trials kept for test (Wyatt Helped here) ------------
    trial_mask = np.zeros((20,10),dtype=bool) # all True matrix, we will set the ones we want to remove to False
    for pt, t in enumerate(Trials4Test):
        trial_mask[pt,t] = True
    # We need to change the axes of the matrix so that we can use this mask on it
    # We change it so that trial is the second axis
    result_matrix = np.transpose(X_good_eeg,[0,3,1,2]) # (20x27x1000x10) -> (20x10x27x1000)
    # print(result_matrix.shape)
    # print(trial_mask.shape)
    # Apply mask to reshaped matrix
    result_matrix = result_matrix[trial_mask]
    # Reshape matrix
    # IMPORTANT: this step will cause trials to be assigned to the wrong patients if you remove an unequal number from each patient.
    # It takes the set of 180 patient-trials and evenly divides them into groups of 9- so they need to retain their order.
    result_matrix = result_matrix.reshape(20,1,27,1000) 
    
    result_matrix_new = np.transpose(result_matrix,[0,2,3,1]) # (20x9x27x1000) -> (20x27x1000,9)
    
    X_good_eeg = result_matrix_new
    #-------------------SAME to Y for removing Trials-------------------------------------
    Yresult_matrix = y[trial_mask]
    #-------------------------------------------------------------------------------------
        
    # Data transpose     
    X_good_eeg = np.transpose(X_good_eeg, (0, 3, 2, 1))        
    # Data dimensions          
    p,m,n,d = X_good_eeg.shape
    # Data reshape     
    X_good_eeg =  X_good_eeg.reshape(p* m,n,d)  
    
    # p = number of subjects after removing bad subjects    
    y = np.reshape(Yresult_matrix, (p*m, 1)) 
    
    
 
    # # # # # Data augmentation (Down-sampling by 2) # # # # # 
    X_good_eeg_DS1=X_good_eeg[:,0::2,:]
    X_good_eeg_DS2=X_good_eeg[:,1::2,:]
    X_good_eeg_DS = np.concatenate((X_good_eeg_DS1,X_good_eeg_DS2))
    # labels
    y_DS = np.concatenate((y,y))
    
    # # # # # Shuffle the data - all patients # # # # # 
    from random import shuffle
    N = X_good_eeg_DS.shape[0]
    indices = [i for i in range(N)]
    #shuffle(indices)
    X_good_eeg_DS  = X_good_eeg_DS[indices, :,:]
    y_DS = y_DS[indices,]
    
    # Sanity Check: Exclude labels with NaN values
    # Indices of nan and inf values
    idx = np.where((np.isnan(y_DS)==False) & (np.isinf(y_DS)==False))
    filtered_X_good_eeg_DS = X_good_eeg_DS[idx[0],:,:]
    filtered_y_DS = y_DS[idx[0]]
    

    
    X = filtered_X_good_eeg_DS
    y = filtered_y_DS
    
    # # Make X and y as float 32
    X = X.astype('float32')
    y = y.astype('float32')
    
   
    
    # -------------Extend with Codes---------------------
    m,n,d = np.shape(X)
    

        
    if Stim == 'sham': 
        Stim_Code_unit = [0, 0, 1]
    elif Stim =='gvs7': 
        Stim_Code_unit = [0, 1, 0]
    elif Stim =='gvs8': 
        Stim_Code_unit = [1, 0 ,0]
    else:
        Stim_Code_unit = "NONE"

        
    # if Health == 'HC':
    #      Health_Code_unit = [0, 1]
    # else: #PD
    #      Health_Code_unit = [1, 0]

    # if Med == 'Off':
    #     Med_Code_unit  = [0 ,1]
    # else: #On
    #     Med_Code_unit  = [1, 0]
        
    Stim_code =   np.reshape([Stim_Code_unit   *n for y in range(m)], [m, n, 3])
    # Health_code = np.reshape([Health_Code_unit *n for y in range(m)], [m, n, 2])
    # Med_code    = np.reshape([Med_Code_unit    *n for y in range(m)], [m, n, 2])

    # full_code   = np.concatenate((Stim_code, Health_code, Med_code),axis = 2)
    # X_extended  = np.concatenate((X,full_code),axis=2)
        
    X_extended = np.concatenate((X,Stim_code),axis=2)
    
    data = {'X':X, 'y':y}
    path = 'Run'+str(run+1)+"/"
    sp.io.savemat(path +'Test_XY.mat', data)

    return (X, X_extended, y)


def TrainValidate(X,y, DataCode, run):
    
    # parse DataCode
    parts = DataCode.split("_")
    Health = parts[0]
    Med = parts[1]
    Stim = parts[2]
    #Sub2Exc = int(parts[3])
    subband = parts[3]
    
   
   
    # # # # # Hold-out (Training-Testing: 80%-20%) # # # # # 
    X_train,X_test,y_train,y_test=train_test_split(X,y, test_size=0.1, random_state=42)

    model = Sequential()
    # this 25 has nothing to do with 27 channels + 3 stim_dummy! Ramy set it to 24 orignially when I had no stim_code
    model.add(LSTM(25, input_shape=(X.shape[1], X.shape[2]), return_sequences=True, implementation=2))
    model.add(TimeDistributed(Dense(1)))
    model.add(AveragePooling1D())
    model.add(Flatten())
    model.add(Dense(1, activation='linear'))

    model.compile(loss='mean_absolute_error', optimizer='adam', metrics=['mean_absolute_error'])
    print(model.summary())
    
    # Callback
    
    # simple early stopping
    ES = EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=400) 
    
    FileName_BestModel = 'Run'+str(run+1)+'/Models/BestModel_' + DataCode + '.h5'
    checkpoint_name = FileName_BestModel
    MC = ModelCheckpoint(checkpoint_name, monitor='val_loss', verbose = 1, save_best_only = True, mode ='auto')
    callbacks_list = [ES, MC]
    
    
    # Model Fitting
    history = model.fit(X_train, y_train, epochs= 2, batch_size= 64, validation_data=(X_test, y_test), shuffle=False, callbacks=callbacks_list, verbose=1)
    
    # list all data in history
    print(history.history.keys())
    # summarize history for loss
    
    LossPlotFileName = 'Run'+str(run+1)+'/Plots/Loss' + DataCode + '.png'

    plt.clf()
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper right')
    plt.savefig(LossPlotFileName)
    
    # load the saved model
    best_model = load_model(FileName_BestModel)
    
    # make predictions
    y_train_Predicted = best_model.predict(X_train)
    y_test_Predicted = best_model.predict(X_test)
    
    TestPlotFileName  = 'Run'+str(run+1)+'/Plots/Test'  + DataCode + '.png'
    
   
    # Plot Original and Predicted Test Labels
    plt.clf()
    plt.plot(y_test)
    plt.plot(y_test_Predicted)
    plt.title('Original and Predicted at Test based on ' + subband)
    plt.ylabel('Response Time')
    plt.xlabel('epoch')
    plt.legend(['Original', 'Predicted'], loc='upper left')
    plt.savefig(TestPlotFileName)
    
    
    # Evaluate the prediction performanceof on the Standarized Data
    print (FileName_BestModel)
    MSE_Train = mean_absolute_error(y_train, y_train_Predicted)
    print ("MAE_Train = ") 
    print (round(MSE_Train,4))
    MSE_Test = mean_absolute_error(y_test, y_test_Predicted)
    print ("MAE_Test = ") 
    print (round(MSE_Test,4))
    R2_score_Train = r2_score(y_train, y_train_Predicted)
    print ("R2_score_Train = ") 
    print (round(R2_score_Train,4))
    R2_score_Test = r2_score(y_test, y_test_Predicted)
    print ("R2_score_Test = ") 
    print (round(R2_score_Test,4))

    
    
#--------------------------------------------------------------------------------------------------
    


def NewTest_ReturnValue (ModelNameStr, X, y):
    
    best_model = load_model(ModelNameStr) 
     

    # make predictions
    y_Predicted = best_model.predict(X)

    print (ModelNameStr)
    MAE_Test = mean_absolute_error(y, y_Predicted)
    print (round(MAE_Test,4))

    #The standard error is calculated by dividing the standard deviation by the square root of number of measurements that make up the mean 
    

    return (y,y_Predicted, MAE_Test)

#-------------------------------------------
def compile_saliency_function(model):
  """
  Compiles a function to compute the saliency maps and predicted classes
  for a given minibatch of input images.
  """
  inp = model.layers[0].input
  outp = model.layers[-1].output
  max_outp = K.max(outp, axis=1)
  saliency = K.gradients(max_outp[0], inp)[0]
  #saliency = K.tf.GradientTape(max_outp[0], inp)[0]
  #saliency = K.GradientTape(max_outp[0], inp)[0]
  max_class = K.argmax(outp, axis=1)
  return K.function([inp], [saliency])

def Test_Saliency2 (FileName_BestModel,X):
    
    # SalMaps_ALL = np.zeros((30,1000,2)) 
    # RTs_2Save   = np.zeros(2)
       
    inp = X
    best_model = load_model(FileName_BestModel)
    sal = compile_saliency_function(best_model)(inp)
    sal_gray = np.maximum(sal[0], 0)
    sal_gray /= np.max(sal_gray)
    
    save_sal_gray = sal_gray
    
    # sal_gray = sal_gray.sum(axis = 2)

    # res1000_smooth =[]
    # # plt.figure(), plt.title(what)
    # for i in range (X.shape[0]):
    #     temp = sal_gray[i,:]
    #     new = savgol_filter(temp, window_length=101, polyorder=5)
    #     res1000_smooth.append(new)
    
    # return(save_sal_gray, res1000_smooth)
    return (save_sal_gray)
    
        
    # plt.figure(), plt.title(what)
    # ax = sns.heatmap(sal_gray2)
    # plt.axvline(x = tpre1, color='y', linestyle='--')
    # plt.axvline(x = tpre2, color='y', linestyle='--')
    
    # plt.axvline(x = texc2+0.2, color='b', linestyle='--')
    # plt.axvline(x = texc4, color='b', linestyle='--')
    
    # plt.axvline(x = tpos4+0.2, color='r', linestyle='--')
    

    # PlotFileName = what + ".PNG"
    # plt.savefig(PlotFileName)
    
    # #------------------- SUM over time OR channels ------------------
    
    # res1000 = np.sum(sal_gray2,0)


    # plt.figure(), plt.title(what)
    # res1000_smooth = savgol_filter(res1000, window_length=101, polyorder=5)
    # ax = plt.plot(res1000_smooth)
    # plt.axvline(x = tpre1, color='y', linestyle='--')
    # plt.axvline(x = tpre2, color='y', linestyle='--')
    
    # plt.axvline(x = texc2+0.2, color='b', linestyle='--')
    # plt.axvline(x = texc4, color='b', linestyle='--')
    
    # plt.axvline(x = tpos4+0.2, color='r', linestyle='--')
    
    # PlotFileName = what + "_sum1000.PNG"
    # plt.savefig(PlotFileName)

    # return (SalMaps_ALL, RTs_2Save)
def NewTest_ReturnValue_Spatial (ModelNameStr, X, y):
    
    best_model = load_model(ModelNameStr) 
    trials,timepoints,channels = np.shape(X)
   
    ys_Predicted = np.zeros ((channels-3, trials))
    ys           = np.zeros ((channels-3, trials))
    
    corr_Test     = np.zeros(channels-3) 
    
    a = range(channels-3)  
                       

    for channel in range(channels-3): # last 7 bits are dummy codes about the GVS
        X1 = np.copy(X) 
    
        b = [x for i,x in enumerate(a) if i!=channel]   # [9, 8, 7, 5, 4, 3, 2, 1, 0]
        X1[:,:,b] = 0
 
        # make predictions
        y_Predicted = best_model.predict(X1)
        ys_Predicted[channel,:] = np.squeeze(y_Predicted)
        ys          [channel,:] = np.squeeze(y)
        y1 = np.squeeze(y)
        yp1 = np.squeeze(y_Predicted)
        
        yp2 = (yp1[1:int(trials/2)] + yp1[int(trials/2)+1:trials])/2
        y2 =  (y1[1:int(trials/2)] + y1[int(trials/2)+1:trials])/2
        r = np.corrcoef(y2,yp2 )
        corr_Test    [channel]   = r[0,1]
    return (ys,ys_Predicted, corr_Test)