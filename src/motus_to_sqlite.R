library(tidyverse)
library(DBI)
library(RSQLite)
library(vroom)
library(motus)
library(motusData)
library(ggspatial)
library(rnaturalearth)

# Writing Motus's tags into sqlite --------------------------------------

# Downloading motus database based on project
Sys.setenv(TZ = "UTC") # set system time

sql_motus <- tagme(projRecv = 176, new = TRUE, dir = "./data/")
# username: motus.sample
# password: motus.sample

# obtain database metadata
metadata(sql_motus)

# retrieve the virtual alltags table from our sql_motus SQLite file
tbl_tags <- tbl(sql_motus, "tags")

# converting tags table to R data frame - needs column dfreq
# dfreq = dfreq + (-1000*(tagFreq-fcdFreq))
# example fron SG tag database

df_tags <- tbl_tags %>%
  rename(proj = projectID,
         id = tagID,
         tagFreq = nomFreq,
         dfreq = offsetFreq,
         codeset = codeSet) %>%
  mutate(fcdFreq = 166.376) %>%
  select(proj, id, tagFreq, dfreq, bi, codeset, fcdFreq) %>%
  distinct() %>% 
  arrange(id) %>%
  collect() %>% 
  as.data.frame()

motus_tags = df_tags[1:10,]


# create sql database/connection
motus_db <- dbConnect(SQLite(), './data/motus_database.sqlite')

# write csv data to sqlite database, table needs to be named 'tags' to be uploaded to SensorGnome
dbWriteTable(motus_db, "tags", motus_tags, overwrite = TRUE)

# list tables in database
dbListTables(motus_db)

# print first 5 rows of database
dbGetQuery(motus_db, 'SELECT * FROM tags')

# disconnect from database
dbDisconnect(motus_db)
dbDisconnect(sql_motus)
