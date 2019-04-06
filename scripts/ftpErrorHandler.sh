#############################################################################################
#
# Description:This script will be used to create pgp related event in Event Management System 
# Created by :Kathiravan Udayakumar (Cognizant) - v43670
# Created Date:09-23-2008
# Updated Date:02-05-2009 
#############################################################################################

ApplicationName="fndintg"
ComponentName="FileMovementUtility"
cfgfname=$1
errfname=$2
ApplicationEventCode=$3
BusinessObjectName=$4
PerceivedSeverity=$5
ClassName=$6
ContextId=$7
AdditionalData=$8
HostName=$HOSTNAME
ThreadId=$$
LoginUserId=`who am i | cut -f 1 -d" "`
DateTime=`date +"on %c"`
ShortDescription="Failed to complete file movement configured in $cfgfname that was executed $DateTime"
scriptdir="/opt/schneider/applications/INTGFoundation/scripts"
ITEventsScript="/opt/schneider/applications/SNIExtensions/SNIJavaExtensionsResources/scripts/itevents/createEvents.sh"

ErrorCodes="unknown host,Login failed.,Connection refused,Not connected,Permission denied,NO BATCHES FOR TRANSMISSION,FILE NOT FOUND,TARGET FILE ALREADY PRESENT"

Count=1
eachErrorCode="NULL"
ErrorStr="NULL"

errorflag=""

while [ "$eachErrorCode" != "" ]
do
	eachErrorCode=`echo $ErrorCodes | cut -f $Count -d","`
	if [ "$eachErrorCode" != "" ]
	then
	ErrorStr=`grep -i "$eachErrorCode" $errfname`
	case $ErrorStr in		 
		*"unknown host"*)
			LongDescription="Unknown Host or Unable to connect to FTP Site configured in $cfgfname filemovement configuration file."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;
		*"Login failed"*)
			LongDescription="Unable to connect to FTP Site configured in $cfgfname filemovement configuration file due to incorrect login id or password."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;
		*"Permission denied"*)
			LongDescription="This issue could be basecuase 1.Unable to change directory in FTP Site configured in $cfgfname filemovement configuration file due to incorrect directory path or permission is denied for the path/file you are tyring to write."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;
		*"NO BATCHES FOR TRANSMISSION"*)
			LongDescription="In $cfgfname filemovement configuration file; Specified FTP (bin/ascii) mode is incorrect or Specified File  is not available for transmission or Specified file not present in FTP Site."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"FILE NOT FOUND"*)
			LongDescription="In $cfgfname filemovement configuration file; Specified file/files are not available for transmission or Specified file/files are not present in FTP Site."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"Connection refused"*)
		 	LongDescription="Connection refused by FTP site configured in $cfgfname filemovement configuration file."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;
		*"Not connected"*)
		 	LongDescription="Unable to connect to FTP site configured in $cfgfname filemovement configuration file."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;
		*"TARGET FILE ALREADY PRESENT"*)
			LongDescription="TARGET FILE ALREADY PRESENT in the FTP Server configured in $cfgfname filemovement configuration file.We also see Override Target is set to No"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
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