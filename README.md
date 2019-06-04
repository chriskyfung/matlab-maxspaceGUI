maxspaceGUI
===========

“maxspaceGUI” is a MATLAB script developed to support burning files into DVD-R. It aids to maximise the utility of DVD-R by finding the optimal list of files.

Last compiled version:	**MATLAB 2010a**

## How to Use
1.	Open the folder “…\maxspaceGUI\maxspaceGUI\distrib\”.
2.	Type the file names wanted to be burnt and their corresponding file sizes into the excel file “temp.xls”.
3.	Run “maxspaceGUI.exe” (MATLAB executable file).
4.	Choose the DVD type, DVD-R (4.7GB) or DVD+R DL (8.5GB).
5.	Click the buttom “Optimize”.
6.	Click the buttom “View Results” to access the “results.xls”. In the “results.xls”, files to be burnt are listed in “sheet 1” while the unused files are stored in “sheet 2”.

## Other Functions
**Import**
Read *.idx files created by CD manager “CD Index” and convert information to a new “temp.xls”.

**Import Last**
Copy the “sheet 2” of “results.xls” to be “temp.xls”.

![Snapshot of the User Interface](/gui_snapshot.png)