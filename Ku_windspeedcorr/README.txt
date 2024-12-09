Contents of this directory

README.txt  This file

Ku_NNwindspeedcorr.m  Method to correct SCATSAT1 and QuikSCAT wind speed retrievals for rain using a neural network
		      While in the MATLAB command window type "help Ku_NNwindspeedcorr" for instructions on how to use.


example_quikscat_tbh_orbit39239.txt Example input H polarization brightness temperature array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.
example_quikscat_ctd_orbit39239.txt Example input cross track distance array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.
example_quikscat_spdmle_orbit39239.txt Example input uncorrected MLE retrieved wind speed array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.
example_quikscat_s0hhfore_orbit39239.txt Example input linear scale HH polarized, fore look sigma0 array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.
example_quikscat_s0hhaft_orbit39239.txt Example input linear scale HH polarized, aft look sigma0 array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.
example_quikscat_s0vvfore_orbit39239.txt Example input linear scale VV polarized, fore look sigma0 array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.
example_quikscat_s0vvaft_orbit39239.txt Example input linear scale VV polarized, aft look sigma0 array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.

output_wind_speed_orbit39239.txt Example output array for Ku_NNwindspeedcorr from QuikSCAT orbit #39239.

scatsat1_windspeed_corr_net.mat Binary MATLAB save file with weights and structural parameters for the neural network that is used by Ku_NNwindspeedcorr

windspeedcorr_input_transform_QuikSCAT.mat  Binary MATLAB save file used to transform QuikSCAT inputs to match SCATSAT1 distributions

