# convert csv to sqlite

library(tidyverse)
library(DBI)
library(RSQLite)
library(here)
library(vroom)

# upload csv of tag data
sg_tags = read.csv('./data/fake_sql_database.csv', header = TRUE)

# create sql database/connection
mydb <- dbConnect(SQLite(), here('data', 'sg_database.sqlite'))

# dbRemoveTable(mydb, 'sg_tags') # remove any mistakenly created tables

# write csv data to sqlite database, table needs to be named 'tags' to be uploaded to SensorGnome
dbWriteTable(mydb, "tags", sg_tags, overwrite = TRUE)

# list tables in sql database
dbListTables(mydb)

# print first 5 rows of database
dbGetQuery(mydb, 'SELECT * FROM tags LIMIT 5')

# tag file from david's client
sg_db = dbConnect(SQLite(), here('data', 'tagfile_project_427_2024-05-07-09-00-57.sqlite'))





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

# converting tags table to R data frame
df_tags <- tbl_tags %>%
  rename(proj = projectID,
         id = tagID,
         tagFreq = nomFreq,
         dfreq = offsetFreq,
         codeset = codeSet) %>%
  select(proj, id, tagFreq, offset, bi, codeset) %>%
  distinct() %>% 
  arrange(id) %>%
  collect() %>% 
  as.data.frame()

motus_tags = df_tags[1:10,]
# motus_tags = read.csv('./data/df_alltags.csv', header = TRUE) %>%
#   top_n(10)

# create sql database/connection
motus_db <- dbConnect(SQLite(), './data/motus_database.sqlite')

# motus_sg = dbGetQuery(mydb, 'SELECT proj id bi, FROM tags ORDER BY proj, tagFreq, id, bi')


# dbRemoveTable(mydb, 'sg_tags') # remove any mistakenly created tables

# write csv data to sqlite database, table needs to be named 'tags' to be uploaded to SensorGnome
dbWriteTable(motus_db, "tags", motus_tags, overwrite = TRUE)

dbListTables(motus_db)

# print first 5 rows of database
dbGetQuery(motus_db, 'SELECT * FROM tags LIMIT 5')

### THIS CAN UPLOAD TO THE SENSORGNOME!!! double check the variables though