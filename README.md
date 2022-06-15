# adcp-matlab
ADCP processing and analysis codes (MatLab version)  

**Preliminary Steps**

After deployment, connect instrument and extract .AD2CP files. Use either MIDAS or Signature Deployment software for Nortek Signature instruments.

If using MIDAS, convert .AD2CP files to .NTK files first. Then, convert .NTK to .MAT files for MatLab processing, or ASCII for other options of processing. With .MAT files, run **QuickLook.m** code to take a first look at the data and to do the beam to ENU conversion. Run code to save sequential .MAT files containing all ADCP data including ENU (East North Up/Earth coordinate) velocities. Generate plots of raw data (beam velocities). To look for in plots: Does the metadata information match the deployment information (ex. sampling period and sampling frequency)? What are the units/variables available in the Data and Config structures? 

**Attitude Parameters (AttitudeParams.m)**

1. Concatenates attitude parameters (heading, pitch, roll, pressure, battery) from all files, and save into a new structure (AttitudeParametersFast.mat). Plot heading, pitch, roll, pressure, battery to check instrument behavior over entire deployment. Calculate standard deviation and mean for attitude parameters (heading, pitch, roll)

2. Generate ensembles for attitude parameters, checks time steps in data to ensure that data was recorded as expected (i.e. at 4Hz for 5 min every 15 min), saves attitude parameters (heading, pitch, roll, pressure, battery) in 5 minute bursts 

**Quality Control w Amplitude and Correlation (AmpCorrQC.m)**

Runs quality control on ENU files from previous code. Detects free-surface and removes data with low amplitude and correlations. Uses vertical beam amplitudes to find the free surface. Use plot of pressure to determine range where free surface might fall (based on depth of deployment). Saves a series of QC files with modified data. Generates color plots and velocity plots for each file:

**Concatenate ENU Velocities for Deployment (GetVelocities.m)**

Grabs u, v, w variables from each QC file and concatenates them over the entire time series, applies conversion to True North (from magnetic north), saves velocities to their own .MAT files (need to save as 7.3 files because there is so much data)  

**Concatenate Beam Velocities for Deployment (GetBeamVelocities.m)**

Grabs b1, b2, b3, b4, b5 variables from each QC file and concatenates them over the entire time series, applies conversion to True North (from magnetic north), saves velocities to their own .MAT files (need to save as 7.3 files because there is so much data)  

**Convert from Instrument Coordinates to Signed Speed or Along/Across Stream (SignedSpeed.m)**

Gets true east and north velocities from GetVelocities.m code, and converts them to signed speed and along/across stream coordinates, saves concatenated velocities.

**Process Concatenated Files into Ensembles (VelocityEnsembles.m)**

Loads each velocity variable (ENU and along-beam) and creates the 5 minute ensembles. Needs to be run for each velocity component.

**Convert Velocities from Depth to Sigma Coordinates (to_sigma.m - function)**

Takes ensemble averaged velocities in depth coordinates and interpolates them to normalized terrain following (sigma) coordinates. Written as a function, and can be used to save individual sigma layer files, or for in situ processing
