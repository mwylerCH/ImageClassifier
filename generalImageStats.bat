// to run
// ../ImageJ/ImageJ -batch seed.bat seedFlash.jpeg | awk '{if($3 != 255) print $0}' 

//run("Record...");

// Read in Image

name = getArgument;
open(name);
rename("Original");

// Preparation
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack invert redirect=None decimal=3");

// Entire image 
run("8-bit");
run("Measure");
saveAs("Results",  name+"_general.csv");


// make distribution plot
getHistogram(values, counts, 256);

// Make table to export
Table.create("table1");
// set a whole column
Table.setColumn("GreyVal", values);
Table.setColumn("Counts", counts);

saveAs("Results",  name+"_greyHisto.csv");

run("Quit");

