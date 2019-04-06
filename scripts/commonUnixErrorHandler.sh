#############################################################################################
#
# Description:This script will be used for notifying common error that occurs in unix command 
# execution; like copy,move and etc
# Created by :Kathiravan Udayakumar (Cognizant) - v43670
# Date:09-23-2008
#
#############################################################################################

ApplicationName="fndintg"
ComponentName="FileMovementUtility"
fmcfgfilename=$1
errfname=$2
ApplicationEventCode=$3
BusinessObjectName=$4
PerceivedSeverity=$5
ClassName=$6
ContextId=$7
AdditionalData=$8
ErrorStr=$9
HostName=$HOSTNAME
ThreadId=$$
LoginUserId=`who am i | cut -f 1 -d" "`
DateTimeFormat=`date +"on %c"`
ShortDescription="Failed to complete file movement configured in $fmcfgfilename that was executed $DateTimeFormat"
scriptdir="/opt/schneider/applications/INTGFoundation/scripts"
ITEventsScript="/opt/schneider/applications/SNIExtensions/SNIJavaExtensionsResources/scripts/itevents/createEvents.sh"

ErrCodes="No such file or directory,config file not found,TARGET FILE ALREADY PRESENT" 

Count=1
eachErrorCode="NULL"

while [ "$eachErrorCode" != "" ]
do
	eachErrorCode=`echo $ErrCodes | cut -f $Count -d","`
	if [ "$eachErrorCode" != "" ]
	then
		if [ "$errfname" != "" ]
		then
		ErrorStr="NULL"
		ErrorStr=`grep -i "$eachErrorCode" $errfname`
		fi
	case $ErrorStr in
		*"No such file or directory"*)
			LongDescription="Unable to copy the file from location specified (file not present) in $fmcfgfilename filemovement configuration file."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			errorflag="1"
			echo "errorstatus=1" | cat >>$errfname
			break
			;;
		*"config file not found"*)
			LongDescription="Specified $fmcfgfilename filemovement configuration file not present"
			EventData="Specified $fmcfgfilename filemovement configuration file not present"			
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			errorflag="1"
			echo "errorstatus=1" | cat >>$errfname
			break
			;;
		*"TARGET FILE ALREADY PRESENT"*)
			LongDescription="Target file Specified in $fmcfgfilename filemovement configuration is already present"
			EventData="Target file Specified in $fmcfgfilename filemovement configuration is already present"			
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			errorflag="1"
			echo "errorstatus=1" | cat >>$errfname
			break
			;;
	esac
fi
Count=`expr $Count + 1`
done

if [ "$errorflag" != "1" ]
then
	echo "currenterrorstatus=0" | cat >>$errfname
fi