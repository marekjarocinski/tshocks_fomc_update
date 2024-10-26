function ttabt = write_shocks(U, RowTimes, fnameroot)
% PURPOSE: Write U to csv
% INPUTS:
% U - array to be saved, T x N
% RowTimes - T x 1
% fnameroot - string, foot of the filenames
round_to = 5;
u = round(U, round_to);
ttabt = array2timetable(u, "RowTimes", RowTimes);
writetimetable(ttabt, fnameroot + ".csv");

