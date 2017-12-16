#!/usr/bin/env bash
redis-server & 
redis-server --port 6377 & 
redis-server --port 6378 &
