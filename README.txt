Before you start:
- download the buffer_bci folder from https://github.com/jadref/buffer_bci
- in myInit line 8 change the string to the path of your buffer_bci installation

The main file will just clean the workspace and run BCI_GUI
(run the GUI direclty if you prefere having a dirty workspace)

The system expects the BioSemi to be already on and connected, otherwise it
will run the proxy of randomly generated signals.

Via the GUI it is possible to run the application, to train the classifier 
it is necessary to either load a previously saved set of calibration data or
to create a new one.
To perform a new calibration set up the electrodes to be used: the positions
are in the notation of a 64 electrodes-cap and there is the need of mapping
those positions to a 32 electrodes recording.
Write in the table the number of the electrode used in each position.
If you are using 64 electrodes, the system works as well, just remember that
'A' electrodes will be from 1 to 32 and 'B' from 33 to 64.


Communication with Unity via TCP/IP. VR set up for use with HTC Vive.
