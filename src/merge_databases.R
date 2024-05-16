### merge tag databases ####
# This function accepts a vector of file names 
# corresponding to the various tag databases to be merged. 
# It saves one tag database containing all the source dbs
# named 'SG_tag_database.sqlite' for copying onto a SG
# It also returns a data frame with the results for visual overview

merge_dbs <- function(db_list, out_db = 'SG_tag_database.sqlite'){
  library(RSQLite)
  
  out_df <- data.frame()
  
  # loop through the list of tag dbs to be merged
  for (i in db_list) {
    message('Processing ', i)
    # establish SQLite connection to the current tag database
    con <- dbConnect(SQLite(), i)
    # select all from the tags table of the tag database, as a data frame
    df <- dbGetQuery(con, 'SELECT * FROM tags')
    # bind (append) the resulting rows to the consolidated out_df data frame
    out_df <- rbind(out_df, df)
    # disconnect from the source tag database
    dbDisconnect(con)
  }
  
  # open a SQLite connection to your output file
  outdb <- dbConnect(SQLite(), out_db)
  # write the results to the new consolidated tag database
  # This will overwrite any existing SG_tag_database.sqlite file 
  # if one already exists in the target directory
  dbWriteTable(outdb, 'tags', out_df, overwrite = T)
  # close the connection to the new consolidated tag database
  dbDisconnect(outdb)
  
  message(length(db_list), " tag sqlite files merged into ", out_db)
  
  return(out_df)
}

# An example of how to use this function...
# Call the function and pass in the paths of the tag databases to be merged.
merged_db <- merge_dbs(c('D:/Downloads/project_322_2020-2_tag_database.sqlite',
                         'D:/Downloads/project_322_2021-2_tag_database.sqlite'))

View(merged_db)