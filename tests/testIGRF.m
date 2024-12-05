%% Script based tests for igrf.m implementation of IGRF evaluation
% 
% 05-Dec-2024, Will Brown, British Geological Survey
% 
% results = runtests('testIGRF');

clearvars

% Test definitive values


% Test predicted values


% Test date to decimal year conversion


% Test date range


% Test geodetic vs geocentric
dates = datetime(1960,5,13);
lat = ;
lon = ;
alt = 10;
coords = 'geodetic';
[X, Y, Z] = igrf(dates, lat, lon, alt, coords);
rds = 6400;
coords = 'geocentric';
B = igrf(dates, lat, lon, rds, coords);

% Test poles


function varargout = igrfWebCalc(dates, lat, lon, alt, coords)
% function [x, y, z] = igrfWebCalc()
% 
% Return IGRF X,Y,Z values from BGS IGRF calculator API.
% 
% Inputs:
%  
% 
% Outputs:
%  x    
%  y    
%  z    
% 

% https://geomag.bgs.ac.uk/web_service/GMModels/igrf/13/?latitude=-80&longitude=240&altitude=0&year=2000.5&format=json
url = 'https://geomag.bgs.ac.uk/web_service/GMModels/igrf/13/';

switch coords
    case 'geocentric'
        heightName = 'radius';
    case 'geodetic'
        heightName = 'depth';
end
switch tVal
    case 'geocentric'
        heightName = 'radius';
    case 'geodetic'
        heightName = 'depth';
end

wr = webread(url, ...
    'latitude', , ...
    'longitude', ...
    heightName, heightVal, ...
    tName, tVal);

switch nargout
    case 1
        varargout{1} = [x,y,z];
    case 3
        varargout{1} = x;
        varargout{2} = y;
        varargout{3} = z;
end


end % function igrfWebCalc()

function assertWithAbsTol(actVal,expVal,tol,varargin)
% Helper function to assert equality within an absolute tolerance.
% Takes two values and an optional message and compares
% them within an absolute tolerance of 1e-6.
tf = abs(actVal-expVal) <= tol;
assert(tf, varargin{:});
end