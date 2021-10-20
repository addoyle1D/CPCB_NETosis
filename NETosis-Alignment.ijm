input = getDirectory("Please select the Input directory");
output1= getDirectory("Please select the Output directory");
output= output1+ "Aligned_files"+File.separator 
File.makeDirectory(output);
Dialog.create("File type and Scaling");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.addString("Indicate the distance calculation from the setup file:", "", 8)
Dialog.show();
suffix = Dialog.getString();
scaling = Dialog.getString();;


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
    
    open(input + file);SaveName=getTitle();
   
    run("Duplicate...", "title=[threshold test] duplicate channels=2");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_threshold test");setAutoThreshold("Otsu dark");run("Measure");selectWindow("Results");  //You can change Otsu to a different threshold if needed.
	Thr=Table.get("Min",0);close("Results");close("MAX_threshold test");close("threshold test");
    run("Correct 3D drift", "channel=2 only=Thr lowest=1 highest=1"); //You can add "multi_time_scale" or "sub_pixel" or "edge_enhance" or all (in order without "") between "channel=2" and "only=Thr" for slow drifts.
//Set the scaling for the image
selectWindow("registered time points"); 
run("Set Scale...", "distance=scaling known=1 pixel=1 unit=micron");
  
    print("Saving to: " + output); 
    saveAs("TIFF", output+"AL_"+file);close();
    close(SaveName);
}
