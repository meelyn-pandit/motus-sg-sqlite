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
sg_tags = read.csv('./data/fake_sql_database2.csv', header = TRUE)

# create sql database/connection
sg_db <- dbConnect(SQLite(), './data/sg_database.sqlite')

# write csv data to sqlite database, table needs to be named 'tags' to be uploaded to SensorGnome
dbWriteTable(sg_db, "tags", sg_tags, overwrite = TRUE)

# list tables in sql database
dbListTables(sg_db)

# print first 5 rows of database
dbGetQuery(sg_db, 'SELECT * FROM tags')

dbDisconnect(sg_db)

