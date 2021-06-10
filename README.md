# LSTM-based-Modeling and explaination of RT out of EEG

Source code for Deep and milti-level regression analysis in "A Deep Method for Prediction and Modeling of Behavioral Measurement from an Arbitrary Period of EEG" paper

0-EEG Preprocessing Pipeline: Extracts EEG data from the curry loader

1-Phase-Amp Perturbation: Builds filtered data using files in the folder Phase-Amp Perturbation

2- Train/validate the LSTM models (on full frequency range and sub-bands). Then test on spatial locations by running codes in the folder TrainModels. 

3-ML Confirmation and 4-Multi-level Regression Analysis of Features 

5-Statistical and Correlation Analysis
![image](https://user-images.githubusercontent.com/16546644/121608362-a44c2400-ca06-11eb-92db-b0c9479a0323.png)
