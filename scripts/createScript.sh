#!/bin/bash
cat $1/* > mustaches/$1.mustache
mustache data/$1.json mustaches/$1.mustache > scripts/$1.sh
chmod +x scripts/*
