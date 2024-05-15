# Load the packages for use
library(motus)
library(motusData)
library(tidyverse)
library(ggspatial)
library(rnaturalearth)


Sys.setenv(TZ = "UTC")

sql_motus <- tagme(projRecv = 176, new = TRUE, dir = "./data/")
# username: motus.sample
# password: motus.sample

metadata(sql_motus)
tbl_recvDeps <- tbl(sql_motus, "recvDeps")



# Downloading multiple receivers at the same time -------------------------
df_serno <- tbl_recvDeps %>%
  filter(projectID == 176) %>%
  select(serno) %>%
  distinct() %>%
  collect() %>%
  as.data.frame()

for (row in 1:nrow(df_serno)) {
  tagme(df_serno[row, "serno"], dir = "./data/", new = TRUE)
}

# Create a list of receivers you'd like to download if you don't want to download project-wide receivers
# create list of receivers you'd like to download
df.serno <- c("SG-AB12RPI3CD34", "SG-1234BBBK4321")

# loop through each receiver (may take a while!), and save to the working directory
for (k in 1:length(df.serno)) {
  tagme(df.serno[k], new = TRUE)
}

# loop through each receiver (may take a while!), and save to a specified directory
for (k in 1:length(df.serno)) {
  tagme(df.serno[k], dir = "./data/", 
        new = TRUE)
}


# Updating all .motus files within a directory ----------------------------

# If you have them saved your working directory:
tagme()

# If you have them saved in a different directory:
tagme(dir = "./data/")


# Accessing downloaded detection data -------------------------------------

library(DBI)
library(RSQLite)

# specify the filepath where your .motus file is saved, and the file name.
file.name <- dbConnect(SQLite(), "./data/project-176.motus") 

# get a list of tables in the .motus file specified above.
dbListTables(file.name) 

# get a list of variables in the "species" table in the .motus file.
dbListFields(file.name, "species") 

# retrieve the virtual alltags table from our sql_motus SQLite file
tbl.alltags <- tbl(sql_motus, "alltags")

# src is a list that provides details of the SQLiteConnection, including the directory where the database is stored.

# second part (lazy_query) is a list that includes the underlying table. -> tbl.alltags is a virtual table that stores the database structure and information requred to connect to the underlying data in the motus file.

# use collection function to get access to components of the underlying data frame
tbl.alltags %>% 
  collect() %>%
  names() # list the variable names in the table


# Converting to flat data -------------------------------------------------

df.alltags <- tbl.alltags %>% 
  collect() %>% 
  as.data.frame() %>%     # for all fields in the df (data frame)
  mutate(time = as_datetime(ts)) # after collecting data, mutate datetime so it uses origin of 1 Jan 1970 and UTC as timezone

# grab a subset of variables, in this case a unique list of Motus tag IDs at each receiver and antenna
# to grab a subset of variables, in this case a unique list of Motus tag IDs at
# each receiver and antenna.
df.alltagsSub <- tbl.alltags %>%
  select(recv, port, motusTagID) %>%
  distinct() %>% 
  collect() %>% 
  as.data.frame() 

# filter to include only motusTagIDs 16011, 23316
df.alltagsSub <- tbl.alltags %>%
  filter(motusTagID %in% c(16011, 23316)) %>% 
  collect() %>% 
  as.data.frame() %>%    
  mutate(time = as_datetime(ts))    

# filter to only Red Knot (using speciesID)
df.4670 <- tbl.alltags %>%
  filter(speciesID == 4670) %>%  
  collect() %>% 
  as.data.frame() %>%    
  mutate(time = as_datetime(ts))  

# filter to only Red Knot (using English name)
df.redKnot <- tbl.alltags %>%
  filter(speciesEN == "Red Knot") %>%   
  collect() %>% 
  as.data.frame() %>%    
  mutate(time = as_datetime(ts))    

# find the number of different detections for each tag at each receiver
df.detectSum <- tbl.alltags %>% 
  count(motusTagID, recv) %>%
  collect() %>%
  as.data.frame() 


# Exporting detections ----------------------------------------------------

saveRDS(df.alltags, "./data/df_alltags.rds")

write.csv(df.alltags, "./data/df_alltags.csv")


# Updating a database -----------------------------------------------------

# updating detections
sql_motus <- tagme(projRecv = 176, dir = "./data/", new = FALSE, update = FALSE)


# Checking for new detections ---------------------------------------------

# tellme() function returns list with:
## numHits - number of new tag dettections
## numBytes - approximate uncompressed size of data transfer required, in megabytes
## numRuns - number of runs of new tag detections, where a run is a series of continuous detections for a tag on a give antenna
## numBatches - number of batches of new data
## numGPS - number of GPS records of new data

tellme(projRecv = 176, dir = "./data/")


# Updating metadata -------------------------------------------------------

sql_motus <- tagme(projRecv = 176, forceMeta = TRUE, dir ="./data/")


# Import full tag and receiver metadata -----------------------------------

#access all tag and receiver metadata for all projects in the network
metadata(sql_motus)

# access tag and receiver metadata associated with project 176
metadata(sql_motus, projectIDs = 176)

# access tag and receiver metadata associated with projects 176 and 1
metadata(sql_motus, projectIDs = c(176, 1))


library(tidyverse)
library(DBI)
library(RSQLite)
library(here)
library(vroom)
