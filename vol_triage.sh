#!/bin/bash
 
# Name: vol_triage.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.2
#
# Description:
# vol_triage is a script to process a memory image in volatility and produce initial resuts for triage.
#
##
####Variables####
Name="Win7x64SP1_001<ItemName best to use machine, item or case name>"
MemoryImagePath="win7-64-memory-raw.001"
MemoryBaseline="win7-64-memory-baseline-raw-001"  # not yet used
ImageProfile="" # image information e,g Win7x64SP1. Optional
#################
###
##
#
CaseFolder="/cases/"$Name
MemoryImagePath="$CaseFolder/$MemoryImagePath" # Path to memory image
OutputPath="$CaseFolder/output" # output folder path
DumpPath="$CaseFolder/dump"
#TempPath="$CaseFolder/temp"

# check Output, Dump and Temp Path exist and create if they do not.
if [ ! -d $OutputPath ]; then
    mkdir $OutputPath
    mkdir $DumpPath
    #mkdir $TempPath
fi

# Find the profile for the image that is being analyzed and store it in ImagePr$
vol.py -f $MemoryImagePath imageinfo > $OutputPath/imageinfo
if [ -z $ImageProfile]; then
        cat $OutputPath/imageinfo | grep "Suggested Profile" 
        echo "Please enter preffered profile: "
        read ImageProfile
fi
VolPath="vol.py -f $MemoryImagePath --profile="$ImageProfile""	# Path to run volatility


# Setup Array of modules to run. Currently run all profiles.
# TODO: change array based on Profile
Modules=(pslist psscan pstree psxview dlllist handles consoles cmdscan cmdline getsids modules ldrmodules modscan netscan connections connscan sockets sockscan connections connscan sockets sockscan ssdt svcscan malsysproc malprocfind autoruns hashdump mimicatz shimcache userassist filescan iehistory hivelist)

for i in ${Modules[@]}
do
	echo -e Running: $i..."\n"
	$VolPath $i > $OutputPath/$i
done


# continue more verbose processing
echo "Running malfind and dumping to $DumpPath..."
VolPath malfind --dump-dir $DumpPath > $OutputPath/malfind # more advanced processing to come here
echo "Running: mftparser..."
$VolPath mftparser --output=body --output-file=$OutputPath/mftparser.csv
mactime -b $OutputPath/mftparser.csv -d -z UTC > $OutputPath/mftparserMactime.csv
echo "Running: ssdt filtered..."
$VolPath ssdt | egrep -v '(ntoskrnl|win32k)' > $OutputPath/ssdtGrep
echo "Processing standard modules finished: please review processed files in $outputPath while I run apihooks... "
echo "Running: apihooks..."
$VolPath apihooks > $outputPath/apihooks
echo "Processing Complete!"
