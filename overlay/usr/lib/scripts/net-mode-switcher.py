import wiringpi
import time
import sys
import subprocess
from wiringpi import GPIO


#use pin 15 and GND pin for button
#use pin 11 and GND pin for LED

wiringpi.wiringPiSetup()
NUM = 8
wiringpi.pinMode(NUM, GPIO.INPUT)
wiringpi.pullUpDnControl(NUM, GPIO.PUD_DOWN)
LED = 5
wiringpi.pinMode(LED, GPIO.OUTPUT)
wiringpi.digitalWrite(LED, GPIO.LOW)
# Запуск режима свитча при первом запуске скрипта
process = subprocess.Popen(['/bin/bash','/usr/lib/scripts/switch.sh'])
process.wait() # Wait for process to complete.
process.kill()
wiringpi.digitalWrite(LED, GPIO.LOW)
FLAG = 1

while True:
    while FLAG:
        if wiringpi.digitalRead(NUM):
            #put script for router mode here
            process = subprocess.Popen(['/bin/bash','/usr/lib/scripts/router.sh'])
            process.wait() # Wait for process to complete.
            process.kill()
            wiringpi.digitalWrite(LED, GPIO.HIGH)
            FLAG = 0
            time.sleep(1)
        else:
            time.sleep(0.05)
    while FLAG == 0:
        if wiringpi.digitalRead(NUM):
            #put script for switch mode here
            process = subprocess.Popen(['/bin/bash','/usr/lib/scripts/switch.sh'])
            process.wait() # Wait for process to complete.
            process.kill()
            FLAG = 1
            wiringpi.digitalWrite(LED, GPIO.LOW)
            time.sleep(1)
        else:
            time.sleep(0.05)

