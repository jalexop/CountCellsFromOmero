<h1>Count Cells from Omero Images</h1>
<br>
<h2>General</h2>
 <p>The macro can be used to connect to an Omero account, and analyse all images within a Dataset. The macro is doing the following:</p>
<li>Connects to Omero.</li>
<li>Using Omero Extensions it lists all the dataset names of the selected user.</li>
<li>The user selects the channel number that will be analysed and the thresholding algorithm (defauls selection is Otsu).</li>
<li>For each dataset that is selected, the macro deletes the previously analysed / saved images.</li>
<li>If the image is a z-stack then on a maximum intensity projection of the image segments (upon background substraction) the selected channel using the selected thresholding algorithm.</li>
<li>From the generated mask it analyses the particles and creates a set or ROIs and a table with analysis results for each detected particle (Area, Mean Intensity, Perimeter, Circularity and Roundness).</li>
<li>Finaly, all results, rois and macimum intensity projections for the analysed channel are uploaded to Omero, under the same dataset.</li>
<br>
<h2>Installation</h2>
<h3><u>Step 1</u></h3>
<p>Download Fiji from <a href="https://fiji.sc">https://fiji.sc</a>. Install Fiji based on the instructions provide (extract the .zip file at a local folder with suffecient permissions).</p>
<p>Update Fiji to it's latest version upon first run.</p>
<h3><u>Step 2</u></h3>
<p>Install required depedencies:</p>
<li>Install the <a href="https://omero-guides.readthedocs.io/en/latest/fiji/docs/installation.html">OMERO.insight plugin</a> (if you haven't already). For version 5.8.6 you can use this <a href="https://github.com/ome/omero-insight/releases/download/v5.8.6/omero_ij-5.8.6-all.jar">link</a>.</li>
<li>Download the JAR file for this <a href="https://github.com/GReD-Clermont/simple-omero-client/releases/tag/5.19.0/">library</a>.</li>
<li>Download the JAR file (<a href="https://github.com/GReD-Clermont/omero_macro-extensions/releases/tag/1.4.0/">for this plugin</a>).</li>
<li>Place these JAR files in your plugins folder (example [Path of Fiji Installation}/plugins/).</li>
<h3><u>Step 3</u></h3>
<p>Install the CountCellsFromOmero.ijm</p>
<li>Download the .ijm file.</li>
<li>Move the downloaded file to the Fiji plugins folder.</li>
<br>
<p>* You can skip Steps 2 and 3 by downloading all files together using the latest release of this package (<a href="https://github.com/jalexop/CountCellsFromOmero/releases">link</a>).</p>
<br>
<h2>Usage</h2>
<li>Select the CountCellsFromOmero macro from your Fiji Plugins menu</li>
<li>Use your Omero server address and the correct port. Use your username and password. If you want to analyse images from another user you need to indicate the username (user2). Otherwise, use your own username at the field below password (see image below) </li>
<img width="455" height="378" alt="image" src="https://github.com/user-attachments/assets/5352f523-152d-4521-a9fa-ddb8e2033660" />
<li>Select the datasets that contain the images to be analysed, and indicate the channel number (for multi-channel images) that will be used for the analysis. Finally select the thresholding algorithm (e.g. Otsu in image below)</li>
<img width="455" height="378" alt="image" src="https://github.com/user-attachments/assets/4c87ce3b-b229-41b5-82a1-86f5af4920a6" />
<br>
<h2>Results</h2>
<p>The macro generates new images (maximum intensity prohections in case of z-stack acquisitions) from the channel that is selected for analysis. These images are uploaded to Omero, under the same dataset as the source images. The newly generated images also have the ROIs of all detected cells.</p>
<p>Additionally, the result table from all the analysed images of each dataset is uploaded as attachment (.csv file) of the analysed dataset and as an Omero table on the dataset level. This analysis table contains the following columns: Image ID, Image name, ROI name, Area, Mean Fluorescence Intensity, Perimeter, Circularity and Roundness, for each detected ROI of all images of the dataset (see example screenshot below)</p>
<img width="2372" height="409" alt="Screenshot 2025-11-21 at 10 50 54" src="https://github.com/user-attachments/assets/a091425c-d83c-4519-82e2-64d4094cb123" />
