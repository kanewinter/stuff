#!/bin/bash
echo " %%%%%%%%% Login !!!!!!!"
kinit nlewis
sleep 5
thunderbird > /tmp/kanethunderbird.log 2>&1 &
firefox > /tmp/kanefirefox.log 2>&1 &
skype > /tmp/kaneskype.log 2>&1 &
pidgin > /tmp/kanepidgin.log 2>&1 &
google-chrome > /tmp/kanegoogle-chrome.log 2>&1 &
keepassx > /tmp/kanekeepassx.log 2>&1 &
