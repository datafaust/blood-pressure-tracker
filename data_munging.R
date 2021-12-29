bp_df <- readxl::read_xlsx(paste0(getwd(),"/data/bloodPressureLog.xlsx"), sheet = 1)
print(head(bp_df))


bp_df$date <- as.Date(bp_df$date)
bp_df$time <- substr(bp_df$time,12,16)
bp_df$date_time <- paste(bp_df$date, bp_df$time)
bp_df$date_time <- as.POSIXct(bp_df$date_time, tz = "GMT")

head(bp_df)
