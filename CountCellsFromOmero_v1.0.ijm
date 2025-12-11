// @String (visibility=MESSAGE, value="<html><h1>Analyse Omero Images</h1></html>", required=false) head
// @String (visibility=MESSAGE, value="<html><h2>Omero Login Info</h2></html>", required=false) msg
// @String(label="Host", value='wss://omero.innere.fb11.uni-giessen.de/omero-ws') omrsrv
// @Integer(label="Port", value=443) omrport
// @String(label="Omero Username", style="Text Field") omrusr
// @String(label="Password", style='password', persist=false) omrpwd
// @String(label="Analyse Data of the following username", style="Text Field") omrusrsudo
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//				Macro written by Dr. Ioannis Alexopoulos
// The author of the macro reserve the copyrights of the original macro.
// However, you are welcome to distribute, modify and use the program under 
// the terms of the GNU General Public License, as long as you attribute proper 
// acknowledgement to the author as mentioned above.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

requires("1.54p");
ThresholdMethods=getList("threshold.methods");
run("OMERO Extensions");

succesfulConnectionOmero=Ext.connectToOMERO(omrsrv, omrport, omrusr, omrpwd);
if (succesfulConnectionOmero){
	print("\\Clear");
	print ("################### Connection to Omero and Project / Dataset Management ################");
	print ("Succesfully Connected to Omero Server "+omrsrv+" on port "+omrport+" for user "+omrusr+"");
	print ("###################\n\n\n");
}else{
	exit("Cannot connect to Omero Server "+omrsrv+" on port "+omrport+" for user "+omrusr+"");
}
omrusrsudo=replace(omrusrsudo, " ", "");
if(omrusrsudo!=""){
	Ext.sudo(omrusrsudo);
}else{
	omrusrsudo=omrusr;
}
ListForUser=Ext.listForUser(omrusrsudo);
userDatasetsIDs=split(Ext.list("Dataset"), ",");
userDatasetsNames=newArray(userDatasetsIDs.length);
default_check_box_values=newArray(userDatasetsIDs.length);
DATASETS_2_OPEN=newArray(userDatasetsIDs.length);
for(d=0;d<userDatasetsIDs.length;d++){
	userDatasetsNames[d]=Ext.getName("Dataset", userDatasetsIDs[d]);
}

rows=20;
columns=(userDatasetsIDs.length/20)+1;
Dialog.create("Analysis Parameters");
if(userDatasetsIDs.length == 1){default_check_box=true;}else{default_check_box=false;}
for(d=0;d<userDatasetsIDs.length;d++){
	userDatasetsNames[d]=Ext.getName("Dataset", userDatasetsIDs[d]);
	default_check_box_values[d]=default_check_box;
}
Dialog.addMessage("Select the Dataset that will be analysed            ");
Dialog.addCheckboxGroup(rows,columns,userDatasetsNames,default_check_box_values);
Dialog.addNumber("Channel number to analyse (start counting from 1)", 2);
Dialog.addChoice("Threshold Algorithm", ThresholdMethods, "Otsu");
Dialog.show();

