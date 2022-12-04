name='adnan'
logformat='httpd-logs'
timestamp=$(date '+%d%m%Y-%H%M%S') 
type='tar'

sudo apt update -y

echo  "-------Apache installed or not"
which apache2
if [[ $? == 0 ]]
then
	echo "Apache already installed"

else
	sudo apt install apache2 -y
	echo "Installed Apache now"
fi


echo "----- running or not ----------"


if [[ $(systemctl status apache2 | grep -i Running | awk '{print $3}') == '(running)' ]]
then
	echo "Already running"
else
	systemctl restart apache2
	echo "restarting the apache2"
fi

echo "----enabled or not----"


if [[ $(systemctl list-unit-files |grep apache2.service |awk '{ print $2}') == "enabled" ]] 
then
	echo "enabled"
else
	echo "enabling"
	systemctl enable apache2
fi

echo "-------- making tar -------------------"

cd /var/log/apache2 && tar -cvf $name-$logformat-${timestamp}.$type *.log &&  
mv $name-$logformat-${timestamp}.$type /tmp


aws s3 	cp /tmp/$name-$logformat-${timestamp}.$type  s3://s3-adnan/adnan/$name-$logformat-${timestamp}.$type

dir="/var/www/html"

if [[ ! -f ${dir}/inventory.html ]]; then 

echo -e "Log Type\t\tTime Created\t\ttype\t\tsize" > ${dir}/inventory.html

fi

if [[ -f ${dir}/inventory.html ]] 
then


size=$(du -h /tmp/${name}-$logformat-${timestamp}.$type | awk '{print $1}')

echo -e "$logformat\t-\t${timestamp}\t-\t$type\t-\t${size}" >> ${dir}/inventory.html

fi



if [[ ! -f /etc/cron.d/automation ]]; then

echo "0 0 * * * /root/automation.sh" > /etc/cron.d/automation

fi
