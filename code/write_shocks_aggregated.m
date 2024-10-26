function [ttabt, ttabd, ttabm] = write_shocks_aggregated(U, RowTimes, fnameroot)
% PURPOSE: Write U to csv, also aggregated to daily and monthly
% INPUTS:
% U - array to be saved, T x N
% RowTimes - T x 1
% fnameroot - string, foot of the filenames

% Write original shocks to csv
ttabt = write_shocks(U, RowTimes, fnameroot);

% Aggregate to daily and write
ttabd = dt2d(ttabt);
if height(ttabd) < height(ttabt)
    write_shocks(ttabd{:,:}, ttabd.Properties.RowTimes, fnameroot + "_d");
end

% Aggregate to monthly and write
if 0
    % option 1 - write indexed by year,month
    tabm = d2m2q(ttabd);
    writetable(tabm, fnameroot + "_m.csv")
else
    % option 2 - write indexed by date
    ttabm = convert2monthly(ttabd, Aggregation="sum");
    ttabm = fillmissing(ttabm, "constant", 0);
    write_shocks(ttabm{:,:}, ttabm.Properties.RowTimes, fnameroot + "_m");
end