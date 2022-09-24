#!/bin/bash
: '
Prerequisites: 
Subfinder
amass
httpx
gowitness'

echo "Script Started"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "Enter the Domain Name:"

read Domain;mkdir $Domain;cd $Domain 

echo " Started Subdomain Enumeration" 

subfinder -d -silent $Domain >subd.txt

amass enum -d $Domain > subd1;cat subd.txt subd1 >subdomain.txt

awk '!seen[$0]++' subdomain.txt >finalsubdout.txt

echo "Filtering out the working subdomains"
echo "============================================================================================"

cat finalsubdout.txt|  httpx >workingdomains.txt

echo "Started taking the screenshots for the working domains"
echo "============================================================================================"
gowitness file -f workingdomains.txt


echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Started Running Nuclei ---> output is saved to nuclei.json"
echo "======================================================================"
nuclei -l workingdomains.txt  -silent -exclude-severity info -o nuclei.json -json

echo "started directory bruteforcing"
echo "============================================================================================"
#!/bin/bash
for word in $(cat workingdomains.txt)
do
 for a in $(echo "$word" | tr / _ ) 
 do
  sudo ffuf -c -t 100 -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -u $word/FUZZ -mc 200,302,401,500 -recursion -e .php,.txt -o $a.html -of html
 done
done

echo "started XSS scan"
echo "============================================================================================"
gospider -S workingdomains.txt -c 10 -d 5 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source | grep -e "code-200" | awk '{print $5}'| grep "=" | qsreplace -a | dalfox pipe | tee xssresult.txt
echo"scan finished"





























