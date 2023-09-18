# MalDocAnalysisContainer
With the ARM architecture, various analysis VMs based on the x86 architecture x64 architecture that I used for analysis of malicious documents would no longer work. Having been exposed to docker and the benefits of using containers versus full fledged VMs not to mention Docker containers are cross-platform, I thought it would be best to create a container with the most common tools that I use for maldoc analysis. The script will instantiate a docker image, install the necessary tools automatically and then run the container with the maldoc can be analyzed. When analysis is complete, exiting will automatically destroy and remove the container so that for your next analysis a new container can be instantiated. Initial creation of the docker image may take about 5 minutes since one of the packages will be built from source in the image. To date, the current tools included in the image are the ones below as well as standard linux tools:

Demo and walkthrough:


https://github.com/JemHadar/MalDocAnalysisContainer/assets/58823454/b1cefd0b-1d06-4d55-9d91-98204d3a870f



 Current tools installed:

 -Didier Stevens' PDFid, PDF-Parser, oledump.
 

 -OLEtools (olevba, rtfobj, pcodedmp, oleid, xlmdeobfuscator)
 

 -Detect it Easy (diec)

 Additional tools will be added to the script or you can modify the Dockerfile to add any additional tools as per needed.


 To instantiate the container, execute the shell script and provide a file for analysis as the argument:


 ./mal_doc_container.sh maldoc_file


**Prerequisites:**

Install Docker Engine

1. Update the apt package index:

	sudo apt-get update


2. Install Docker Engine, containerd, and Docker Compose.

 
To install the latest version, run:


 	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


3.Verify that the Docker Engine installation is successful by running the hello-world image.


 sudo docker run hello-world


This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

You have now successfully installed and started Docker Engine. 	
