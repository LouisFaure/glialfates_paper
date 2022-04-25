// ImageJ script to extract background intensity level. Will loop over a folder.
// This is applied to uncropped images, a zone has to be selected by the user.
// Output: a csv file containing the mean intensity value of zone.

dir=getDirectory("Choose a Directory");
print(dir);
list = getFileList(dir);

for (i = 0; i < list.length; i++) {
	subStringArray = split( list[i], "(RGB)");
	if (subStringArray[1].length==5){ // open only uncropped image
		open(dir+list[i]);
		imgName=getTitle();
		baseNameEnd=indexOf(imgName, ".tif");
		baseName=substring(imgName, 0, baseNameEnd);
		run("Split Channels");
		waitForUser("Select background zone. Press Okay to continue....");
		run("Measure");
		saveAs("Results", dir+baseName+".csv");
		run("Clear Results");
		close();
		close();
		close();
	}
}