for (i=0; i<userDatasetsIDs.length; i++){
	DATASETS_2_OPEN[i]=Dialog.getCheckbox();
}
Channel2Analyse=Dialog.getNumber();
Thres_Method=Dialog.getChoice();
// Check if user selected a dataset
ok_to_proc=0;
for(i=0; i<userDatasetsIDs.length; i++){
	if(DATASETS_2_OPEN[i]==1){
		ok_to_proc=1;
	}
}
if(ok_to_proc<1){
	exit("Please Select a dataset to analyse")
}
setBatchMode(true);
//For every Dataset that is ok to open (analyse): Do stuff
for (i=0; i<userDatasetsIDs.length; i++){
	if(DATASETS_2_OPEN[i]){
		print("Processing Dataset "+userDatasetsNames[i]+" with ID: "+userDatasetsIDs[i]);
		processingDataset=""+userDatasetsNames[i];
		images=Ext.list("images", "dataset", userDatasetsIDs[i]);
		// This will delete all images in the dataset with MAX_Ch[Channel2Analyse] name
		RawImages=split(images, ",");
		print("Checking for previously analysed images");
		for(q=0;q<RawImages.length;q++){
			RawimgName=Ext.getName("Image", RawImages[q]);
			DeleteName="MAX_"+"Ch"+Channel2Analyse+"_Counting_";
			if(startsWith(RawimgName, DeleteName)){
				id2Delete=RawImages[q];
				delImage(id2Delete);
			}
		}
		images=Ext.list("images", "dataset", userDatasetsIDs[i]);
		// This will exlude all images in the dataset with MAX_[ImageName] name
		images2="";
		RawImages2=split(images, ",");
		print("Checking for maximum intensity projections images");
		for(q=0;q<RawImages2.length;q++){
			RawimgName2=Ext.getName("Image", RawImages2[q]);
			ExludeName="MAX_";
			if(startsWith(RawimgName2, ExludeName)){
				print("\t -Image "+RawimgName2+" with ID: "+ RawImages2[q]+" seems to be a maximum intensity projection and will not be analysed");
			}else{
				images2=images2+RawImages2[q]+",";
			}
		}
		images2=substring(images2, 0, lastIndexOf(images2, ","));
		//
		print("\n\n");
		Images2Open=split(images2, ",");
	
		for(q=0;q<Images2Open.length;q++){
			ttt=Ext.getImage(Images2Open[q]);
			print("\t Opening image "+Ext.getName("Image", Images2Open[q])+" with ID: "+Images2Open[q]);
			run("Duplicate...", "title=tmp duplicate");
			analyseData(Channel2Analyse, Thres_Method);
			selectWindow("MaximumInt");
			newName="MAX_"+"Ch"+Channel2Analyse+"_Counting_"+Ext.getName("Image", Images2Open[q]);
			rename(newName);
			Area=newArray(nResults);
			Perimeter=newArray(nResults);
			Mean=newArray(nResults);
			Circularity=newArray(nResults);
			Roundness=newArray(nResults);
			results=nResults;
			for (r = 0; r < nResults(); r++) {
				Area[r]=getResult("Area", r);
				Perimeter[r]=getResult("Perim.", r);
				Mean[r]=getResult("Mean", r);
				Circularity[r]=getResult("Circ.", r);
				Roundness[r]=getResult("Round", r);
				roiManager("select", r);
			//	roiManager("rename", call("ij.plugin.frame.RoiManager.getName", r)+"_"+Images2Open[q]);
			}
	//		
			selectWindow(newName);
			run("Clear Results");
			for (r = 0; r < results; r++) {
				setResult("Image Name", r, Ext.getName("Image", Images2Open[q]));
   			//	setResult("Dataset Name", r, processingDataset);
   				setResult("ROI Name", r, call("ij.plugin.frame.RoiManager.getName", r));
   				setResult("Area", r, Area[r]);
   				setResult("Mean Intensity", r, Mean[r]);
   				setResult("Perimeter", r, Perimeter[r]);
   				setResult("Circularity", r, Circularity[r]);
 				setResult("Roundness", r, Roundness[r]);
			}
			updateResults();
			TableName="AnalysisResults_Ch"+Channel2Analyse;
			NewImportedImageId=Ext.importImage(userDatasetsIDs[i]);
			noROIS=Ext.saveROIs(NewImportedImageId, "ROI_ID");
			//noROIS=Ext.saveROIs(Images2Open[q], "ROI_ID");
			print("\t\t "+noROIS + " Rois were saved on Omero for image "+Ext.getName("Image", NewImportedImageId)+" with ID "+NewImportedImageId);
			Ext.addToTable(TableName, "Results", NewImportedImageId, ""); // The results contents of each raw file are added to the Omero Table
			print ("\t\t Added results to Table\n");
			run("Clear Results");
			run("Close All");
		}
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		month=month+1;
		date=""+year+'-'+month+'-'+dayOfMonth+'_'+hour+'-'+minute+'-'+second;
		print("Save Table to Dataset: "+userDatasetsIDs[i]);
		Ext.saveTable(TableName, 'dataset', userDatasetsIDs[i]);
		txt_file = getDir("temp") +date+"_"+userDatasetsIDs[i]+"_Ch"+Channel2Analyse+"_analysis_results.csv";
		print("Save as csv file");
		Ext.saveTableAsFile(TableName, txt_file, ",");
		file_id = Ext.addFile("Dataset", userDatasetsIDs[i], txt_file);
		print("**************************************\n\n");
		deleted = File.delete(txt_file);
	}else{
	//	print("Dataset "+userDatasetsNames[i]+" with ID: "+userDatasetsIDs[i]+" is not selected for Processing");
	//	print("**************************************\n\n");
	}
	run("Close All");
}

Ext.endSudo();
Ext.disconnect();
setBatchMode(false);
print("Finished...!");

function analyseData(Channel2Analyse, Thres_Method){
	selectWindow("tmp");
	getDimensions(width, height, channels, slices, frames);
	if(slices>1){
		run("Z Project...", "projection=[Max Intensity]");
	}
	if(channels>1){
		run("Split Channels");
		for(c=1;c<=channels;c++){
			if(c<Channel2Analyse || c>Channel2Analyse){
				close("C"+c+"-MAX_tmp");
			}
		}
		selectImage("C"+Channel2Analyse+"-MAX_tmp");
	}
	run("Median...", "radius=2");
	run("Subtract Background...", "rolling=15 disable");
	run("Duplicate...", "title=MaximumInt duplicate");
	selectImage("C"+Channel2Analyse+"-MAX_tmp");
	setAutoThreshold(""+Thres_Method+" dark");;
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
	run("Set Measurements...", "area mean perimeter shape display redirect=[MaximumInt] decimal=3");
	run("Analyze Particles...", "size=20.00-Infinity circularity=0.15-1.00 display clear include add");
	selectWindow("MaximumInt");
	for (index=0; index<roiManager("count");index++){
		roiManager("select", index);
		name=call("ij.plugin.frame.RoiManager.getName", index);
		new_name="Ch"+Channel2Analyse+"_"+name;
		roiManager("rename", new_name);
	}
	close("*tmp*");
}
function delImage(id2Delete){
	print("\t -Image "+Ext.getName("Image", id2Delete)+" with ID: "+id2Delete+" already exists and will be replaced with new analysed data");
	Ext.delete("image", id2Delete);
}
