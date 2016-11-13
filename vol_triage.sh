#!/bin/bash
 
# Name: vol_triage.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.1
#
# Description:
# vol_triage is a script to process a memory image in volatility and produce initial resuts for triage.
# The idea is then to grep output and process additional steps as requried.
# Designed to run on sift workstation with environment variables pointing to binaries.

# Variables
imagePath="/cases/<CaseFolder>/<ImageFile>" # Path to memory image
outputPath="/cases/<CaseFolder>/vol_output" # output folder path
profile="<Profile>" # image information
volPath="vol.py -f $imagePath --profile="$profile""	# Path to run volatility

# Array of modules to run
modules=(imageinfo pslist psscan pstree psxview dlllist handles consoles cmdscan cmdline getsids modules malfind ldrmodules modscan netscan connections connscan sockets sockscan connections connscan sockets sockscan ssdt svcscan malsysproc malprocfind autoruns hashdump mimicatz shimcache userassist)

mkdir $outputPath

for i in ${modules[@]}
do
	echo -e Running: $i..."\n"
	$volPath $i > $outputPath/$i.txt
done

echo -e  Running: pstree Verbose..."\n"
$volPath pstree -v > $outputPath/pstreeV.txt 
echo -e Running: ssdt filtered..."\n"
$volPath ssdt | egrep -v '(ntoskrnl|win32k)' > $outputPath/ssdtGrep.txt
echo -e Processing standard modules finished: please review processed files in $outputPath while I run apihooks... "\n"
echo -e Running: apihooks..."\n"
$volPath apihooks > $outputPath/apihooks.txt 
echo -e Processing Complete!
