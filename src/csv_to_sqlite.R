library(tidyverse)
library(DBI)
library(RSQLite)
library(vroom)
library(motus)
library(motusData)
library(ggspatial)
library(rnaturalearth)


# Convert CSV to SQLite ----------------------------------------------------------------

# upload csv of tag data
# necessary column headers: proj, id, tagFreq, fcdFreq(166.376), offsetFreq, codeset
# dfreq is calculated by SensorGnome with following equation:
# # dfreq = offsetFreq + (-1000*(tagFreq-fcdFreq))

sg_tags = read.csv('./data/sg_database.csv', header = TRUE)
sg_tags = sg_tags[1:10,]

# create sql database/connection
sg_db <- dbConnect(SQLite(), './data/sg_database.sqlite')

# write csv data to sqlite database, table needs to be named 'tags' to be uploaded to SensorGnome
dbWriteTable(sg_db, "tags", sg_tags, overwrite = TRUE)

# list tables in sql database
dbListTables(sg_db)

# print first 5 rows of database
dbGetQuery(sg_db, 'SELECT * FROM tags')

# disconnect database
dbDisconnect(sg_db)

