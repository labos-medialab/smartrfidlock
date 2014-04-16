#!/bin/bash 
cat /dev/arduino > /tmp/serial.txt &
sleep 2

#open.sen.se
APIKEY=apikkey.nr.
STATE="LOCKED"
VARO="PRAZNO"
CODE="passwd"
BRNA="card.nr" #52421
PERO="card.nr" #52421
BRNA2="card.nr" #52420
VALENT="card.nr" #52422
VALENTINO="card.nr"
zatvarano=0
otvarano=0
#DANIEL=""
#Unauthorized_feed= 44776
#Authorized_feed=   44777
#Lockdown_feed=     44778
#LOCK
#CASE
#party
TEMP=$(digitemp_DS9097 -a -q -o"%.2C")

ARDUINO() {
	echo -n "$1" > /dev/arduino
}
  
OPEN() {
	ARDUINO ";open;unlock;ok;ON;"
	echo "PRAZNO" > /tmp/serial.txt
	ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "sh -c 'nohup killall wget & nohup killall mplayer > /dev/null 2>1 &'"
        ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key  "sh -c 'nohup mpc play > /dev/null 2>1 &'"
	curl 'http://api.sen.se/events/?sense_key='$APIKEY -X POST -H "Content-type: application/json" -d '[{"feed_id": '44777',"value": '$TEMP'}]'
	#STATE="UNLOCKED"
	/etc/init.d/mjpg-streamer stop
	ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "echo -n "df" > /dev/ttyUSB0 &"
	otvarano="1"
	zatvarano="0"
}

CLOSE() {
	ARDUINO ";close;ok;OFF;"
        ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "sh -c 'nohup  killall mplayer & nohup mpc stop > /dev/null 2>1 &'"
        ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "sh -c 'nohup killall wget && nohup ffmpeg -framerate 5 -i Dropbox/video.mjpg Dropbox/video/upad_$(date +"%d.%m.%H:%M:%S").mp4 > /dev/null 2>1 &'"
	curl 'http://api.sen.se/events/?sense_key='$APIKEY -X POST -H "Content-type: application/json" -d '[{"feed_id": '44778',"value": '$TEMP'}]'
	echo "PRAZNO" > /tmp/serial.txt
	#STATE="LOCKED"
	/etc/init.d/mjpg-streamer start
	ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "echo -n "L1*0" > /dev/ttyUSB0 &"
	zatvarano="1"
	otvarano="0"
}

CLOSE
while [ 1 ]
do
  if [[ $STATE == "UNLOCKED" && $otvarano == "0" ]]; then
    OPEN
  fi
  
  if [[ $STATE == "LOCKED" && $zatvarano == "0" && $BRAVA == "closed"  ]]; then
    CLOSE
  fi

  TXTSIZE=$(ls -al /tmp/serial.txt | cut -f 5 -d ' ') #(limiter 5 polje je varijabla)                                                         
  LIMIT=100000
  TEMP=$(digitemp_DS9097 -a -q -o"%.2C")
  VARN=$(tail -n 1 /tmp/serial.txt)          
  
  if [[ "$VARN" != "$VARO"  ]]; then 

#BRAVA open
   if [[ "$VARN" == "LOCK" ]]; then                                                                                                                                   
	  BRAVA="open"
#BRAVA closed
   elif [[ "$VARN" == "lock" ]]; then                                                                                                                                   
	  BRAVA="closed"
   elif [[ "$VARN" == "CASE" ]]; then                                                                                                                                   
	  echo TEMPER!!!!!!
	  #mail,sirena
    elif [[ "$STATE" == "LOCKED" ]]; then
	if [[ "$VARN" == "$CODE" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "$BRNA" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "$BRNA2" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "$PERO" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "$VALENT" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "$VALENTINO" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "$DANIEL" ]]; then
	  STATE="UNLOCKED"
	elif [[ "$VARN" == "PRAZNO" ]]; then
	    echo "prazno"
	else
	  ARDUINO ";nok;"
	  echo "PRAZNO" > /tmp/serial.txt
	fi
	
    elif [[ "$STATE" == "UNLOCKED" && "$BRAVA" == "closed" ]]; then
	if [[ "$VARN" == "$CODE" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "$BRNA" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "$BRNA2" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "$PERO" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "$VALENT" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "$VALENTINO" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "$DANIEL" ]]; then
	  STATE="LOCKED"
	elif [[ "$VARN" == "0" ]]; then
	  ARDUINO ";unlock;ok;"
	elif [[ "$VARN" == "PRAZNO" ]]; then
	    echo "prazno"
	else
	  ARDUINO ";nok;"
	  echo "PRAZNO" > /tmp/serial.txt
	fi
	
    elif [[ "$STATE" == "UNLOCKED" && "$BRAVA" == "open" ]]; then
#RGB  Arduino:
	if [[ "$VARN" == L1* ]]; then
	  ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "echo -n "$VARN" > /dev/ttyUSB0 &"
	  ARDUINO ";ok;"
	elif [[ "$VARN" == "party" ]]; then   
	 ARDUINO ";ok;ON;"
	 ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "sh -c 'nohup  killall mplayer && nohup mpc play > /dev/null 2>1 &'"
	ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "echo -n "df" > /dev/ttyUSB0 &"
	elif [[ "$VARN" == "PARTY" ]]; then
	  ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key  "sh -c 'nohup mpc stop > /dev/null 2>1 &'"
	  sleep 1
	  ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key  "sh -c 'nohup mplayer /home/labos/1.mp3  > /dev/null 2>1 &'"
	  ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "echo -n "pf" > /dev/ttyUSB0 &"  
	ARDUINO ";ok;ON;OFF;ON;OFF;"
	elif [[ "$VARN" == "PRAZNO" ]]; then
	    echo "prazno"
	    else
	  ARDUINO ";nok;"
	  echo "PRAZNO" > /tmp/serial.txt
	fi

     elif [[ "$VARN" == "PRAZNO" ]]; then
	    echo "prazno"	     
    fi
      
      #intruder
   if [[ "$BRAVA" == "open" && "$STATE" == "LOCKED" ]]; then                                                                                                                                 
	    ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key  "sh -c 'nohup wget -O Dropbox/video.mjpg  http://192.168.35.182:8080/?action=stream  > /dev/null 2>1 &'"
	    ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key  "sh -c 'nohup mplayer /home/labos/intruder.mp3 > /dev/null 2>1 &'"
	   # curl 'http://api.sen.se/events/?sense_key='$APIKEY -X POST -H "Content-type: application/json" -d '[{"feed_id": '44776',"value": '$TEMP'}]'
	    ssh -f root@192.168.35.225 -i /etc/dropbear/dropbear_rsa_host_key "echo -n "L1*7" > /dev/ttyUSB0 &"
	    #echo "intrude
	    zatvarano="0"
    fi
  fi                                                                                                                                             

  
  
  if [ "$TXTSIZE" -gt "$LIMIT" ]                                                                                                                 
      then                                                                                                                                     
        rm /tmp/serial.txt                                                                                                                     
  fi                                                                                                                                     
             

  VARO=$VARN

done
