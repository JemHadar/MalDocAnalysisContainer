# MalDocAnalysisContainer
 Shell script and Dockerfile that will instantiate a docker container for malicous document analysis. Once analysis completed, exiting will destroy the container. This allows one to analyze malicious documents in newly instantiated containers.

 Current tools installed:

 -Didier Stevens' PDFid, PDF-Parser, oledump.
 

 -OLEtools (olevba, rtfobj, pcodedmp, oleid, xlmdeobfuscator)
 

 -Detect it Easy (diec)

 Additional tools will be added to the script or you can modify the Dockerfile to add any additional tools as per needed.


 To instantiate the container, execute the shell script and provide a file for analysis as the argument:


 ./mal_doc_container.sh maldoc_file


Prerequisites:

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
