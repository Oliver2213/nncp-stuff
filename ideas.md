# Ideas
## peers
Adding peers feels very clunky. I like copy-paste as much as the next guy, but I wish there was a more convenient format to send node keys in. Something like a base-64 encoded URL?
```NNCP-node://encoded-keys```

Also a command to actually add those keys - validate them and add them to a block in the neigh section.
```
nncp-addneigh bob nncpnode://encoded-keys...
nncp-rmneigh bob
```
Maybe the fictional nncpnode scheme could have an addr arg, for specifying one or more addresses. Then, though ugly, we have a fully web-ready and standard format for sharing nodes among friends.  
The directory config format sort of solves this neighbor adding problem... Except now your config is a directory, and you still need to write something to add nodes to it. Still, maybe it could be an intermediate step? A bash function to write a new node to a config directory. Then just convert back to hjson when done.

## content and tooling
NNCP is perfect for bulk offline downloading / uploading of content to and from places. NNCP works via unix philosophy, but still needs a bit more work on tooling to 
* Search for content on the internet, or other offline collections. But at first, internet. Needs to be extremely flexible, and likely handled by not just one script or thing.
  * generic wholesale website mirroring. Wget --mirror, web archiving tools
  * specific content or site scripts, which one to one map to programs for those sites. Examples youtube-dlp for youtube and tons of video / audio sites. Get content by link, search term (returning results, accepting results and result ranges back to download).
  * Bit torrent - request specific torrent (from file or magnet link). Use a torrent daemon to download, then send packets back with the content.
  * rss! A natural fit. A tool that registers a user's feeds, then collects them on a schedule and queues them to all your nodes.
  * Podcasts
  * kiwix! generic file downloader would work with zim files. Maybe a tool to send updated versions at configurable time periods. E.G. User can say "I want a full copy of wikipedia refreshed every year".

In general, a lot of these follow similar patterns:
* Search for content and return results. Depending on user's situation, they might want this to go further - don't just return a list of results, download the top n. Or download everything. Or download everything that matches a set of filters.
* Let users keep a file of ongoing subscriptions. These could be search terms that a user always wants to download or be informed of new results for, playlists / updating collections, etc. They can of course update this file. Adding a new URL, search term / set of filters should be enough to start collecting results or media for that subscription - as soon as a node handling these requests gets the packet. Periodically, a node running this would go through all its known users, and recheck each one of their subscriptions. It would download any new ones - according to the user's filters and settings in their subsscription file, queueing the new content into nncp for the user.

Each of these services also needs a standard way to report its help documentation, so people know how to use them. Or maybe they could ship back little wrapper scripts. You send an exec command, and then several files are sent to your node's bin directory. They would map to wget, youtube-dlp, curl, etc commands - using the wget script simply queues that execution. It would probably also need --help, for explaining the differences, what wget options don't work, etc.  

## Users...
Ok. Users for nncp are... Not well defined... Or are they. Devices are (almost) there. You just have to know which are yours and which belong to your friends. (But do you really have friends using this yet?)  
How feasible is it to share a "node" among all your machines, aside from just setting them all to the same keys? It seems like this would break some of the uses of this - if 'john' sends an ack for that 5 gb file from laptop 'John' back to server 'John'... All well and good. But if phone 'John' syncs after this, it won't get the file; it's already been acknowledged.  (And how does fictional John send files anyways? TO himself I guess, since everything has keys.)
This whole discussion might be moot: areas. What if you made a 'user area'. Then give that area to your friends; give the private keys of the area to all your nodes. You still have distinct peers you can send to, but have a consistent identity for everyone else.  
Something to test.

### User management
As stated above, adding nodes is a process. Either manually edit the config file, or get an h-json tool to add a new section in neigh... And do that every time you add a node. Granted that is probably not often, but this could still be easier.  
Idea: the proposed command to add neighbor nodes above. Ideally through some sort of compact URL. Now you could add an exec section for your own nodes that makes this command available offline. Essentially, this brings adding new nodes to your "set" into nncp.
```
# $friendlink is your friend's nncp link, with their keys and maybe an address.
# (doesn't matter if this is an area or a node I think)
nncp-addneigh --update-all-nodes bob $friendlink

Adding neighbor 'bob' with keys ......
```
That command would:
* parse the link, extracting the public keys
* add a new section labeled bob in your neighbors configuration with those keys and any provided addresses.
* With the --update-all-nodes option, create packets for all our known neighbors (excluding bob). These should be exec packets, that just run 
```
nncp-addneigh bob bobs-link
```
Replicating bob as a neighbor across all your nodes. This is a bit rough - you might not be allowed the addneigh command on all your neighbors, and having the update part of the command itself also feels clunky. But the idea is that you can introduce a new neighbor to your local nncp config with one command, and automate that among all your nodes if you want.

## Ideas for utilities over nncp
As utility scripts available asynchronously over nncp, it seems useful to have:
* a script which, when run on an internet-connected machine, will retrieve either the latest nncp, or a specific version, check it's signature, then send the tarball to the node asking.
* As already mentioned, some nncp script or command to add a neighbor node to the local one, and also remove by node ID.
* 