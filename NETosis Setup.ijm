//Select the Output directory for saving
output = getDirectory("Output directory");
targetD3= output+"Setup_Files"+File.separator;
if ( !(File.exists(targetD3)) ) { File.makeDirectory(targetD3); }

//Select the data file to analyze for setup parameters 
TLpath=File.openDialog("Open the NETosis file of interest:");open(TLpath);
SaveName=getTitle();

// this calculates the distance for scaling used in the alignment macro line __
Dialog.create("Calculating image scaling:");
Dialog.addNumber("What is the objective magnification?", 20);
Dialog.addNumber("What is the camera pixel size in microns?", 6.5);
Dialog.show();
 Obj= Dialog.getNumber();
 Pix= Dialog.getNumber();;
 Scale1=Pix/=Obj; Scale2=(1/Scale1);
print("");
print("NETosis Setup Information---------");
print("");
print("Scaling Information");
print(Scale1);
print("distance="+Scale2);

Stack.getDimensions(width, height, channels, slices, frames);
setSlice(frames);

//Image stack colors are split, then test images are created
selectWindow(SaveName); run("Split Channels");
selectWindow("C1-"+SaveName);run("Duplicate...", "title=Nuclei");run("Enhance Contrast", "saturated=0.35");
selectWindow("C2-"+SaveName);setSlice(frames); run("Duplicate...", "title=Apoptosis");run("Enhance Contrast", "saturated=0.35");
selectWindow("C2-"+SaveName);run("Duplicate...", "title=NETosis-1 duplicate range=1-12");run("Z Project...", "projection=[Max Intensity]");run("Enhance Contrast", "saturated=0.35");
imageCalculator("Subtract create", "MAX_NETosis-1","Apoptosis"); selectWindow("Result of MAX_NETosis-1");run("Enhance Contrast", "saturated=0.35");rename("NETosis");

//testing nuclei threshold and size
print("----------------------------");
print("Nuclei Information");
selectWindow("Nuclei");
run("Threshold...");
waitForUser("Test which threshold works to cover the nuclei, then select OK in this window");
Dialog.create("Nuclei Thresholding");
Dialog.addString("What is Threshold name?", "Otsu");
Dialog.show();
 Thrname= Dialog.getString();
print("Nuclei threshold type="+Thrname);
run("Set Measurements...", "area mean standard min fit shape feret's median area_fraction limit redirect=None decimal=3");
run("Analyze Particles...", "size=1-Infinity show=Masks exclude summarize");
selectWindow("Summary");
AveNuc=Table.get("Average Size",0);
lowsize=AveNuc*0.8;
print("Average nuclei size="+AveNuc);
print("80% of average nuclei size="+lowsize);SaveName2=replace(SaveName, ".tif","");
selectWindow("Mask of Nuclei"); saveAs("Tiff", targetD3+ "Nuc_"+SaveName2); close();

//testing apoptosis threshold and size
print("----------------------------");
print("Apoptosis Information");
selectWindow("Apoptosis");
run("Threshold...");
waitForUser("Test which threshold works to cover the apoptotic cells, then select OK in this window");
Dialog.create("Apoptosis Thresholding");
Dialog.addString("What is Threshold name?", "IJ_IsoData");
Dialog.show();
 Thrname2= Dialog.getString();
print("Apoptosis threshold type="+Thrname2);
run("Set Measurements...", "area mean standard min fit shape feret's median area_fraction limit redirect=None decimal=3");
run("Analyze Particles...", "size=52-Infinity show=Masks exclude summarize");
selectWindow("Summary");
AveApop=Table.get("Average Size",1);
lowsizeA=AveApop*0.8;
print("Average apoptotic cell size="+AveApop);
print("80% of average apoptotic cell size="+lowsizeA);
selectWindow("Mask of Apoptosis"); saveAs("Tiff", targetD3+ "Apop_"+SaveName2); close();

//testing NETosis threshold and size
print("----------------------------");
print("NETosis Information");
selectWindow("NETosis");
run("Threshold...");
waitForUser("Test which threshold works to cover the NETosis cells, then select OK in this window");
Dialog.create("NETosis Thresholding");
Dialog.addString("What is Threshold name?", "RenyiEntropy");
Dialog.show();
 Thrname3= Dialog.getString();
print("Apoptosis threshold type="+Thrname3);
run("Set Measurements...", "area mean standard min fit shape feret's median area_fraction limit redirect=None decimal=3");
run("Analyze Particles...", "size=52-Infinity show=Masks exclude summarize");
selectWindow("Summary");
AveNET=Table.get("Average Size",2);
lowsizeN=AveNET*0.8;
print("Average NETosis cell size="+AveNET);
print("80% of average NETosis cell size="+lowsizeN);
selectWindow("Mask of NETosis"); saveAs("Tiff", targetD3 + "NET_"+SaveName2); close();
selectWindow("Summary");saveAs("Results",targetD3+SaveName2+"_Sum.csv");Table.deleteRows(0, 2, SaveName2+"_Sum.csv");
selectWindow("Log");saveAs("Text", targetD3+SaveName2+"_log.txt");
run("Close All");


