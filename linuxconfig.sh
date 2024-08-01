#!/bin/bash

clear
echo "-------------------------------------------------------------------------------------------"
echo "|  Welcome to the 66 bit TTD Pool installer script for Linux.                             |"
echo "|  With this script you can configure a Vast.AI instance with up to 18 Nvidia GPUs.       |"
echo "|  It should work with all GPUs Vast has available.                                       |"
echo "|  More information will be displayed when the script finishes.                           |"
echo "|  If you encounter any problems please contact me in the telegram chat.                  |"
echo "|                                                                                         |"
echo "|  Thanks and happy hunting Chris Zahrt                                                   |"
echo "|                                                                                         |"
echo "|  Press enter to continue.                                                               |"
echo "-------------------------------------------------------------------------------------------"
clear
apt-get update
apt-get install -y joe
apt-get install -y zip
apt-get install -y screen
clear

ClientFile="ttdclientlinuxall.zip"
GPUName="4070-x3"       # Define your GPU name here
GPUCount=3           # Define the number of GPUs here
ScanMode=1           # Define the scan mode here
UserName="lovecrypto"  # Define your username here
PayoutAddress="bc1qxddz9h5kvvl25vsqx3yvng0vcqfa7k06nyxljj"  # Define your BTC payout address here

echo "We are going to use $ClientFile."
wget http://www.ttdsales.com/66bit/$ClientFile
unzip $ClientFile
cd ttdclient
chmod 755 ttdclientVS vanitysearch
cd ..
clear

# Determine GPURanges based on ScanMode
if [[ $ScanMode -eq 2 ]]; then
    GPURanges="seq-F"
elif [[ $ScanMode -eq 3 ]]; then
    GPURanges="seq-R"
elif [[ $ScanMode -eq 4 ]]; then
    GPURanges="seq-U"
elif [[ $ScanMode -eq 5 ]]; then
    GPURanges="seq-D"
elif [[ $ScanMode -eq 6 ]]; then
    GPURanges="seq-UF"
elif [[ $ScanMode -eq 7 ]]; then
    GPURanges="seq-UR"
elif [[ $ScanMode -eq 8 ]]; then
    GPURanges="seq-DF"
elif [[ $ScanMode -eq 9 ]]; then
    GPURanges="seq-DR"
elif [[ $ScanMode -eq 10 ]]; then
    GPURanges="seq-Random"
else
    GPURanges=1  # Default value if not specified correctly
fi

echo "Configuring this instance for $GPURanges range(s) each on $GPUCount $GPUName GPU(s) for user $UserName."
echo "With a payout address of $PayoutAddress."

for (( n=1; n<=$GPUCount; n++ ))
do
    echo "Setting up GPU $n"
    mkdir v$(($n-1))
    cp ttdclient/* v$(($n-1))
    cd v$(($n-1))
    sed -i "1s/.*/$UserName.vast-$GPUName-$(($n-1)),$PayoutAddress/" settings.ini
    sed -i "2s/.*/-t 0 -gpu -gpuId $(($n-1))/" settings.ini
    sed -i "5s/.*/$GPURanges/" settings.ini
    screen -dmS "v$(($n-1))" ./ttdclientVS
    cd ..
    echo "cd v$(($n-1))" >> go
    echo "screen -dmS "v$(($n-1))" ./ttdclientVS" >> go
    echo "cd .." >> go
    echo "sleep 1" >> go
    sleep 1
done

chmod 755 go
curl -s -X POST https://api.telegram.org/bot7478179242:AAGVcJGFulmxCqKNp5pSzg-B7-Rbw31Brgc/sendMessage -d chat_id=5391995999 -d text="Setup complete!"

echo "-------------------------------------------------------------------------------------------"
echo "|  Config is complete.  Your ttdclient instances should now be running.                   |"
echo "|  Enter 'screen -list' to see the instances.                                             |"
echo "|  Enter 'screen -r v0' to connect to an instance. (v0 is the instance name from -list)   |"
echo "|  When connected to an instance press contrl-a then d to drop back out of the instance.  |"
echo "|  Enter 'nvidia-smi' to see gpu load and power consumption.                              |"
echo "|  You can close this connection and the instance(s) will continue running.               |"
echo "|  If the rig restarts you can restart the screen session(s) with './go'.                 |"
echo "-------------------------------------------------------------------------------------------"
