#!/usr/bin/env python
import json
import math
from os import remove,path
from shutil import copyfile
from redis.sentinel import Sentinel
from redis.sentinel import MasterNotFoundError

print "Starting the creation of conf files... "

sentinelPort = 26379
serverPort = 6379
downAfterMilliseconds = 5000
parallelSyncs = 1
failoverTimeout = 180000
dataDir = "/data"
clusterInfoPath = '/etc/cluster.info'
sentinelConfig = "redis-sentinel/config/sentinel.conf"
serverConfig = "redis-server/config/server.conf"
notificationScript = "/root/notification-script.sh"
clientReconfigScript = "/root/client-reconfig-script.sh"
allInterfaces = "0.0.0.0"
passwordFile = "./../sensitive.conf"
defaultsConfig = "/root/defaults.conf"

clusterInfo = json.load(open(clusterInfoPath))
clusterName = clusterInfo["clusterName"]
instanceName = clusterInfo["instanceInfo"]["name"]
instanceIp = clusterInfo["instanceInfo"]["publicAddr"]
instanceFullName = clusterInfo["instanceInfo"]["fqdn"]
instances = len(clusterInfo["instances"]) + 1
quorum = int(math.ceil(instances / 2.0))
masterIp = instanceIp


for inst in clusterInfo["instances"]:
  try:
    sentinel = Sentinel([(inst["publicAddr"], sentinelPort)], socket_timeout=0.1)
    masterInfo = sentinel.discover_master(clusterName)
    masterIp = masterInfo[0]
    print "Master found"
    break;
  except MasterNotFoundError:
    print inst["publicAddr"] + " is not the master"
  
if masterIp == instanceIp:
  print "Master not found, using local as master " + masterIp

# TODO: leer el password desde "sensitive.conf"
password = "secret"

print "\n### Cluster Info ###"
print " - Cluster name: " + clusterName
print " - Instance name: " + instanceName
print " - Instance ip: " + instanceIp
print " - Master ip: " + masterIp
print " - Instances count: " + `instances`
print " - Quorum: " + `quorum`

if path.isfile(sentinelConfig):
  remove(sentinelConfig)

with open(sentinelConfig, "a") as config:
    config.write("dir \"" + dataDir + "\"\n")
    config.write("bind " + allInterfaces + "\n")
    config.write("port " + `sentinelPort` + "\n")
    config.write("sentinel announce-ip \"" + instanceIp + "\"\n")
    config.write("sentinel announce-port " + `sentinelPort` + "\n")
    config.write("sentinel monitor " + clusterName + " " + masterIp + " " + `serverPort` + " " + `quorum` + "\n")
    config.write("sentinel auth-pass " + clusterName + " \"" + password + "\"\n")
    config.write("sentinel down-after-milliseconds " + clusterName + " " + `downAfterMilliseconds` + "\n")
    config.write("sentinel parallel-syncs " + clusterName + " " + `parallelSyncs` + "\n")
    config.write("sentinel failover-timeout " + clusterName + " " + `failoverTimeout` + "\n")
    config.write("sentinel notification-script " + clusterName + " \"" + notificationScript + "\"\n")
    config.write("sentinel client-reconfig-script " + clusterName + " \"" + clientReconfigScript + "\"\n")
    config.write("\n")
    
if path.isfile(serverConfig):
  remove(serverConfig)

with open(serverConfig, "a") as config:
    config.write("include " + defaultsConfig + "\n")
    config.write("dir \"" + dataDir + "\"\n")
    config.write("bind " + allInterfaces + "\n")
    config.write("requirepass \"" + password + "\"\n")
    config.write("slave-announce-ip \"" + instanceIp + "\"\n")
    config.write("slave-announce-port " + `sentinelPort` + "\n")
    config.write("masterauth \"" + password + "\"\n")
    if masterIp != instanceIp:
      config.write("slaveof \"" + masterIp + "\" " + `serverPort` + "\n")
    config.write("\n")