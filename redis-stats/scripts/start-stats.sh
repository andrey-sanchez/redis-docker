#!/bin/sh
exec java -jar /root/redis-stats.jar server:6379 sentinel:26379 --server --verbose
