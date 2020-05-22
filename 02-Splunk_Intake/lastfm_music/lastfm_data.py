#!/usr/bin/env python3.5
# coding: utf-8

import lastexport
import os
from optparse import OptionParser
import syslog
import sys

__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

syslog.openlog("lastfm_data.py")

if len(sys.argv) != 2:
    sys.exit("first arg as user")

with open("/home/paul/vp_ip", "r") as f:
    ip=f.read().replace('\n','')



# Check du dernier epochtime
with open(os.path.join(__location__, "last_epoch") , "r") as le:
    last_epoch = le.read()

# Getting data from last.fm, taken from lastexport.py
parser = OptionParser()
username, outfile, startpage, server, infotype = lastexport.get_options(parser)
#Override username
username = sys.argv[1]
#TOTEST - donner un max de pages a chercher
lastexport.main(server, username, startpage, outfile, infotype)


final = list()
first = True
with open("exported_tracks.txt", "r") as f:
        for l in f.readlines():
            lst = l.split("\t")
            # New last epoch
            if lst[0] <= last_epoch:
                break
            else:
                # key=value format
                final.append("date=\"{}\" track=\"{}\" artist=\"{}\" album=\"{}\"\n".format(lst[0], lst[1], lst[2], lst[3]))
            if first: # The first line is the last song played
                with open(os.path.join(__location__ , "last_epoch"), "w") as le_new:
                    le_new.write(lst[0])
                    syslog.syslog("new last_epoch={}".format(lst[0]))
                    first = False

os.remove("exported_tracks.txt") 

final.reverse()

# TODO - Trouver un meilleur endroit
with open("/var/log/last-fm_tracks.log", "a+") as log:
    for track in final:
        log.write(track)
    syslog.syslog("Wrote {} new songs".format(len(final)))
    os.system("ssh -p 22 -i /home/paul/.ssh/id_rsa paul@{} \"notify-send \'LastFM Data\' \'Wrote {} new songs\' -i info\"".format(ip, len(final)))
