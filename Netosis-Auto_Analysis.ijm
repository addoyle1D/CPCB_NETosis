input = getDirectory("Input directory");
output = getDirectory("Output directory");
Dialog.create("Naming");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.addString("Enter the Date of the Experiment", "200704_");
Dialog.show();
suffix = Dialog.getString();
Date = Dialog.getString();; 
targetD= output+Date+"_Image-Files"+File.separator;
File.makeDirectory(targetD);
targetD2= output+Date+"_Data-Files"+File.separator;
File.makeDirectory(targetD2);

processFolder(input);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], suffix))
            processFile(input, output, list[i]);
    }
}
 
function processFile(input, output, file) {
      print("Processing: " + input + file);
      open(input + file);SaveName2=getTitle();SaveName=replace(SaveName2,".tif","");rename(SaveName);
selectWindow(SaveName);run("Split Channels");
selectWindow("C1-"+SaveName);rename("Ch1");
selectWindow("C2-"+SaveName);rename("Ch2");
Stack.getDimensions(width, height, channels, slices, frames);setSlice(frames);
run("Duplicate...", "duplicate channels=2");run("Duplicate...", "duplicate range=61");
selectWindow("Ch2");
imageCalculator("Subtract create stack", "Ch2-1","Ch2-2");
selectWindow("Result of Ch2-1");
imageCalculator("Subtract create stack", "Ch2","Result of Ch2-1");
run("Merge Channels...", "c1=[Result of Ch2-1] c2=[Result of Ch2] c3=[Ch1] create keep ignore");
selectWindow( "Merged");
Stack.setChannel(1); run("Enhance Contrast", "saturated=0.1");
Stack.setChannel(2); run("Enhance Contrast", "saturated=0.02");
Stack.setChannel(3); run("Enhance Contrast", "saturated=0.2");saveAs("Tiff", targetD+SaveName+"_Net-RGB");
close(SaveName +"_Net-RGB.tif");close("Ch2");

//Get Netosis data
run("Clear Results");
selectWindow("Result of Ch2-1");
run("Make Substack...", "  slices=1-12");selectWindow("Substack (1-12)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-12)");
selectWindow("Result of Ch2-1");
run("Make Substack...", "  slices=1-24");selectWindow("Substack (1-24)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-24)");
selectWindow("Result of Ch2-1");
run("Make Substack...", "  slices=1-36");selectWindow("Substack (1-36)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-36)");
selectWindow("Result of Ch2-1");
run("Make Substack...", "  slices=1-48");selectWindow("Substack (1-48)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-48)");
selectWindow("Result of Ch2-1");
run("Make Substack...", "  slices=1-61");selectWindow("Substack (1-61)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-61)");
run("Concatenate...", "  title=MAX_Hours open image1=[MAX_Substack (1-12)] image2=[MAX_Substack (1-24)] image3=[MAX_Substack (1-36)] image4=[MAX_Substack (1-48)] image5=[MAX_Substack (1-61)] image6=[-- None --]");
run("Z Project...", "projection=[Max Intensity]");
run("Concatenate...", "  title=Net-Hours-Total open image1=MAX_Hours image2=MAX_MAX_Hours image3=[-- None --]"); selectWindow("Net-Hours-Total");
close("MAX_Hours");
selectWindow("Net-Hours-Total");
run("Set Measurements...", "area mean min stack limit redirect=None decimal=3");

//Set your threshold by changing the  name in the code line below (for example, subsitute "Otsu" for "Default" in the code. 
//Alternatively, comment out(//) this code and set the thresold manually by changing the lower range on line 72.If doing the latter, be sure to remove the "//" and the beginning of the line.
setAutoThreshold("Otsu dark");
//setThreshold(2000,65535);

//if needed, change the size of the particle filter.  Review your setup log file for the NETosis cell size information. We suggest a value between 80% and 50% of the calculated value.
selectWindow("Net-Hours-Total");run("Analyze Particles...", "size=120-Infinity show=Overlay display exclude clear stack");
selectWindow("Results");Table.rename("Results", SaveName+"_Net");
Table.save(targetD2+SaveName+"_Net1.csv");
selectWindow("Net-Hours-Total");saveAs("Tiff", targetD+SaveName+"_Net-hrs");run("Duplicate...", "duplicate"); rename("NET");close(SaveName+"_Net-hrs.tif");
selectWindow("Result of Ch2-1");close();


//Get Apoptosis Data
run("Clear Results");Table.rename(SaveName+"_Net", "Results");
selectWindow("Result of Ch2");
run("Make Substack...", "  slices=1-12");selectWindow("Substack (1-12)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-12)");
selectWindow("Result of Ch2");
run("Make Substack...", "  slices=1-24");selectWindow("Substack (1-24)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-24)");
selectWindow("Result of Ch2");
run("Make Substack...", "  slices=1-36");selectWindow("Substack (1-36)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-36)");
selectWindow("Result of Ch2");
run("Make Substack...", "  slices=1-48");selectWindow("Substack (1-48)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-48)");
selectWindow("Result of Ch2");
run("Make Substack...", "  slices=1-61");selectWindow("Substack (1-61)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-61)");
run("Concatenate...", "  title=Apop_MAX_hrs open image1=[MAX_Substack (1-12)] image2=[MAX_Substack (1-24)] image3=[MAX_Substack (1-36)] image4=[MAX_Substack (1-48)] image5=[MAX_Substack (1-61)] image6=[-- None --]");
run("Z Project...", "projection=[Max Intensity]");
run("Concatenate...", "  title=Apop-hrs-Total open image1=Apop_MAX_hrs image2=MAX_Apop_MAX_hrs image3=[-- None --]"); 
close("Apop_Max_hrs");
selectWindow("Apop-hrs-Total");run("Set Measurements...", "area mean min stack limit redirect=None decimal=3");

//Set your threshold by changing the  name in the code line below (for example, subsitute "Otsu" for "RenyiEntropy" in the code. 
//Alternatively, comment out(//) this code and set the thresold manually by changing the lower range on line 108. If doing the latter, be sure to remove the "//" and the beginning of the line.
setAutoThreshold("RenyiEntropy dark");
//setThreshold(8000,65535);

//if needed, change the size of the particle filter.  Review your setup log file for the Apoptosis cell size information. We suggest a value between 80% and 50% of the calculated value.
selectWindow("Apop-hrs-Total");run("Analyze Particles...", "size=52-Infinity show=Overlay display exclude clear stack");
selectWindow("Results");Table.rename("Results", SaveName+"_Apop");
Table.save(targetD2+SaveName+"_Apop.csv");
//selectWindow("registered time points"); saveAs("Tiff", targetD3+"AL-"+BaseName);close("AL-"+BaseName);
selectWindow("Apop-hrs-Total");saveAs("Tiff", targetD+SaveName+"_Apop-hrs");run("Duplicate...", "duplicate"); rename("Apop");
close(SaveName+"_Apop-hrs-Total.tif");

//Make two-color NET and Apop Stack
run("Merge Channels...", "c1=NET c2=Apop create keep");selectWindow("Merged");
run("Channels Tool...");
Stack.setActiveChannels("10");run("Red");Stack.setActiveChannels("11");saveAs("Tiff", targetD+SaveName+"_NET-Apop-hrs");

//Get Live Nuc Data
run("Clear Results");Table.rename(SaveName+"_Apop", "Results");
selectWindow("Ch1");
run("Make Substack...", "  slices=1");selectWindow("Substack (1)");
selectWindow("Ch1");
run("Make Substack...", "  slices=1-61");selectWindow("Substack (1-61)");
run("Z Project...", "projection=[Max Intensity] all");close("Substack (1-61)");
selectWindow("Ch1");
run("Make Substack...", "  slices=61");selectWindow("Substack (61)");
run("Concatenate...", "  title=Nuc_MAX_hrs open image1=[Substack (1)] image2=[Substack (61)] image3=[MAX_Substack (1-61)] image4=[-- None --]");
run("Z Project...", "projection=[Max Intensity]");
run("Concatenate...", "  title=Nuc-hrs-Total open image1=Nuc_MAX_hrs image2=MAX_Nuc_MAX_hrs image3=[-- None --]"); 
close("Nuc_Max_hrs");
selectWindow("Nuc-hrs-Total");run("Unsharp Mask...", "radius=15 mask=0.60 stack");run("Set Measurements...", "area mean min centroid stack limit redirect=None decimal=3");

//Set your threshold by changing the  name in the code line below (for example, subsitute "Default" for "RenyiEntropy" in the code. 
//Alternatively, comment out(//) this code and set the thresold manually by changing the lower range on line 151. If doing the latter, be sure to remove the "//" and the beginning of the line.
setAutoThreshold("Otsu dark");
//setThreshold(,65535);

//if needed, change the size of the particle filter.  Review your setup log file for Nuclei size information. We suggest a value between 80% and 50% of the calculated value.
selectWindow("Nuc-hrs-Total");run("Analyze Particles...", "size=12-Infinity show=Overlay display clear stack");
selectWindow("Results");Table.rename("Results", SaveName+"_Nuc");
Table.save(targetD2+SaveName+"_Nuc.csv");
selectWindow("Nuc-hrs-Total");saveAs("Tiff", targetD+SaveName+"_Nuc-hrs");close(SaveName+"_Nuc-hrs-Total.tif");
close("*");     

}