Contents of this directory

README.txt  this file

SWOT_NNiceconcret.m   A MATLAB routine used to produce an autonomous ice concentration estimate from SWOT data.
		      For instructions on use in the MATLAB command window type "help SWOT_NNiceconcret.m"

swot_ice_conc_net2_20240511.mat Binary MATLAB save file containing the neural network weights and structure parameters used by
				SWOT_NNiceconcret

compute_var2.m        A routine to compute the variance in the 3x3 neighborhood of each pixel in the input array

output_ice_conc_009_015.txt  Example output when ice concentration retrieval is run with the SWOT data file
                             SWOT_L2_LR_SSH_Expert_009_015_20240104T153441_20240104T162609_PIC0_01.nc.
                             The SWOT data can be obtained from https://podaac.jpl.nasa.gov/dataset/SWOT_L2_LR_SSH_2.0

