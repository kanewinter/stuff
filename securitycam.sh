#!/bin/sh

/usr/bin/streamer -c /dev/video0 -b 16 -o /home/kane/Pictures/SecurityCam/$(date -u +\%m\%d\%y\-\%H\%M\%S).laptop.jpeg >> /tmp/securitycam.log 2>&1
/usr/bin/streamer -c /dev/video1 -b 16 -o /home/kane/Pictures/SecurityCam/$(date -u +\%m\%d\%y\-\%H\%M\%S).ext.jpeg >> /tmp/securitycam.log 2>&1
