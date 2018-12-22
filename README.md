# NDCP
Noisy Dispersion Curve Picking
				
Suite package to pick velocity group dispersion curves of surface waves from noise cross correlation data and earthquakes,  Version 1.0
										
INPUT FILES:

NDCP handles data in SAC format (https://ds.iris.edu/files/sac-manual/manual/file_format.html ). 
Data must be placed in a same folder.
SAC header must contain Station and Event information (latitude, longitude, origin time of the record and of the earthquake if the case).
To avoid border effects at long periods filtering (for earthquakes records), we suggest to add a broad time window (around 20% of the earthquake duration), before and after the seismogram.


TO RUN NDCP:
1) set the path of the NDCP folder in the matlab environment  
2) execute the main script p1_NDCP.m
3) select the data type and select the data folder in the popup window
4) select whatever file, NDCP will read all the SAC files inside the folder.


DEFINING FTAN PARAMETERS:
When a file is selected, NDCP reads and displays the Waveform and Amplitude Spectrum.
pre-defined FTAN parameters:
Distance (km): directly read from the SAC HEADER

Tmin (s): minimum period to be analyzed 
T max (s): maximum period to be analyzed
fstep log(s)): step (distance in seconds) between two consecutive filters 
width (log(s)) length of the filter window 
filter order: 
Cut signal: option to select a subset of the displayed data (put nothing if the whole signal is kept)

Default values are automatically calculated depending on the station-station or event-station interdistance.


Once the parameters are defined, NDCP will calculate and display the FTAN analysis for each record:
- FTAN waveforms of Seismic record, at top left.
- Seismic record, at bottom left.
- Velocity-Period diagram, at bottom right.
- FTAN envelopes for picking dispersion curves, at top right.

PICKING OF THE DISPERSION CURVE:

1) let click on PICKING OF DISPERSION CURVE BUTTON. In the case of cross correlation data, user has to select the part of the signal to be picked (causal or non causal). for CC data users can pick, only one branch or both by selecting them one per time. If user needs to modify the picking, can do it just selecting once again the button ÒPICKING OF DISPERSION CURVE BUTTONÓ ( for records) or causal/non causal ( for cross correlations)
2) let click and hold the cursor on the FTAN envelopes (top right box); then release it only at the end of the picking.
3) let click on SAVE CURVE to keep the result on the workspace.
4) let Click PREVIOUS or NEXT button to analyze the next or the previous data.

EXPORTING PICKED CURVES:
Upon all curves are picked and saved, the button ÒEXPORT ALL CURVESÓ writes a 4-column ASCII file for each data analyzed in the working folder with the following information:

        name of the file: the same as of the input data (EXAMPLE.txt)

	1st  col. 	Frequency [Hz]
	2nd. col. 	Period [s]
	3rd. col.	Velocity [km/s]
	4th. col. 	Picked time [s]


	
	
To cite NDCP:
Granados, I., Calo, M., and Ramos, V. (2018). NOISY DISPERSION CURVE PICKING (NDCP): a Matlab package for group velocity dispersion picking of seismic surface waves. 
Submitted to "Computer and Geosciences".

Comments and remarks can be sent to IGranadosC@igeofisica.unam.mx

