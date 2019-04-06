#############################################################################################
#
# Description:This script will be used to create SFTP related errors in Event Management System 
# Created by :Kathiravan Udayakumar (Cognizant) - v43670
# Date:01-15-2008
#
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

ErrorCodes="FILE NOT FOUND,Host key verification failed,is not allowed to run sudo,Permission denied,Couldn't read packet: Connection reset by peer,Couldn't rename file,TARGET FILE ALREADY PRESENT,Killed by signal 1,Failure"

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
		*"Host key verification failed"*)
			LongDescription="In $cfgfname filemovement configuration file; Host key verification failed,unable to login to SFTP site"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"Couldn't read packet: Connection reset by peer"*)
			LongDescription="In $cfgfname filemovement configuration file; Couldn't read packet: Connection reset by peer,Error in connecting to SFTP site or error in execuring the SFTP command"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"Permission denied"*)
			LongDescription="In $cfgfname filemovement configuration file; Permission denied Error; Unauthorized Key for target server; Please check if the Public key of the given key pair is available in authorized_keys file of target server under specified user /export/home/<specific user>/.ssh directory"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"FILE NOT FOUND"*)
			LongDescription="In $cfgfname filemovement configuration file; Specified file/files are not available for transmission or Specified file/files are not present in SFTP Site."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;		
		*"is not allowed to run sudo"*)
			LongDescription="In $cfgfname filemovement configuration file; oracle does not have sudo access to specified user"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"Couldn't rename file"*)		
			LongDescription="In $cfgfname filemovement configuration file; Unable to override the target file. File with specified name in config file or source system is already present in target"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break 
		;;
		*"TARGET FILE ALREADY PRESENT"*)
			LongDescription="In $cfgfname filemovement configuration file; Unable to override the target file. File with specified name in config file or source system is already present in target"
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;	
            *"Killed by signal 1"*)
			LongDescription="Error due to Killed by signal 1 in the SFTP Server configured in $cfgfname filemovement configuration file."
			EventData=`cat $errfname`
			EventData="Error Details: $EventData Additional Details: $AdditionalData"
			$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
			echo "errorstatus=1" | cat >>$errfname
			errorflag="1"
		break
		;;
            *"Failure"*)
			LongDescription="Failure in the SFTP Server configured in $cfgfname filemovement configuration file."
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