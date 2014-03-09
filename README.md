project-oscilloscope
====================

A oscilloscope implementation on the Cyclone DE2 FPGA kit. 

Takes analog input signals using the ADC Daughter card and displays it on the VGA output

The PDF file gives the full report on the project.

oscilloscope.v contains the main state machine running the scope.
A copy has been put outside the project so that its easier to find.

Other files of interest are the trigger.v
This implements the auto trigger that is build in all scopes. The 
auto trigger is what refreshes the screen data for periodic data
at periodic intervals so that the display doesn't move around horizontally.
