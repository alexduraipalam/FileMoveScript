#############################################################################################
#
# Description: This script will be used to extract details from file moevements configuration. 
# 		 file and call file movement script
# Created by : Kathiravan Udayakumar (Cognizant) - v43670
# 
#############################################################################################

cfgfilepath=/opt/schneider/applications/INTGFoundation/config/filemovement
tempdir=/var/schneider/applications/INTGFoundation/filemovement/data/working
pphfilepath=/var/schneider/applications/INTGFoundation/encryption/passphrases            
pswdcfgfile=/opt/schneider/applications/INTGFoundation/config/filemovement/snifmpswdcfg.cfg
pgpcmd="/usr/bin/gpg --batch --armor"
logdir="/var/schneider/applications/INTGFoundation/filemovement/logs"
scriptdir="/opt/schneider/applications/INTGFoundation/scripts"

datetime=`date +"%y-%m-%d-%H-%M-%S-%N"`
log="RunFileMoves_""$datetime".log

logrollperiod=30 #30 days older files will be deleted.
runfilemovesexitstatus="0"

# getting script options
OPTIND=1
debugopt=""
while getopts d: debugchoice
do 
	case $debugchoice in
	d) debugopt="debug"
	   echo debug option $debugopt
	;;
	esac
done
OPTIND=1

echo entering into runfilemoves.sh script
echo entering into runfilemoves.sh script >>$logdir/$log

for eachcfgfile
do
cfgfnamefchar=`expr substr $eachcfgfile 1 1`
if [ "$cfgfnamefchar" != "-" ]
then	
	echo "running $eachcfgfile configuration"
	echo "running $eachcfgfile configuration" >>$logdir/$log
	fmcfgcheck=""	
	ls $cfgfilepath/$eachcfgfile >>$logdir/$log
	fmcfgcheck=$?	
	if [ "$fmcfgcheck" != "1" ]
	then
		configfilenamealone=`echo $eachcfgfile | cut -f 1 -d"."`
		dyndatetime=`date +"%y-%m-%d-%H-%M-%S-%N"`
		dynlog="${configfilenamealone}_${dyndatetime}".log		
		$scriptdir/fileMovement.sh $cfgfilepath/$eachcfgfile $tempdir $pswdcfgfile "$pgpcmd" $pphfilepath $logdir $scriptdir $debugopt >$logdir/$dynlog 2>&1
		filemovementexitstatus=$?
		echo "filemovement exitstatus in runfilemoves" $filemovementexitstatus
		echo "filemovement exitstatus in runfilemoves" $filemovementexitstatus >>$logdir/$log
		if [ "$runfilemovesexitstatus" = "0" ]
		then
		   runfilemovesexitstatus=$filemovementexitstatus
		fi
		echo "Completed running $eachcfgfile filemovement configuration; check $dynlog log for more details about this run"
		echo "Completed running $eachcfgfile filemovement configuration; check $logdir/$dynlog log for more details about this run" >>$logdir/$log
	else
		echo specified configuration $eachcfgfile not present
		$scriptdir/commonUnixErrorHandler.sh "$eachcfgfile" "" "B2B_FND_FMCFG_FILE_ERROR" "" "30" "runFileMovies.sh" "ContextID" "AdditionalDetails" "config file not found" >>$logdir/$log 2>&1
		runfilemovesexitstatus=1
	fi
fi
done

echo "runfilemoves exitstatus" $runfilemovesexitstatus
echo "runfilemoves exitstatus" $runfilemovesexitstatus >>$logdir/$log

echo "exit from runfilemoves.sh script"
echo "exit from runfilemoves.sh script" >>$logdir/$log

exit "$runfilemovesexitstatus"