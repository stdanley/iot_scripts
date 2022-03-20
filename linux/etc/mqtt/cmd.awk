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
function checkGogs()
{
	line="ps -ef |grep gogs |grep -v grep"
	if ( ( line | getline result ) > 0 ) { 
                close(line);
                return 1;
        }
	close (line);
	return 0;
}
function startGogs()
{
	ret=""
	if (checkGogs()==1) return "gogs is runing";

	line="cd /apps/gogs; sudo -u git /apps/gogs/gogs web &"
      	if ( ( line | getline result ) > 0 ) {
		getline result
		#ret="failed:"result;
		#close(line);
		#return ret;
	}
	close(line);
	system("sleep 1");
	if (checkGogs()==1) return "gogs started";
	else return "gogs start failed";
}
function stopGogs()
{
	ret=""
	if (checkGogs()==0) return "gogs already stopped";

	line="ps -ef|grep gogs |grep -v sudo |grep -v grep |awk '{print $2}' |xargs kill"
      	if ( ( line | getline result ) > 0 ) {
		ret=" stop failed:" result;
		close(line);
		return ret;
	}
	close(line);
	system("sleep 1");
	if (checkGogs()==0) return "gogs stopped";
	else return "gogs stop failed";
}
function restartS()
{
	line="service mqtt stop"
	system(line);
	line="service mqtt start"
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
	print "recv cmd:[" cmd "]" >> "/var/log/mqtt.log"
        res="{ "
        if (cmd=="reboot") {
		line="reboot"
		system (line)
                res=res"\"sys\": \"rebooting\""
	} else 
        if (cmd=="ipv6") {
		line= "ifconfig eth0 |grep Global "
      		if ( ( line | getline result ) > 0 ) {
                	res=res"\"ipv6\": \"[" result "]\""
		}
		close(line);
	} else 
        if (cmd=="reboot_service") {
		restartS()
                res=res"\"service \": \"restared\""
	} else 
        if (cmd=="git_start") {
                res=res"\"gogs\": \"" startGogs() "\""
	} else 
        if (cmd=="git_stop") {
                res=res"\"gogs\": \"" stopGogs() "\""
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

