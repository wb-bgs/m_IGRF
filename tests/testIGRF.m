% Script based tests for igrf.m implementation of IGRF evaluation
% 
% 05-Dec-2024, Will Brown, British Geological Survey
% 
% Request IGRF values from BGS webservice API and validate igrf.m return
% against them.
% 
% Usage:
% >> results = runtests('testIGRF');

addpath('../')

% Set to current IGRF generation number
igrfGen = '14';
tol = 1; % IGRF given to 1nT precision, so allow for rounding discrepencies

%% Test 1: Definitive geodetic triple var
% Test definitive values, in geodetic, triple variable output
dates = '1960-5-13';
dt = datetime(dates);
lat = -45;
lon = -63;
alt = 50;
coords = 'geodetic';
[X, Y, Z] = igrf(dt, lat, lon, alt, coords);
[expX, expY, expZ] = igrfWebCalc(igrfGen, dates, lat, lon, alt, coords);
assertWithAbsTol([X,Y,Z], [expX,expY,expZ], tol, ...
    'Test 1: X,Y,Z geodetic does not match.')

%% Test 2: Definitive geocentric single var
% Test definitive values, in geocentic, single  variable output
dates = '1960-5-13';
dt = datetime(dates);
lat = -45;
lon = -63;
rds = 6412.68919478693; % approx match for 50km WGS84 altitude geodetic
coords = 'geocentric';
B = igrf(dt, lat, lon, rds, coords);
expB = igrfWebCalc(igrfGen, dates, lat, lon, rds, coords);
assertWithAbsTol(B, expB, tol, ...
    'Test 2: B geocentric does not match.')

%% Test 3: Latest predicted values
dates = '2029-12-31';
dt = datetime(dates);
lat = 58.2;
lon = 186.9;
alt = 0;
coords = 'geodetic';
B = igrf(dt, lat, lon, alt, coords);
expB = igrfWebCalc(igrfGen, dates, lat, lon, alt, coords);
assertWithAbsTol(B, expB, tol, ...
    'Test 3: SV prediction does not match.')

%% Test 4: Date to decimal year conversion
dates = '2000-7-2';
dt = datetime(dates);
dyr = 2000.5;
lat = -60;
lon = 360;
alt = -1;
coords = 'geodetic';
B = igrf(dt, lat, lon, alt, coords);
expB = igrfWebCalc(igrfGen, dyr, lat, lon, alt, coords);
assertWithAbsTol(B, expB, tol, ...
    'Test 4: Date to decimal year conversion does not match.')

%% Test 5: Date range
% Should really use the testcase class, but can cheat with try, catch...
dates = '1899-12-31';
dt = datetime(dates);
lat = 10;
lon = -180;
alt = -5;
coords = 'geodetic';
try
    B = igrf(dt, lat, lon, alt, coords);
catch ME
    if ~strcmp(ME.identifier, 'igrf:timeOutOfRange')
        error('Test 5: IGRF should not be valid prior to 1900-01-01.')
    end
end

dates = '2030-01-02';
dt = datetime(dates);
try
    B = igrf(dt, lat, lon, alt, coords);
catch ME
    if ~strcmp(ME.identifier, 'igrf:timeOutOfRange')
        error('Test 5: IGRF should not be valid after to 2030-01-01.')
    end
end

%% Test 6: Geographic poles
dates = '1927-08-05';
dt = datetime(dates);
lat = 90;
lon = 67;
alt = 500;
coords = 'geodetic';
B = igrf(dt, lat, lon, alt, coords);
expB = igrfWebCalc(igrfGen, dates, lat, lon, alt, coords);
assertWithAbsTol(B, expB, tol, ...
    'Test 6: Geographic north pole does not match.')

lat = -90;
B = igrf(dt, lat, lon, alt, coords);
expB = igrfWebCalc(igrfGen, dates, lat, lon, alt, coords);
assertWithAbsTol(B, expB, tol, ...
    'Test 6: Geographic south pole does not match.')

%% Test 7: vector input route
% Other test are all scalal route
dates = '1927-08-05';
dt = datetime(dates);
lat = -80;
lon = [-180, 0, 90];
rds = 6371.2;
coords = 'geocentric';
B = igrf(dt, lat, lon, rds, coords);
expB = nan(3);
for i = 1:3
    expB(i,:) = igrfWebCalc(igrfGen, dates, lat, lon(i), rds, coords);
end
assertWithAbsTol(B, expB, tol, ...
    'Test 7: Vectorised position calculation route does not match.')


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
% Helper function to assert equality within an absolute tolerance for all
% elements of an array.
% 
% Inputs:
%  actVal   Double, Test values
%  expVal   Double, Reference values
%  tol      Double, Absolute tolerance to test to
%  message  Char, Error message to display on failure of test

tf = all(abs(actVal-expVal) <= tol, 'all');
assert(tf, varargin{:});

end % function assertWithAbsTol()
