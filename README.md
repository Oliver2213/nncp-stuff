# NNCP stuff
This is a collection of scripts and writings about [NNCP, node to node copy](https://nncp.mirrors.quux.org/).
It's a very flexible project, and I need a place to begin collecting ideas of usage, scripts, examples, links, etc.

## Resources
* [Source code](https://git.cypherpunks.ru/nncp.git) 
* [Website](http://www.nncpgo.org/)

## contains
### nncp-sync
Scans mounted USB drives, running this manual, sneaker net sync process for each. The idea is that you plug a drive in, run ncp-sync, and any queued files, file requests, commands, etc get read from and written. This will *receive* any packets other machines wrote to the drive intended for this machine (or which it will rout), then *send* anything queued for other nodes by writing those encrypted packets to the disk. Repeat, bouncing among configured machines - interact with any of them asynchronously via the flash drive, running the script on each machine to process updates.  
You can still connect them real-time with nncp-daemon, nncp-caller, nncp-call.  

How this works, excerpted from [this script's source](https://www.complete.org/dead-usb-drives-are-fine-building-a-reliable-sneakernet/):

>Here are the basic steps to processing this stuff with NNCP:
>1. First, we use nncp-xfer -rx to process incoming packets from the USB (or other media) device. This moves them into the NNCP inbound queue, deleting them from the media device, and verifies the packet integrity.
>2. We use nncp-ack -node $NODE to create ACK packets responding to the packets we just loaded into the rx queue. It writes a list of generated ACKs onto fd 4, which we save off for later use.
>3. We run nncp-toss -seen to process the incoming queue. The use of -seen causes NNCP to remember the hashes of packets seen before, so a duplicate of an already-seen packet will not be processed twice. This command also processes incoming ACKs for packets we’ve sent out previously; if they pass verification, the relevant packets are removed from the local machine’s tx queue.
>4. Now, we use nncp-xfer -keep -tx -mkdir -node $NODE to send outgoing packets to a given node by writing them to a given directory on the media device. -keep causes them to remain in the outgoing queue.
>5. Finally, we use the list of generated ACK packets saved off in step 2 above. That list is passed to nncp-rm -node $NODE -pkt < $FILE to remove those specific packets from the outbound queue. The reason is that there will never be an ACK of ACK packet (that would create an infinite loop), so if we don’t delete them in this manner, they would hang around forever.

### MacOS USB autorun script
This is an apple script which runs a shell script, 'OnInsert', when a USB drive is inserted. This associated via a folder action to /volumes.
Once set up, if a flash drive has a OnInsert file, it will be tried as a shell script whenever a new drive is mounted (folder appears in /volumes).  
This, of course, has huge security implications, and I don't think I'd have this turned on if I plugged in drives from other people to my machines! - but its useful in the context of drives of your own (that you trust) with nncp.

