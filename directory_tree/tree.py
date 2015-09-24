#!/usr/bin/python

import os
import sys

#------------------------------------------------------------------------------

def  get_prefix (rel_path):
    dirs = rel_path.split(os.sep);
    dirs.pop()   
    prefix_str = ''
    for folder in dirs:
        prefix_str += ' ' * 4
    prefix_str += "|-- "
    return prefix_str
        
         
#-------------------------------------------------------------------------------    
    
def  tree (path, base=''):   
    if not base:
        base = path     
    fullpath = ''
    fullbase = ''
    if os.path.isabs(path):
        fullpath = path
    else:
        fullpath = os.path.abspath(path)
    if os.path.isabs(base):
        fullbase = base 
    else:
        fullbase = os.path.abspath(base)

    filename = os.path.basename(fullpath)
    rel_path = os.path.relpath(fullpath, fullbase);
    
    if rel_path == '.' :
        print filename
    else:
        pass
   
    for item in os.listdir(fullpath):
        itempath = os.path.join(fullpath, item)
        rel_path = os.path.relpath(itempath, fullbase);
        prefix_str = get_prefix(rel_path)
        if os.path.isfile(itempath):
            print prefix_str + item
        if os.path.isdir(itempath):  
            print  prefix_str + item         
            tree(itempath, fullbase)
             
    return

#------------------------------------------------------------------------------
#
# main 
#
#default is current working directory
path = '.'
# get command argument
if  len(sys.argv) < 2:
    pass
else:
    path = sys.argv[1] 

# validate the path
# TODO print help information
if not (os.path.exists(path)):
    print "Error: '" + path + "' is an invalid path"
    sys.exit()


if os.path.isdir(path):
    tree(path)
else:
    print path  
  

   
    
