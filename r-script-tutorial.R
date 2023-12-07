### Load libraries
library(tidyverse)
library(haven) # for reading dta files
library(lubridate) # for datetime
library(tigris) # for census data
library(sf) # for spatial data
library(tidycensus) # census api

### Load datasets

# Mapping Police Violence data
mpv_raw <- read_csv("/Users/taylor/Desktop/phd/research-local/data/police-violence-data/MPV03282023.csv")

# US Census Tract Demographics dataset from Kaggle
census_tract_demographics_raw <- read.csv("/Users/taylor/Desktop/phd/research-local/data/housing-neighborhoods/us-census-tracts/kaggle census tract demographic data/acs2017_census_tract_data.csv")

# Exploring different parts of the data before wrangling.
View(census_tract_demographics_raw)
dim(census_tract_demographics_raw)
colnames(census_tract_demographics_raw)
View(mpv_raw)
mpv_raw$tract # Missing a lot of census tracts
sum(is.na(mpv_raw$tract))
dim(mpv_raw)

### Clean up MPV data to be up to 2017, since the Census data only goes up to 2017 
mpv_raw$date <- as.Date(mpv_raw$date, format = "%m/%d/%Y")
mpv_raw$date

mpv_2017 <- mpv_raw %>%
  filter(date < "2018-01-01")

# Check sanity
dim(mpv_2017) # 5405 instances of fatal police violence nationwide up to 2017
min(mpv_2017$date) # 2012-04-07
max(mpv_2017$date) # Sanity check

### Filtering MPV data to just California
mpv_2017_CA <- mpv_2017 %>%
  filter(state == "CA")

mpv_2017_CA # 896 instances in CA

# Getting just latitude and longitude for instances in CA
mpv_2017_CA_long_lat_only <- mpv_2017_CA %>%
  select(longitude, latitude)


### Loading CA shapefile from tidycensus API + point data geoprocessing

# Getting CA census tract data (shapefile) from the Census API, per tutorial link above
ca <- tidycensus::get_acs(state = "CA", geography = "tract",
              variables = "B19013_001", geometry = TRUE)

# Convert to sf object of points, so that we can match it to the shapefile above
mpv_2017_CA_long_lat_sf <- mpv_2017_CA_long_lat_only %>%
  filter(!is.na(latitude), !is.na(longitude)) %>% # get rid of NAs
  st_as_sf(coords = c("longitude", "latitude"), crs = st_crs(ca)) # converting lat and long numbers to geometry object


### Visualization(s)

# Plot the sf object created above now that it's been geoprocessed
plot(mpv_2017_CA_long_lat_sf)

# Better visualization of the point data, overlaying CA shapefile 
ggplot(ca) +
  geom_sf() +
  geom_sf(data = mpv_2017_CA_long_lat_sf) +
  ggtitle("Mapping Police Violence in California 2012-2017 
(896 observations)")

### Extracting the FIPS codes for Census Tracts where police violence occurred

# Variable for all CA census tracts -- retrieving from tidycensus api
ca_tracts <- tracts("CA", class = "sf") %>%
  select(GEOID, TRACTCE)

# Creating boundaries around all CA census tracts
CA_bbox <- st_bbox(ca_tracts)

# Use st_join to find intersections of point data and/within CA census tracts
CA_points_tract <- st_join(mpv_2017_CA_long_lat_sf, ca_tracts) # spits out the tracts associated with the points 
CA_points_tract # 953 observations since many Census Tract IDs are duplicates (multiple instances of police violence)

# Create the dataframe to store all the fips codes for CA
tract_IDs_CA <- c(CA_points_tract$GEOID)

length(tract_IDs_CA) # 953 CA instances with census tracts
length(unique(tract_IDs_CA)) # 863 unique census tracts 

###  Final list of Census Tract IDs

# Remove duplicates for final list
tract_IDs_CA_final <- c(unique(tract_IDs_CA))
# Print final list
length(tract_IDs_CA_final) # sanity check to make sure there's only 863
print(tract_IDs_CA_final) # print Census Tract FIPS codes that experienced police violence through 2017


