function ttabd = dt2d(ttabt)
% PURPOSE: Aggregate data with multiple observations per day to daily by adding up.
% INPUTS:
% ttabt - table/timetable with potentially multiple observations per day
% OUTPUT:
% ttabd - table/timetable with daily data with one observation per day

if isa(ttabt, 'table')
    ttabt = table2timetable(ttabt);
    b_table = true;
elseif isa(ttabt, 'timetable')
    b_table = false;
else
    error('Please provide a table or a timetable')
end

[T,N] = size(ttabt);

% convert nonnumeric entries to NaN
for nn = 1:N
    if ~isnumeric(ttabt.(nn))
        ttabt.(nn) = nan(T,1);
    end
end

% all dates, unique dates
dates = dateshift(ttabt.(ttabt.Properties.DimensionNames{1}), "start", "day");
udates = unique(dates);
udates.Format = "uuuu-MM-dd";
Td = length(udates);

% aggregate by unique dates
datad = nan(Td,N);
for dd = 1:Td
    % select rows corresponding to the unique date dd
    rowsdd = ttabt{dates == udates(dd), :};

    % by variable, if not all NaNs, replace by zero
    for nn = 1:N     
        if ~all(isnan(rowsdd(:,nn)))
            % sum(...,"omitnan") changes NaN to 0
            rowsdd(:,nn) = sum(rowsdd(:,nn), 2, "omitnan");
        end
    end

    datad(dd,:) = sum(rowsdd, 1);
end

ttabd = array2timetable(datad, 'RowTimes', udates, ...
    'VariableNames', ttabt.Properties.VariableNames, ...
    'DimensionNames', {'Date','Variables'});

if b_table
    ttabd = timetable2table(ttabd);
end
