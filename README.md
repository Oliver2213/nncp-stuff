# NNCP stuff
This is a collection of scripts and writings about [NNCP, node to node copy](https://nncp.mirrors.quux.org/).
It's a very flexible project, and I need a place to begin collecting ideas of usage, scripts, examples, links, etc.

## Resources
* [Source code](https://git.cypherpunks.ru/nncp.git) 
* [Website](http://www.nncpgo.org/)

## contains
### MacOS USB autorun script
This is an apple script which runs a shell script, 'OnInsert', when a USB drive is inserted. This associated via a folder action to /volumes.
Once set up, if a flash drive has a OnInsert file, it will be tried as a shell script whenever a new drive is mounted (folder appears in /volumes).  
This, of course, has huge security implications, and I don't think I'd have this turned on if I plugged in drives from other people to my machines! - but its useful in the context of drives of your own (that you trust) with nncp.

