# 13th Generation International Geomagnetic Reference Field

The International Geomagnetic Reference Field (IGRF) model is the
empirical representation of the Earth's magnetic field recommended for
scientific use by a special Working Group of the International
Association of Geomagnetism and Aeronomy (IAGA). The IGRF model
represents the main (predominatly core) field without external sources.
The model employs the usual spherical harmonics expansion of the scalar
potential in geocentric coordinates. The IGRF model coefficients are
based on all available data sources including geomagnetic measurements 
from observatories, ships, aircrafts and satellites.

The IGRF model consists of sets of coefficients for a global
representation of the Earth magnetic field for the years 1945, 1950,
1955, etc. There are definitive coefficient sets (`DGRF####.DAT`; ####
= year) for which no further revisions are anticipated and
`IGRF####.DAT` and `IGRF####S.DAT` for which future updates are
expected. `IGRF####S.DAT` provides the first time derivatives of the
coefficients for extrapolation into the future. The 13th generation of
the IGRF model (IGRF-13) consists of definitive coefficients sets for
1900 thru 2015 (DGRF1945 thru DGRF2015) and preliminary sets for 1900 to
1940 and for 2020 (IGRF2020) and for extrapolating from 2020 to 2025
(`IGRF2020s.DAT`).

## Overview

This program is a conversion of the FORTRAN subroutines that make
the calculation into MATLAB. It does not use a compiled FORTRAN mex
file, which probably makes it slower but at the advantage of being
easier to use (as no compilation is necessary). In fact, my motivation
in writing the program was to provide an IGRF implementation in MATLAB
with minimal "fuss." Another motivation was a vectorized IGRF function,
which this function is (with a separate routine adapted directly from
the FORTRAN code that is faster for scalars implemented as well).

The following files are provided:
 - `igrf.m`: Computes Earth's magnetic field at a point(s).
 - `igrfline.m`: Gives the coordinates along a magnetic field line starting at a given point.
 - `getigrfcoefs.m`: Extracts coefficients from the .dat files provided on the IGRF website and saves them to a .mat file.
 - `igrfcoefs.mat`: IGRF coefficients of the 13th IGRF generation (most recent as of 2020).
 - `loadigrfcoefs.m`: Loads the proper IGRF coefficients at a given time (making the necessary interpolation).
 - `*grf*.dat`: 13th generation IGRF coefficient data files.
 - `plotbline`: Plots a magnetic field line.
 - `plotbearth`: Plots a number of magnetic field lines.
 - `geod2ecef`: Converts geodetic coordinates to ECEF coordinates.
 - `ecef2geod`: Converts ECEF coordinates to geodetic.

The only prerequisite to running either the function IGRF or the
function IGRFLINE is to put the file igrfcoefs.mat in the MATLAB search
path. The program is designed to be scalable with time: As new IGRF
generations are released, simply replace the old .dat files with their
newer versions in a subfolder called 'datfiles' within the same
directory that the function getigrfcoefs.m is located and run
`getigrfcoefs`, and then replace the file it generates (`igrfcoefs.mat`)
with the old .mat file. Updates happen every five years, with the last
update occurring in 2020. New .dat files will hopefully continue to be
uploaded to the following website,
https://ccmc.gsfc.nasa.gov/pub/modelweb/geomagnetic/igrf/fortran_code/.

Finally, I have included two example scripts showing how the function
IGRFLINE works: `plotbline.m` and `plotbearth.m`. These scripts both
utilize the Mapping Toolbox to plot globes upon which magnetic field
lines are plotted, but if the user does not have that package, a crude
globe with just latitude and longitude lines is shown.

I've made some cursory comparisons with the online IGRF calculator at,
http://ccmc.gsfc.nasa.gov/modelweb/models/igrf_vitmo.php,
and found this function to be accurate to within 1 nT. I'm not sure why
there is a discrepancy between the two, but my guess is round-off error.

## Other resources

The IGRF homepage is at,
http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html,
where data files, publications, and Fortran and Python evaluation codes
for the model are also available.

A web calculator, geomagnetic coordinate calculator, and other resources
are availale at,
https://geomag.bgs.ac.uk/data_service/models_compass/home.html.

## Authors

This code was orignally written by Drew Compton, as provide on the
Matlab File Exchange,
Drew Compston (2021). International Geomagnetic Reference Field (IGRF)
Model
(https://www.mathworks.com/matlabcentral/fileexchange/34388-international-geomagnetic-reference-field-igrf-model),
MATLAB Central File Exchange. Retrieved December 8, 2020.

It was updated for IGRF-13 by William Brown, British Geological Survey
in December 2019. Contact wb@bgs.ac.uk, or see,
https://github.com/wb-bgs/m_IGRF.

## Edits
 - 06 Feb 2021: Another name conflict, 'years' is a built in now too!
 - 19 Dec 2019: Correction for final roundings of IGRF-13 coefficients
 - 11 Dec 2019: IGRF-13 coefficients added
 - 26 Nov 2019: Correction to allow return of field at 1900.0, removed name clash of `year` variable
