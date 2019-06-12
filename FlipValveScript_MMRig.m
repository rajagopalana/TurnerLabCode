% FLIPPING BETWEEN EMPTY OPEN AND ODOR OPEN
s=FlipValveUSB6525({'Vial1','Vial2','Vial3','Vial4','Vial5','Final'},[0 0 0 0 1 1],valvedio); % EMPTY OPEN (VIAL 5)
s=FlipValveUSB6525({'Vial1','Vial2','Vial3','Vial4','Vial5','Final'},[0 0 1 0 0 1],valvedio); % ODOR OPEN (VIAL 3)

% LEAVE VALVES IN NON-ENERGIZED STATE AT END
s=FlipValveUSB6525({'Vial1','Vial2','Vial3','Vial4','Vial5','Final'},[0 0 0 0 0 0],valvedio); % 

% % FLIPPING BETWEEN ODOR CLOSED FINAL OPEN - IGOR'S CARRIER AIRSTREAM DESIGN
% s=FlipValveUSB6525({'Vial1','Vial2','Vial3','Vial4','Vial5','Final'},[0 0 0 0 0 0],valvedio); % ODOR CLOSED (FINAL OPEN)
% s=FlipValveUSB6525({'Vial1','Vial2','Vial3','Vial4','Vial5','Final'},[0 0 1 0 0 1],valvedio); % ODOR OPEN (FINAL CLOSED)
% 
% % IT SEEMS THAT THERE CAN BE A PRESSURE BUILD-UP WHEN YOU DO IT IGOR'S WAY.
% % PERHAPS THAT'S BECAUSE THE TIMING OFFSET BETWEEN WHEN THE ODOR AND THE FINAL VALVES SWITCH 
% 
% % THERE MAY BE AN ISSUE WITH HOW I INDEX THE VALVES - CHECK THAT I'M
% % REALLY FLIPPING THE ONES I THINK I'M FLIPPING 
% 
% % HOW TO RELEASE DAQ AT END OF SESSION?  