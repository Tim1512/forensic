#!/bin/bash
 
# Name: vol_triage.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.2
#
# Description:
# vol_triage is a script to process a memory image in volatility and produce initial resuts for triage.
#
##
###Paramaters###
MemoryImagePath="/cases/Win7-64-001/Win7-64-memory-raw.001"
MemoryBaseline="/baseline/win7-64-memory-baseline-raw-001"  # not yet used
ImageProfile="" # image information e,g Win7SP1x86 Optional
CaseFolder="/cases/Win7-64-001"
OutputPath="$CaseFolder/output" # output folder path
DumpPath="$CaseFolder/dump"
#TempPath="$CaseFolder/temp" 
#################
###
##
#

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
Modules=(pslist psscan pstree psxview dlllist handles consoles cmdscan cmdline getsids modules ldrmodules modscan netscan connections connscan sockets sockscan connections connscan sockets sockscan ssdt svcscan malsysproc malprocfind autoruns hashdump mimicatz shimcache userassist filescan iehistory hivelist apihooks)

for i in ${Modules[@]}
do
	echo -e Running: $i..."\n"
	$VolPath $i > $OutputPath/$i
done

# continue more verbose processing
echo "Running: ssdt filtered..."
cat $OutputPath/ssdt | egrep -v '(ntoskrnl|win32k)' > $OutputPath/ssdtGrep
echo "Running malfind and dumping to $DumpPath..."
$VolPath malfind --dump-dir $DumpPath > $OutputPath/malfind # more advanced processing to come here
echo "Running: mftparser and mactime..."
$VolPath mftparser --output=body --output-file=$OutputPath/mftparser.body
mactime -b $OutputPath/mftparser.body -d -z UTC > $OutputPath/mftparserMactime.csv
echo "Processing Complete!"
