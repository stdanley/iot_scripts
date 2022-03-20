function getWifiStatus(){
	ret=""
	pending="true";
	for (i=0;i<120;i++) {
		line="wifi status | if grep -cq '\"pending\": true' ;\n then \n echo true \nelse echo false \nfi"
        	if ( ( line | getline result ) > 0 ) {
			pending=result;
                	if (result=="false") {
				close(line);
				break;
			} 
			close(line);
			system("sleep 1");
		}
        }

	line="wifi status | if grep -cq '\"up\": false' ;\n then \n echo wifiOff \nelse echo wifiOn \nfi"
        if ( ( line | getline result ) > 0 ) {
                ret=result
        }
        close(line)
	return ret
}
function restartS()
{
        line="/etc/init.d/mqtt restart"
        system(line);
}

BEGIN{}
{
    if(NF<1) {
    	res= "{ \"err\": \"wrong cmd:" "\" }"
    	print res
    } else {
       	#id=$1
       	cmd=$1
        res="{ "
        if (cmd=="wifiStatus") {
                res=res"\"wifi\": \"" getWifiStatus() "\""
        } 
	else 
        if (cmd=="wifiOn") {
		status=getWifiStatus()
		if (status=="wifiOff") {
			line="/usr/bin/wifi_schedule.sh  start"
			system (line)
			status=getWifiStatus()
		}
                res=res"\"wifi\": \"" status "\""
			
	}
	else 
        if (cmd=="wifiOff") {
		status=getWifiStatus()
		if (status=="wifiOn") {
			line="/usr/bin/wifi_schedule.sh forcestop; sleep 3"
			system (line)
			status=getWifiStatus()
		}
                res=res"\"wifi\": \"" status "\""
	} else 
        if (cmd=="open") {
		line="openDoor"
		system (line)
                res=res"\"sys\": \"open door executed\""
	} else 
	if (cmd=="reboot_service") {
                restartS()
                res=res"\"service \": \"restared\""
        } else
        if (cmd=="restart_blue") {
		line="/etc/init.d/door reload"
		system (line)
                res=res"\"sys\": \"bluetooth reload executed\""
	} else 
        if (cmd=="reboot") {
		line="reboot"
		system (line)
                res=res"\"sys\": \"rebooting\""
	} else 
        if (cmd=="df") {
		line="df -h /"
		outBuf=""
		while (  (line |getline out) >0) {
			outBuf=out
		}
		close (line)
		split (outBuf,tmp);	
		split (tmp[5],tmp2,"%");
                res=res"\"disk\": " tmp2[1] ""
	} else 
        if (cmd=="uptime") {
		line="uptime"
		while (  (line |getline out) >0) {
                	res=res"\"up\": \"" out "\""
		}
		close (line)
	} 
	
        res=res"  }"
        print res
        fflush()
    }
}
END{}

