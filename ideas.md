# Ideas
## peers
Adding peers feels very clunky. I like copy-paste as much as the next guy, but I wish there was a more convenient format to send node keys in. Something like a base-64 encoded URL?
```NNCP-node://encoded-keys```

Also a command to actually add those keys - validate them and add them to a block in the neigh section.
```
nncp-addneigh bob nncpnode://encoded-keys...
nncp-rmneigh bob
```
Maybe the fictional nncpnode scheme could have an addr arg, for specifying one or more addresses. Then, though ugly, we have a fully web-ready and standard format for sharing nodes aong friends.

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
* Let users keep a file of ongoing subscriptions. These could be search terms that a user always wants to download or be informed of new results for, playlists / updating collections, etc. They can of course update this file. Adding a new URL, search term / set of filters should be enough to start collecting results or media for that subscription - as soon as a node handling these requests gets the packet.

