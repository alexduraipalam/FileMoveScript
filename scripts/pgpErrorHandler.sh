#############################################################################################
#
# Description:This script will be used to create pgp related event in Event Management System 
# Created by :Kathiravan Udayakumar (Cognizant) - v43670
# Date:09-25-2008
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
HostName=$HOSTNAME
ThreadId=$$
LoginUserId=`who am i | cut -f 1 -d" "`
DateTimeFormat=`date +"on %c"`
ShortDescription="Failed to complete file movement configured in $fmcfgfilename that was executed $DateTimeFormat"
scriptdir="/opt/schneider/applications/INTGFoundation/scripts"
ITEventsScript="/opt/schneider/applications/SNIExtensions/SNIJavaExtensionsResources/scripts/itevents/createEvents.sh"

LongDescription="PGP Action Failed"
EventData=`cat $errfname`
EventData="Error Details: $EventData Additional Details: $AdditionalData"
$ITEventsScript "-applicationEventCode:$ApplicationEventCode" "-shortDescription:$ShortDescription" "-perceivedSeverity:$PerceivedSeverity" "-applicationName:$ApplicationName" "-componentName:$ComponentName" "-hostName:$HostName" "-threadId:$ThreadId" "-contextId:$ContextId" "-createUserId:$LoginUserId" "-eventData:$EventData" "-longDescription:$LongDescription" "-businessObjectName:$BusinessObjectName" "-className:$ClassName"
