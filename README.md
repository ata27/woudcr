# woudcr
Read ozone sondes from the web and interpolate onto defined pressure levels. 

This is a very simple R script for getting ozone sonde data and doing some processing of it. 

The ozone sonde is a nice instrument which enables the vertical profile of ozone to be measured in the atmosphere. 

It's usual that a number of other measurements are made alongside ozone and these can be very useful. For example the NOAA show some data here: 

![Example ozone sonde](https://www.esrl.noaa.gov/gmd/ozwv/ozsondes/images/Ozonesonde%20Profile.jpg)


# Usage
To use the script you will need to first go to the world ozone sonde database and download a csv file which contains the links to the ozone sondes to process. 

`This can be done by going to this link: https://woudc.org/data/explore.php
Then clicking "OzoneSonde" in the drop down menu. 
Then selecting a start and end date.
Then clicking search -- after a moment the Search Results are populated. 
Scroll to the bottom and then select Download and a new dialogue box opens. 
In this new dialogue box select "Download from database - csv" as the format.`

Use this new csv file as the input for the script. This is the file the R script then uses to search the data base for. NB you will need an internet connection!


# License
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to http://unlicense.org/
