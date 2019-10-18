# R script to read in ozone sonde data
library(stringr)

# read in all file list (links to web data so need an internet connection)
all_file_list <- readLines("~/Downloads/woudc-DataURLFileList.csv")

# remove the first row in the file -- check the file to see if you need to do this?
all_file_list <- all_file_list[-1]

# initalise some empty lists for all data
all_data_list <- list()
all_loc_list <- list()
all_input_list <- list()

# define the pressure levels to interpolate the O3PartialPressure onto
# this generates 25 intervals from 50 hPa to 900 hPa
p_to_interp <- rev(seq(50, 900, by=25) )


# function to read in data - safely
readUrl <- function(url) {
  out <- tryCatch(
    {
      # Just to highlight: if you want to use more than one 
      # R expression in the "try" part then you'll have to 
      # use curly brackets.
      # 'tryCatch()' will return the last evaluated expression 
      # in case the "try" part was completed successfully
      
      message("This is the 'try' part")
      
      readLines(con=url, warn=FALSE) 
      # The return value of `readLines()` is the actual value 
      # that will be returned in case there is no condition 
      # (e.g. warning or error). 
      # You don't need to state the return value via `return()` as code 
      # in the "try" part is not wrapped insided a function (unlike that
      # for the condition handlers for warnings and error below)
    },
    error=function(cond) {
      message(paste("URL does not seem to exist:", url))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("URL caused a warning:", url))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={
      # NOTE:
      # Here goes everything that should be executed at the end,
      # regardless of success or error.
      # If you want more than one expression to be executed, then you 
      # need to wrap them in curly brackets ({...}); otherwise you could
      # just have written 'finally=<expression>' 
      message(paste("Processed URL:", url))
      message("Some other message at the end")
    }
  )    
  return(out)
}

# now we want to loop over the all_file_list and open up a file on the internet and 
# (1) read and (2) convert the file including doing the interpolation of the sone data onto 
# the p_to_interp levels
# for(i in 1:length(all_file_list) ) {
for(i in 1:10) {
  print(i)
  print(paste("Reading in", all_file_list[i], "from the internet. This may take a while...") )

  # read in the full file and all the crap
  file.all <- readUrl(all_file_list[i])
print("Converting file...")

# grep for special characters in the full file and work out comment lines
com.lines <- grep("^[*]+", file.all)

# remove the comment lines if they exist
if(length(com.lines>=1) ) file.all <- file.all[-com.lines]

# find out where the actual profile data starts
start.profile <- grep("#PROFILE", file.all, ignore.case=TRUE)[1]

# find out where the sonde profile was made (its location)
start.loc <- grep("#LOCATION", file.all, ignore.case=TRUE)[1]
if(is.finite(start.loc) ) { # add an if here to catch the location data -- need for the analysis
  # read the location info
  loc.dat <- file.all[(start.loc+1):(start.loc+2)]
  
  # work out the names of the columns of data in the location header NB different for different sondes
  loc_names <- unlist(strsplit(loc.dat[1], ","))
  
  # read in the profile data
  in.dat <- file.all[start.profile+1:(length(file.all))]
  
  # work out the names of the columns of data in the profile NB different for different sondes
  data_names <- unlist(strsplit(in.dat[1], ","))
  
  # split the data into columns
  loc_data <- str_split_fixed(loc.dat, ",", length(data_names))
  
  # find the longitude and latitude
  lat.idx <- which(loc_data[1,] %in% c("Latitude", "Lat", "latitude", "lat") )
  lon.idx <- which(loc_data[1,] %in% c("Longitude", "Lon", "longitude", "lon") )
  lat <- as.numeric(loc_data[2, lat.idx] )
  lon <- as.numeric(loc_data[2, lon.idx] )
  
  # add the location data to the loc list
  all_loc_list[[i]] <- c(lon, lat)
  
  # split the data into columns
  my_data <- str_split_fixed(in.dat, ",", length(data_names))
  
  # remove the header
  my_data <- data.frame(my_data[-1,])
  
  # add the names to the new data frame
  names(my_data) <- data_names
  
  # subset the data -- here we are looking to remove junk from the files and just have the ozone profile
  # NB typos in files so have to account for that in search (i.e. the pressure was called pressue)
  sub_data <- my_data[, c(which(data_names %in% c("Pressure", "Pressue")), 
                          which(data_names %in% c("O3PartialPressure", "o3partialpressure", "O3PartialPressue")))]
  
  # convert factors to numeric 
  sub_data$Pressure <- as.numeric(levels(sub_data[,1]))[sub_data[,1]]
  sub_data$O3PartialPressure <- as.numeric(levels(sub_data[,2]))[sub_data[,2]]
  
  # remove NA and blank data
  sub_data <- sub_data[!apply(is.na(sub_data) | sub_data == "", 1, all),]
  
  # interpolate the O3 profile onto uniform pressure levels
  O3PartialPressure_interp <- approx(x = sub_data$Pressure, 
                                     y=sub_data$O3PartialPressure, method = "linear", xout=p_to_interp)
  
  # add the converted data to the master list
  all_data_list[[i]] <- O3PartialPressure_interp$y
  
  # add the name of the input file to the list of input
  all_input_list[[i]] <- all_file_list[i]

    } # end if loop
 } # end loop over i



# Now we have looped over all the files in the input .csv and internally generated some lists 
# which contain the interpolated data and the location of the sonde ptofiles. We want to now 
# combine data lists and write output.

# First generate data frames of the location info and the sonde info, 
# then combine together
loc_output <- do.call(rbind, all_loc_list)

## AA extract failed.. so fudging this by only looking at rows 1:605 -- Fouzia you may not need the next line
# loc_output <- loc_output[1:10, ]

sonde_output <- do.call(rbind, all_data_list)
data_output <- data.frame(cbind(loc_output, sonde_output))
names(data_output) <- c("x", "y", p_to_interp)

# catch for spuriously high data
data_output[data_output>300] <- NA

# drop data with NA for Dan's code to work
input_list <- unlist(all_input_list)
input_list <- input_list[complete.cases(data_output)]
data_output <- data_output[complete.cases(data_output), ]

# finally write the data out for Dan's code. 
write.table(data_output, file="~/Documents/ACSIS/Data/DanJones/test_data_file2.csv", 
            sep = ",", row.names = FALSE, col.names = TRUE)

# this file contains the input information on the files that have been written out in case of the need
# for any cross checking. 
write.table(input_list, file="~/Documents/ACSIS/Data/DanJones/test_data_file_inputs2.csv", 
            sep = ",", row.names = FALSE, col.names = TRUE)

