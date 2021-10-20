inputFolder = getDirectory("Choose the folder containing images to process:");

Dialog.create("How many positions?");
Dialog.addString("Positions", "1");
Dialog.show();
Pos= Dialog.getString();
// Create an output folder based on the inputFolder
parentFolder = getPath(inputFolder); inputFolderPrefix = getPathFilenamePrefix(inputFolder);
outputFolder="G:\\Data\\Machine learning data\\3D Data Stacks\\";
//if ( !(File.exists(outputFolder)) ) { File.makeDirectory(outputFolder); }

run("Close All");
setBatchMode(true);

flist = getFileList(inputFolder);

for (i=0; i<flist.length; i++) {
	filename = inputFolder + flist[i];
	filenamePrefix = getFilenamePrefix(flist[i]);

	if ( endsWith(filename, ".nd") || endsWith(filename, ".nd2") || endsWith(filename, ".czi") ) {
		run("Bio-Formats Macro Extensions");
		Ext.setId(filename); Ext.getSeriesCount(seriesCount);
		print(seriesCount);
	
		//for(seriesNum = 0; seriesNum < seriesCount; seriesNum++) {
		for(seriesNum = 0; seriesNum < Pos; seriesNum++) {
			Ext.setSeries(seriesNum);
			Ext.openImagePlus(filename);
			//targetD= outputFolder+ filenamePrefix + "-pos-" + seriesNum + File.separator;
			//File.makeDirectory(targetD);
			saveAs("TIFF",outputFolder + filenamePrefix + "-pos-" + seriesNum);
			//open(filename); id0 = getImageID();
		}
		
		//run("Close All");
	}
}


function getPathFilenamePrefix(pathFileOrFolder) {
	// this one takes full path of the file
	temp = split(pathFileOrFolder, File.separator);
	temp = temp[temp.length-1];
	temp = split(temp, ".");
	return temp[0];
}

function getFilenamePrefix(filename) {
	// this one takes just the file name without folder path
	temp = split(filename, ".");
	return temp[0];
}

function getPath(pathFileOrFolder) {
	// this one takes full path of the file (input can also be a folder) and returns the parent folder path
	temp = split(pathFileOrFolder, File.separator);
	if ( File.separator == "/" ) {
	// Mac and unix system
		pathTemp = File.separator;
		for (i=0; i<temp.length-1; i++) {pathTemp = pathTemp + temp[i] + File.separator;}
	}
	if ( File.separator == "\\" ) {
	// Windows system
		pathTemp = temp[0] + File.separator;
		for (i=1; i<temp.length-1; i++) {pathTemp = pathTemp + temp[i] + File.separator;}
	}
	return pathTemp;
}