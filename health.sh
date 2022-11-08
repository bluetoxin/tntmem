#!/bin/bash

connect="""
local CONSOLE_SOCKET_PATH = 'unix/:/var/run/tarantool/tarantool.sock'
local console = require('console') 
local os = require('os') 
local yaml = require('yaml') 
console.on_start(function(self) 
    local status, reason 
    status, reason = pcall(function() require('console').connect(CONSOLE_SOCKET_PATH) end) 
    if not status then 
        self:print(reason) 
        os.exit(1) 
    end 
"""

disconnect="""
    os.exit(0) 
end) 
console.on_client_disconnect(function(self) self.running = false end) 
console.start() 
os.exit(0) 
"""

getmem="""
$connect
    cmd = 'box.info.memory()' 
    local res = self:eval(cmd) 
    if res ~= nil then 
        res = yaml.decode(res) 
 print(res[1].lua) 
    end 
$disconnect
"""

collectgarbage="""
$connect
    action = 'collect' 
    cmd = 'collectgarbage(action)' 
    self:eval(cmd) 
$disconnect
"""


status=$( ( echo -e $getmem | tarantool ) 2>/dev/null)


echo "$status"

if [ -z $1 ]
then
    # Default is 512MB
    limit=512
else
    limit=$1
fi


if [ "$status" -ge "$(($limit*1000000))" ]
then
    # Collect Garbage
    $( ( echo -e $collectgarbage | tarantool ) 2>/dev/null)
    exit 1
else
    exit 0
fi
