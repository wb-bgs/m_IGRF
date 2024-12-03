function [g, h] = loadigrfcoefs(dates)

% LOADIGRFCOEFS Load coefficients used in IGRF model.
% 
% Usage: [G, H] = LOADIGRFCOEFS(DATES) or GH = LOADIGRFCOEFS(DATES)
% 
% Loads the coefficients used in the IGRF model at time TIME in MATLAB
% serial date number format and performs the necessary interpolation. If
% two output arguments are requested, this returns the properly
% interpolated matrices G and H from igrfcoefs.mat. If just one output is
% requested, the proper coefficient vector GH from igrfcoefs.mat is
% returned.
% 
% If this function cannot find a file called igrfcoefs.mat in the MATLAB
% path, it will try to create it by calling GETIGRFCOEFS.
% 
% Inputs:
%   -DATES: Time to load coefficients either in MATLAB datetime format or a
%   string that can be converted into MATLAB datetime format using DATETIME
%   with no format specified (see documentation of DATETIME for more
%   information). 
% 
% Outputs:
%   -G: g coefficients matrix (with n going down the rows, m along the
%   columns) interpolated as necessary for the input TIME.
%   -H: h coefficients matrix (with n going down the rows, m along the
%   columns) interpolated as necessary for the input TIME.
%   -GH: g and h coefficient vector formatted as:
%   [g(n=1,m=0) g(n=1,m=1) h(n=1,m=1) g(n=2,m=0) g(n=2,m=1) h(n=2,m=1) ...]
% 
% Edits:
%  26-Nov-2019, Will Brown, British Geological Survey
%    Corrected error with input of 1900.0 exactly
%  18-Nov-2024, Will Brown, British Geological Survey
%    Modernised to use datetime in place of datenum.
% 
% See also: IGRF, GETIGRFCOEFS.

% Convert time to a datenumber if it is a string.
if ~isdatetime(dates)
    dates = datetime(dates);
end
% Make sure time has only one element.
if numel(dates) > 1
    error('loadigrfcoefs:timeInputInvalid', ['The input TIME can only ' ...
        'have one element']);
end

% Convert time to fractional years.
tStart = dateshift(dates, 'start', 'year');
tEnd = tStart + calyears(1);
dates = year(dates) + (dates - tStart) ./ (tEnd - tStart);

% Load coefs and years variables.
if ~exist('igrfcoefs.mat', 'file')
    getigrfcoefs;
end
load igrfcoefs.mat coefs;

% Check validity on time.
years = cell2mat({coefs.year});
if dates < years(1) || dates > years(end)
    error('igrf:timeOutOfRange', ['This IGRF is only valid between ' ...
        num2str(years(1)) ' and ' num2str(years(end))]);
end

% Get the nearest epoch that the current time is between.
lastepoch = find(years < dates, 1, 'last');
if isempty(lastepoch)
    lastepoch = 1;
end
nextepoch = lastepoch + 1;

% Output either g and h matrices or gh vector depending on the number of
% outputs requested.
if nargout > 1
    
    % Get the coefficients based on the epoch.
    lastg = coefs(lastepoch).g; lasth = coefs(lastepoch).h;
    nextg = coefs(nextepoch).g; nexth = coefs(nextepoch).h;
    
    % If one of the coefficient matrices is smaller than the other, enlarge
    % the smaller one with 0's.
    if size(lastg, 1) > size(nextg, 1)
        smalln = size(nextg, 1);
        nextg = zeros(size(lastg));
        nextg(1:smalln, (0:smalln)+1) = coefs(nextepoch).g;
        nexth = zeros(size(lasth));
        nexth(1:smalln, (0:smalln)+1) = coefs(nextepoch).h;
    elseif size(lastg, 1) < size(nextg, 1)
        smalln = size(lastg, 1);
        lastg = zeros(size(nextg));
        lastg(1:smalln, (0:smalln)+1) = coefs(lastepoch).g;
        lasth = zeros(size(nexth));
        lasth(1:smalln, (0:smalln)+1) = coefs(lastepoch).h;
    end

    % Calculate g and h using a linear interpolation between the last and
    % next epoch.
    if coefs(nextepoch).slope
        gslope = nextg;
        hslope = nexth;
    else
        gslope = (nextg - lastg)/diff(years([lastepoch nextepoch]));
        hslope = (nexth - lasth)/diff(years([lastepoch nextepoch]));
    end
    g = lastg + gslope*(dates - years(lastepoch));
    h = lasth + hslope*(dates - years(lastepoch));
    
else
    
    % Get the coefficients based on the epoch.
    lastgh = coefs(lastepoch).gh;
    nextgh = coefs(nextepoch).gh;
    
    % If one of the coefficient vectors is smaller than the other, enlarge
    % the smaller one with 0's.
    if length(lastgh) > length(nextgh)
        smalln = length(nextgh);
        nextgh = zeros(size(lastgh));
        nextgh(1:smalln) = coefs(nextepoch).gh;
    elseif length(lastgh) < length(nextgh)
        smalln = length(lastgh);
        lastgh = zeros(size(nextgh));
        lastgh(1:smalln) = coefs(lastepoch).gh;
    end
    
    % Calculate gh using a linear interpolation between the last and next
    % epoch.
    if coefs(nextepoch).slope
        ghslope = nextgh;
    else
        ghslope = (nextgh - lastgh)/diff(years([lastepoch nextepoch]));
    end
    g = lastgh + ghslope*(dates - years(lastepoch));
    
end