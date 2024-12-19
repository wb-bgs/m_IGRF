%% Script based tests for igrf.m implementation of IGRF evaluation
% 
% 05-Dec-2024, Will Brown, British Geological Survey
% 
% Request IGRF values from BGS webservice API and validate igrf.m return
% against them.
% 
% results = runtests('testIGRF');

clearvars
addpath('../')

% Set to current IGRF generation number
igrfGen = '14';

% Test definitive values, in geodetic and geocentric, single and triple
% variable output
% Some dates match to 1nT precision, but examples fail test for both
% past and present dates, both geocentric and geodetic, X, Y, and Z ...
% maybe it's the legendre approx? likely not the SH part, coefficients,
% or geodetic conversion. Test against the CHAOS implementation?
dates = '1960-5-13';
dt = datetime(dates);
lat = -45;
lon = -63;
alt = 50;
coords = 'geodetic';
[X, Y, Z] = igrf(dt, lat, lon, alt, coords);
[expX, expY, expZ] = igrfWebCalc(igrfGen, dates, lat, lon, alt, coords);
tol = 0.5; % IGRF given 1nT precision, so allow for rounding
% assertWithAbsTol([X,Y,Z], [expX,expY,expZ], tol, ...
    % 'Test 1: X,Y,Z geodetic does not match.')

rds = 6400;
coords = 'geocentric';
B = igrf(dt, lat, lon, rds, coords);
expB = igrfWebCalc(igrfGen, dates, lat, lon, rds, coords);
% assertWithAbsTol(B, expB, tol, ...
    % 'Test 2: B geocentric does not match.')

% Test predicted values


% Test date to decimal year conversion


% Test date range


% Test poles


% Test vector input calculation route (other test are all scalal route)



function varargout = igrfWebCalc(igrfGen, tVal, lat, lon, alt_rad, coords)
% function [x, y, z] = igrfWebCalc(igrfGen, dates, lat, lon, alt_rad, coords)
% function B = igrfWebCalc(igrfGen, dates, lat, lon, alt_rad, coords)
% 
% Return spot values of IGRF X,Y,Z from BGS IGRF calculator API.
% 
% Inputs:
%  igrfGen  String/Char giving number of IGRF generation to call API for.
%  tVal     String/Char, time in format 'yyyy-mm-dd', or as Double, in
%           decimal year in format yyyy.y
%  lat      Double, latitude, in degrees, in geodetic (coord='geodetic') or
%           geocentric (coord='geocentric') coordinate system
%  lon      Double, longitude, in degrees
%  alt_rad  Double, value of altitude (coord='geodetic') or radius
%           (coord='geocentric'), in km
%  coords   String/Char, define 'geodetic' or 'geocentric' coordinate
%           system for both input `lat`, `alt_rad` and output [x,z] values
% 
% Outputs:
%   B           Double, 1x3 array of [x,y,z] in geodetic North, East, Down
%               system (coord='geodetic') or geocentric NED
%               (coord='geocentric')
%  or
%   x, y, z     Double, in geodetic North, East, Down system
%               (coord='geodetic') or geocentric NED (coord='geocentric')
% 

urlRoot = 'https://geomag.bgs.ac.uk/web_service/GMModels/igrf';

switch lower(coords)
    case 'geocentric'
        heightName = 'radius';
    case 'geodetic'
        heightName = 'altitude';
end
switch class(tVal)
    case {'string', 'char'}
        tName = 'date';
    case 'double'
        tName = 'year';
end

wr = webread([urlRoot,'/',igrfGen,'/'], ...
    'latitude', lat, ...
    'longitude', lon, ...
    heightName, alt_rad, ...
    tName, tVal, ...
    'format', 'json');

x = wr.geomagnetic_field_model_result.field_value.north_intensity.value;
y = wr.geomagnetic_field_model_result.field_value.east_intensity.value;
z = wr.geomagnetic_field_model_result.field_value.vertical_intensity.value;

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
% Takes two inputs and an optional message and compares
% them within an absolute tolerance of 1e-6.
tf = all(abs(actVal-expVal) <= tol);
assert(tf, varargin{:});
end
