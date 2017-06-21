#!/usr/bin/env python
'''
Name: bulk_evtx_searcher.py
Author: Matthew Green - @mgreen27
Version: 1.0
License: Creative Commons Attribution 4.0 | You may privatize, fork, edit, teach, publish, or deploy for commercial use - with attribution in the text.

Description: 
Script to carve and search for data in event log entries
The script will spit out the complete entry on each search hit to a text file
Included multiprocess capabilities so try to run on a mcahine with lots of cores for faster processing

Requirements:
Python-evtx, pip install python-evtx

Instructions:
$ python bulk_evtx_searcher.py -s "<search,string,comma,delimited>"" </source/folder/> </output/file.log>
$ python bulk_evtx_searcher.py -s "USERNAME1,USERNAME2,10.10.10.10,192.182.23.4" /cases/data /cases/output.txt
'''

from lxml import etree
import Evtx.Evtx as evtx
import Evtx.Views as e_views
import os, multiprocessing
from datetime import datetime

##### Initialisation #####
input_folder = ""
output_file = ""
search_terms = []
input_files = []
##########################

def worker(file, queue):
    worker_time = datetime.now()
    print "Processing " + file
    with evtx.Evtx(file) as log:
        for record in log.records():
            root = etree.fromstring(record.xml())
            for elem in root.iter():
                # change below to elem.attrib is searching by date
                # change to elem.tag if searching for tag
                for item in search_terms:
                    if str(elem.text) == item:
                        queue.put(record.xml())
                        print "Search hit: " + item + " in " + file  
    print(file + " complete in: {}".format(datetime.now() - worker_time))


def listener(queue, output_file):
    EvtDump = open(output_file, "a+")
    while True:
        result = queue.get()
        if result == "kill":
            break
        EvtDump.write(result + "\n") 
        EvtDump.flush()
    EvtDump.close()


def main():
    start_time = datetime.now()

    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument( "--search_terms", "-s",
        help="Comma delimitered list of search terms to use, e.g. SYSTEM,127.0.0.1,Username,DOMAIN", 
        type=str, required=True)
    parser.add_argument("input_folder", 
        help="Input folder to parse event logs (evtx)")
    parser.add_argument("output_file", 
        help="Output file to send records with hits")
    args = parser.parse_args()

    for term in args.search_terms.split(','):
        search_terms.append(str(term))  
    input_folder = os.path.join(args.input_folder, '')
    output_file = args.output_file

    print "\nStarting processing event logs... \n"
    print "Folder to process: " + input_folder 
    print "Output file: " + output_file + "\n"
    print "Searching for:"
    print search_terms

    try: os.remove(output_file)
    except: pass
    print "\nPreparing files to parse..."
    for file in os.listdir(input_folder):
        if file.endswith(".evtx"):
            input_files.append(input_folder + file)
    print "Found " + str(len(input_files)) + " files \n"
    print "Using " + str(multiprocessing.cpu_count()) + " cores for work \n"
    
    #must use Manager queue here, or will not work
    manager = multiprocessing.Manager()
    queue = manager.Queue()    
    pool = multiprocessing.Pool(multiprocessing.cpu_count() + 2)

    #put listener to work first
    watcher = pool.apply_async(listener, (queue, output_file))

    #fire off workers
    jobs = []
    for file in input_files:
        job = pool.apply_async(worker, (file, queue))
        jobs.append(job)
    # collect results from the workers through the pool result queue
    for job in jobs: 
        job.get()

    #now we are done, kill the listener
    queue.put('kill')
    pool.close() 

    if os.stat(output_file).st_size==0:
        os.remove(output_file)
        print "\nComplete!... no hits" 
    else:
        print "\nComplete!... please review " + output_file   
    print("Total duration: {}".format(datetime.now() - start_time))

if __name__ == "__main__":
    main()

