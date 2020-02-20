# CRAFTY CoBRA Template

## Instructions for using the template

This template is meant to include the most appropriate file structure for a new CRAFTY-CoBRA model to start with.
However, depending on your model it might be a better idea to start from another configured project.

When you checked out the template from the repository, make sure to disconnect the project and optionally share 
it with another repository (otherwise you'd mess up the template when committing if you're allowed to):

* In eclipse, right-click the checked out project > Team > Disconnect
* Delete the .hg folder in the project folder
* In eclipse, right-click the checked out project > Team > Share Project ...

For information about setting up CRAFTY-CoBRA look [here](https://www.wiki.ed.ac.uk/display/CRAFTY/CoBRA%3A+Model+Setup+Documentation).

## Template Adaptation

In order to adjust this template to your context, search all files for "TEMPLATE" and replace that string
with a suitable substitute. Also look for "CUSTOMIZE" to e.g. adapt paths and further names.

Currently known files are:
.local.properties
./config/ant/FetchBackResults.xml
./config/ant/ReleaseToLinuxCluster.xml
./config/ant/ReleaseToLinuxCluster-FS.xml
./config/cluster/resources/Eddie_CraftySerialModel.sh
./config/cluster/resources/Eddie_CraftyParallelModel.sh
./config/launcher/Crafty Template CoBRA.launch (substitute all occurrences of CRAFTY_TemplateCoBRA by your project name)
files in ./config/R


## Default Configuration

The out-of-the-box configuration is:

startTick: 	2000
endTick:	2003
world:		CUSTOMIZE-WORLD
scenario:	CUSTOMIZE-SCENARIO
FRs:		FR1, FR2, FR3
BTs:		Cognitor, Innovator
Preferences:Competitiveness, SocialApproval, NeighbourApproval
Capitals:	Cap1, Cap2, Cap3
Services:	Service1, Service2, Service3


The default configuration should work as is and simulates a single region via Region.xml. 
In case you like to use several regions (4 per default) change World_XML.xml to World_CSV.xml 
in the file data/xml/Scenario.xml.

## Test Run

Right click the file './config/launcher/Crafty Template CoBRA.launch' and choose 'Run as...' > <First entry>
Note: you need to substitute the project name first (see above)!


## ReleaseToLinuxCluster

This ant script facilitates the transfer of model configuration data to e.g. a linux cluster. The '-FS' version
of the script assumes you have mapped the cluster file system to a network drive of your local file system
(see [here](https://www.wiki.ed.ac.uk/display/ecdfwiki/Transferring+Data) for Eddie) 

## Some Notes

* CRAFTY-CoBRA supports parallel processing of regions which requires MPI to be present and mpi.jar in the Java
classpath. If MPI is not present, mpi.jar _must_ be excluded from the Java classpath. CRAFTY-CoBRA will then issue
a warning (No MPI in classpath!) which can be ignored.

* CRAFTY-CoBRA currently issues a number of warnings from LEventbus. They basically mean that decision making
processes are triggered, but no actual decision for that trigger configured. In most cases the warnings can be 
ignored.

## Post-Processing
The folder ./config/R contains templates to aggregate and visualise simulation output data with R.
See [crafty wiki](https://www.wiki.ed.ac.uk/display/CRAFTY/Post-Processing) for details.

***

If you have any further questions don't hesitate to contact
Sascha.Holzhauer@ed.ac.uk 