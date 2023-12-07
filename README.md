# census_tracts_IDs_from_geocoordinates
Extracting Census Tract FIPS codes from latitude and longitude coordinates using the tidycensus API.

 The datasets used for this example:
  
- [MappingPoliceViolence.org]("https://mappingpoliceviolence.org/)
- [US Census Demographic and Economic Data for Census Tracts and Counties]("https://www.kaggle.com/datasets/muonneutrino/us-census-demographic-data/data) from Kaggle

**Motivation**: This is a data wrangling and API-calling exercise as part of a broader research project looking at the impact that instances of local police violence have on the neighborhoods in which that violence occurs. From MappingPoliceViolence.org I have a geocoded repository of instances of fatal police interactions nationwide, but unfortunately the "tract" variable is quite messy in the original dataset. For that reason I am leveraging the spatial package *sf* and the census API-calling package "tidycensus* to manually impute FIPS codes for Census Tracts that saw instances of police violence. For the purposes of this tutorial, I will only be imputing FIPS codes for instances in California.

Script loosely follows the tutorial outlined here: https://stackoverflow.com/questions/52248394/get-census-tract-from-lat-lon-using-tigris
