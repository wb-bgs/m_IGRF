# 14th Generation International Geomagnetic Reference Field

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
coefficients for extrapolation into the future. The 14th generation of
the IGRF model (IGRF-14) consists of definitive coefficients sets for
1900 thru 2020 (DGRF1945 thru DGRF2020) and preliminary sets for 1900 to
1940 and for 2025 (IGRF2025) and for extrapolating from 2025 to 2030
(`IGRF2025s.DAT`).

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
 - `igrfcoefs.mat`: IGRF coefficients of the 14th IGRF generation (most recent as of 2024).
 - `loadigrfcoefs.m`: Loads the proper IGRF coefficients at a given time (making the necessary interpolation).
 - `*grf*.dat`: 14th generation IGRF coefficient data files.
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
update occurring in 2024.

Finally, I have included two example scripts showing how the function
IGRFLINE works: `plotbline.m` and `plotbearth.m`. These scripts both
utilize the Mapping Toolbox to plot globes upon which magnetic field
lines are plotted, but if the user does not have that package, a crude
globe with just latitude and longitude lines is shown.

## Accuracy

Original author's comment (with 2025 https address updated)):
I've made some cursory comparisons with the online IGRF calculator at,
https://ccmc.gsfc.nasa.gov/modelweb/models/igrf_vitmo.php, and found
this function to be accurate to within 1 nT. I'm not sure why there is a
discrepancy between the two, but my guess is round-off error.

WB comment:
I have added a test function to compare output of `igrf.m` to the
official BGS IGRF calculator output. This confirms that this code can
typically match the output to 1nT. I have verified the algorithms for
Gauss coefficent interpolation in time, Legendre function derivative
calculation, and geodetic to geocentric coordinate tranformation against
independent codes.

1nT is the acepted precision to which IGRF field values should be given.
I have found that there are discepencies of 1nT at 1nT precision in a
small number of cases, which I have tracked down to language and system
dependent implementation of rounding used by the various "official" IGRF
codes available. Essentially, Fortran, C, Matlab and Python (etc) may
all work with different representation and precisions of float values,
and implement different rounding schemes when printing output values at
a specified precision, particularly on tie values that may be e.g.
rounded toward zero, away from zero, to even, etc, depending on the
specific implementation. It is difficult to exactly reproduce output
across implementations as each uses slightly different algorithms,
typically producing variations at less than 1e-3 in the computed values,
but that mean rounding and exact ties effected by rounding schemes are
not uniformly produced across codes.

Note also that handling of computations at the geographic poles is not
uniform between all codes and users should avoid calculations here, as
the vector spherical geocentric coordinate system is not well defined
there and assumptions must be made as to which way North and East are!

## Testing

To run the test cases, use:
  ```
  >> !cd tests
  >> results = runtests('testIGRF');
  ```
These tests only verify the output of `igrf.m` (and thus also
`loadigrfcoefs.m`) and require an internet connection to access the IGRF
API used to source expected model values for comparison.

## Other resources

The IGRF homepage and NOAA hosted resources are at,
`https://www.ncei.noaa.gov/products/international-geomagnetic-reference-field`
where data files, publications, and Fortran and Python evaluation codes
for the model are also available.

A BGS hosted web calculator, geomagnetic coordinate calculator, and other
resources are availale at,
`https://geomag.bgs.ac.uk/research/modelling/IGRF.html`.

A NASA CCMC hosted calculator is available at,
`https://ccmc.gsfc.nasa.gov/modelweb/models/igrf_vitmo.php`.

## Authors

This code was orignally written by Drew Compton, as provide on the
Matlab File Exchange,
Drew Compston (2021). International Geomagnetic Reference Field (IGRF)
Model
(`https://www.mathworks.com/matlabcentral/fileexchange/34388-international-geomagnetic-reference-field-igrf-model`),
MATLAB Central File Exchange. Retrieved December 8, 2020.

It was updated for IGRF-13 and IGRF-14 by William Brown, British
Geological Survey. The IGRF-14 onward includes testing to verify output
against the official BGS IGRF calculator.
Contact wb@bgs.ac.uk, or see,
`https://github.com/wb-bgs/m_IGRF.`

## Edits
 - 18 Nov 2024: IGRF-14 update, replaced `datenum` use with `datetime`,
                rounded output to 1nT precision, added testing against
                official calculator
 - 06 Feb 2021: Another name conflict, 'years' is a built in now too!
 - 19 Dec 2019: Correction for final roundings of IGRF-13 coefficients
 - 11 Dec 2019: IGRF-13 coefficients added
 - 26 Nov 2019: Correction to allow return of field at 1900.0, removed name clash of `year` variable
