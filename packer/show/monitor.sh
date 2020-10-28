#!/bin/bash

tmux new-session  'htop' \; split-window './status-feed.sh'
