#!/bin/bash

USER_AGENT="\"Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalboot)\"";

link=$1;

wget --user-agent="$USER_AGENT" $link -O index.html;
