# iot_scripts

## connect your legacy systems into IOT network

this repo include scripts to connect your legacy systems like router, linux server, etc. to IOT network, 
so you can control them use mobile/desktop iot clients.

leverage the open-sourced mqtt client mosquitto-pub/sub,  bash and awk scripts, we can put these all together
to form a flow to interact with remote iot brokers.

## flow design
```
┌───────────────────────────────────────────────────────────────────┐
│                    legacy machine                                 │
│                                                                   │
│                                                                   │
│   ┌─────────────┐pipe     ┌───────────┐pipe     ┌─────────────┐   │
│   │mosquitto_sub├────────►│awk scripts├────────►│mosquitto_pub│   │
│   └─┬───────────┘         └───────────┘         └───────┬─────┘   │
│     │                                                   │         │
└─────┼───────────────────────────────────────────────────┼─────────┘
      │                                                   │
      │                                                   │
      │           ┌─────────────────┐                     │
      │           │  mqtt server    │                     │
      └──────────►└─────────────────┘  ◄──────────────────┘
           mqtts connection
```


## configration

the configure files located in /etc/mqtt:

**mqtt.conf:**

```
id=xxxx				#uniq mqtt client id used to connect to mqtt server. this client also subscribe to command/{id} and publish event to reply/{id}
cafile=xxx
keyfile=xx
certfile=xx			#cafile, certfile, keyfile used to auth the client,use client certification authrization methods
server=xxx.xxx.xxx.xxx                #domain name or ip this client connect to, use the standard mqtts port:8883
```

**cmd.awk:**

cmd.awk implements logic to parse mqtt message and call system commands ,then output result in json format, like this:
```
if (cmd=="reboot") {                                               
                line="reboot"                                              
                system (line)                                              
                res=res"\"sys\": \"rebooting\""                            
        }
```
following commands have been implemented:

* __reboot system__
* __check uptime__
* __check disk usage__
* __get ipv6 address__
* __turn on/off wifi__
* __start other service__


## supported systems
### linux 
 **pre requirements**

 install mosquitto-clients package using os-specific package manager
 install __gawk__ manually instead of traditional awk on openwrt .
 
 **run as system service**
 
 please refer to the system guide on how to registe a system service. 
 the dirs **linux** and **openwrt** are implements to make our iot connector a system service.


## mqtt server:

we can leverage public mqtt server self-hosted, by simply install mosquitto. 
the only should be noted is we must use client-cerfication plus ssl instead of plain user/password, for security reasons.

## mqtt mobile client

there are so many mobile mqtt clients. I choose [mqtt-dash](https://play.google.com/store/apps/details?id=net.routix.mqttdash&hl=en), 
please read following link to see how to configure mqtt-dash:
https://www.hackster.io/fabiosouza/use-mqtt-dash-to-control-a-lamp-over-the-internet-97fa63#:~:text=MQTT%20Dash%20is%20one%20of%20the%20best%20free,use.%20You%20can%20download%20it%20in%20Google%20Play. 


use the convenient mobile mqtt clients, we can control the system remotely with just a click



