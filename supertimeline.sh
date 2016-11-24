#!/bin/bash 

# Name: timeline.sh
# Author: Matthew Green - mgreen27(at)gmail.com
# Version 0.1
#
# Description:
# timeline.sh is a quick script to Generate Supertimeline.csv
#	- you will need to specifiy vss to process during execution
#	- you will need to merge supertimeline to colour template
#
# Instructions:
# - create case name folder in /cases/
# - add disk evidence, memory evidence and baseline memory
# - set paramaters in script
# - ensure /cases/whitelist.txt exists
# - run as sudo
#
#
##
###Paramaters###
CaseName="<ItemName best to use machine, item or case name>"
DiskEvidence="<disk evidence file (E01|AFF|etc)>"
#memory_evidence="win7-64-memory-raw.001" # not yet used
CaseFolder="/cases/"$CaseName
l2tl_start_date="2016-04-02 20:00:00"
l2tl_end_date="2016-10-20 00:00:00"
l2tl_parser_config="winevtx,filestat,winreg,webhist,lnk,prefetch" # modify as required
################
###
##
#

DiskEvidence=$CaseFolder"/"$DiskEvidence

echo $DiskEvidence
echo Configured parsers are: $l2tl_parser_config
echo Processing Supertimeline... from $l2tl_start_date to $l2tl_end_date
cd $CaseFolder
log2timeline.py --parsers "$l2tl_parser_config" plaso.dump $DiskEvidence
psort.py -z "UTC" -o L2tcsv plaso.dump "date > '$l2tl_start_date' AND date < '$l2tl_end_date'" > $CaseName-timeline.csv
grep -v -i -f /cases/whitelist.txt $CaseName-timeline.csv > FINAL-$CaseName-timeline.csv
echo Timeline complete: FINAL-$CaseName-timeline.csv


