#!/bin/bash
# Script from: https://www.complete.org/dead-usb-drives-are-fine-building-a-reliable-sneakernet/
# Adapted to my paths and local nodes.

set -eo pipefail

MEDIABASE="/volumes/"

# The local node name
NODENAME="mbp"

# All nodes.  NODENAME should be in this list.
ALLNODES="mbp macmini-server"

RUNNNCP=""
# If you need to sudo, use something like RUNNNCP="sudo -Hu nncp"
NNCPPATH="/Users/blakeoliver/bin/nncp"

ACKPATH="`mktemp -d`"

# Process incoming packets.
#
# Parameters: $1 - the path to scan.  Must contain a directory
# named "nncp".
procrxpath () {
    while [ -n "$1" ]; do
        BASEPATH="$1/nncp"
        shift
        if ! [ -d "$BASEPATH" ]; then
            echo "$BASEPATH doesn't exist; skipping"
            continue
        fi

        echo " *** Incoming: processing $BASEPATH"
        TMPDIR="`mktemp -d`"

        # This rsync and the one below can help with
        # certain permission issues from weird foreign
        # media.  You could just eliminate it and
        # always use $BASEPATH instead of $TMPDIR below.
        rsync -rt "$BASEPATH/" "$TMPDIR/"

        # You may need these next two lines if using sudo as above.
        # chgrp -R nncp "$TMPDIR"
        # chmod -R g+rwX "$TMPDIR"
        echo "     Running nncp-xfer -rx"
        $RUNNNCP $NNCPPATH/nncp-xfer -progress -rx "$TMPDIR"

        for NODE in $ALLNODES; do
                if [ "$NODE" != "$NODENAME" ]; then
                        echo "     Running nncp-ack for $NODE"

                        # Now, we generate ACK packets for each node we will
                        # process.  nncp-ack writes a list of the created
                        # ACK packets to fd 4.  We'll use them later.
                        # If using sudo, add -C 5 after $RUNNNCP.
                        $RUNNNCP $NNCPPATH/nncp-ack -progress -node "$NODE" \
                           4>> "$ACKPATH/$NODE"
                fi
        done

        rsync --delete -rt "$TMPDIR/" "$BASEPATH/"
        rm -fr "$TMPDIR"
    done
}


proctxpath () {
    while [ -n "$1" ]; do
        BASEPATH="$1/nncp"
        shift
        if ! [ -d "$BASEPATH" ]; then
            echo "$BASEPATH doesn't exist; skipping"
            continue
        fi

        echo " *** Outgoing: processing $BASEPATH"
        TMPDIR="`mktemp -d`"
        rsync -rt "$BASEPATH/" "$TMPDIR/"
        # You may need these two lines if using sudo:
        # chgrp -R nncp "$TMPDIR"
        # chmod -R g+rwX "$TMPDIR"

        for DESTHOST in $ALLNODES; do
            if [ "$DESTHOST" = "$NODENAME" ]; then
                continue
            fi

            # Copy outgoing packets to this node, but keep them in the outgoing
            # queue with -keep.
            $RUNNNCP $NNCPPATH/nncp-xfer -keep -tx -mkdir -node "$DESTHOST" -progress "$TMPDIR"

            # Here is the key: that list of ACK packets we made above - now we delete them.
            # There will never be an ACK for an ACK, so they'd keep sending forever
            # if we didn't do this.
            if [ -f "$ACKPATH/$DESTHOST" ]; then
                echo "nncp-rm for node $DESTHOST"
                $RUNNNCP $NNCPPATH/nncp-rm -debug -node "$DESTHOST" -pkt < "$ACKPATH/$DESTHOST"
            fi

        done

        rsync --delete -rt "$TMPDIR/" "$BASEPATH/"
        rm -rf "$TMPDIR"

        # We only want to write stuff once.
        return 0
    done
}

procrxpath "$MEDIABASE"/*

echo " *** Initial tossing..."

# We make sure to use -seen to rule out duplicates.
$RUNNNCP $NNCPPATH/nncp-toss -progress -seen

proctxpath "$MEDIABASE"/*

echo "You can unmount devices now."

echo "Done."
