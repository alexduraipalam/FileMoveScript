###################################################################################
#
# Description:This script will be used to extract details from file movement configuration and complete the actions specified in the configuration.
# Created by :Kathiravan Udayakumar (Cognizant) - v43670
# Date:08-28-2008
#
###################################################################################

#-----------------------------------------------------------------------------------------------#
# Declaring variables and assigning default values	  		        		#
#-----------------------------------------------------------------------------------------------#

#setting input arguments to variable
cfgfname=$1 tempdir=$2 pswdcfgfname=$3 pgpcmd=$4 pphdir=$5 logdir=$6 scriptdir=$7 loglevel=$8

#defaulting common variables to blank
count="" key="" value="" filesize="" filemovementscriptexitstatus="" originaltempdir=""

#defaulting source and target ftp variables to blank
srclocationtype="" srcserver="" srclocation="" srcfilename="" srcuserid="" srcpassword="" srcauthtype="" srcpassphrase="" srcpassphrasefile="" srcsftpport="" srcsftpportcmd="" srcsftptimeout=""
deleteafterprocessing="" erroronfilenotfound="" privatekeyfile=""  
tgtlocationtype="" tgtserver="" tgtlocation="" tgtfilename="" tgtuserid="" tgtpassword="" tgtauthtype="" tgtpassphrase="" tgtpassphrasefile="" tgtmode="" ovrtgtfile="" tgtsftpport="" tgtsftpportcmd="" tgtwriteorgfilename="" tgtsftptimeout=""

#action related variables to be defaulted to blank
grpcount="" grpkey="" pgpaction="" pgptpkey="" pgpnewtpkey="" pgpsnikey="" pgpnewsnikey="" pgppphfile="" pgpinputfile=""pgpoutputfile="" pgpsniappendcmd="" pgpAdvancedOptions="" pgptextmode="" pgpverbosemode=""

#variables realted to file meta character search
testtgtfname="" metacharstartindex="" tgtfilenamefirstpart="" tgtfilenamesecondpart="" fileappender="" 
seplength="" finallength="" 


#getting configuration file name from complete filepath
cfgfnamealonewithextn=`echo $cfgfname | cut -f 8 -d"/"` 
cfgfnamealone=`echo $cfgfnamealonewithextn | cut -f 1 -d"."`

#setting date format variables
currentdatetime=`date +"%y-%m-%d-%H-%M-%S-%N"`
currentdate=`date +"%m_%d_%y"`
currenttime=`date +"%H_%M_%S"`

filemovementscriptexitstatus=0;

#setting temp files and ftp/pgp log files;
tempinputfilename="tempInputFile_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".dat"
srcreadlog="srcftpreadlog_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".log"
srcdecryptlog="srcdecryptlog_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".log"
srcdellog="srcftpdellog_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".log"
tgtwritelog="tgtftpwritelog_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".log"
tgtdecryptlog="tgtdecryptlog_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".log"
pgperrlog="pgperrlog_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".log" 
tempoutputfilename="tempOutputFile_""$cfgfnamealone""_filemovement_configuration_$currentdatetime"".dat"
userid=`who am i | cut -f 1 -d" "`

currentdatetime=`date +"%m_%d_%y_%H_%M_%S"`
echo "Entering filemovement script for $cfgfnamealonewithextn at " $currentdatetime

#conditional check variables are set to blank - clearing flag variables from pervious run
ftpexitstatus="" pgpresult="" tgtfilecreatedflag="" temptgtfilename=""

#grepping Document Type Details
doctypename=`grep -i 'DocTypeName' $cfgfname | cut -f 2 -d"="`

#grepping src, action, tgt details separately
srcdetails=`grep -i 'SourceDetails' $cfgfname`
actdetails=`grep -i 'Actions' $cfgfname`
tgtdetails=`grep -i 'TargetDetails' $cfgfname`

#defaulting src ftp mode to binary
srcmode="binary"

#change directory to temporary path
curdir=`pwd`
originaltempdir=$tempdir;
cd $tempdir
mkdir $tempdir/"$cfgfnamealone""$$"
tempdir=$tempdir/"$cfgfnamealone""$$"
cd $tempdir

#creating temp input directory and changing input directory
mkdir $tempdir/input
tempinputdir="$tempdir/input"
mkdir $tempdir/output
tempoutputdir="$tempdir/output"

#Init Default encryption related ( pass phrase file,classpath etc)
defaultpassphrase=`cat $pphdir/default.txt`
EXT_CLASSPATH={$CLASSPATH}:/opt/schneider/applications/SOAFoundation/lib/FndIntgSoaExtensions.jar:/opt/oracle/middleware/soa/oui/jlib/jlib/jsse.jar:/opt/oracle/soa/bpel/lib/j2ee_1.3.01.jar:/opt/oracle/middleware/soa/soa/modules/oracle.soa.bpel_11.1.1/orabpel-common.jar
export SNIValueEncodeDecode=true
export JAVA_ENCRYPT_HOME=/opt/oracle/jrmc/bin/java
#-----------------------------------------------------------------------------------------------#
#Grepping Source Details and  Get files to working directory -  Starts				#
#-----------------------------------------------------------------------------------------------#
echo "Getting Source Details"
#grepping source details to variables.
count=1
key="null"
erroronfilenotfound="y"
srcdetailsline=`grep -i 'SourceDetails' $cfgfname | cut -f 2 -d"="| cut -f 2 -d"[" | cut -f 1 -d"]"`
while [ "$key" != "" ]
do
	key=`echo $srcdetailsline | cut -f $count -d"|" | cut -f 1 -d":"`
	value=`echo $srcdetailsline | cut -f $count -d"|" | cut -f 2 -d":"`
	case $key in
		LocationType)
			srclocationtype=$value
			;;
		ServerName)
			srcserver=$value
			;;
		Location)
			srclocation=$value
			;;
		FileName)
			srcfilename=$value
			;;
		Userid)
			srcuserid=$value
			;;
		AuthType)
			srcauthtype=$value
			;;
		PassPhrase)
			srcpassphrasefile=$value
			;;
		SftpPort)
			srcsftpport=$value
			;;
		SftpTimeout)
			srcsftptimeout=$value
			;;
		DeleteAfterProcessing)
			deleteafterprocessing=$value
			;;
		Mode)
			srcmode=$value
			;;
		ErrorOnFileNotFound)
			erroronfilenotfound=$value
			;;
		PrivateKeyFile)
			srcprivatekeyfile=$value
			;;
		*)
			;;
	esac
	count=`expr $count + 1` 
done

#getting source password from password configuration file.
echo "Getting Source FTP Password"
srcpassword=`grep -i $srcserver:$srcuserid $pswdcfgfname | cut -f 3 -d":"`
$JAVA_ENCRYPT_HOME -cp {$EXT_CLASSPATH} sni.foundation.soa.util.EncryptDecryptUtil decrypt "$srcpassword" "$defaultpassphrase" Value[ ]Value > $logdir/$srcdecryptlog
srcpassword=`grep "Value\[" $logdir/$srcdecryptlog | cut -f 1 -d"]" | cut -f 2 -d"["`
rm $logdir/$srcdecryptlog
#this is done to avoid the script not to wait for password if the password is not provided in password configuration file.
if [ "$srcpassword" = "" ]
then
	srcpassword="dummy"
fi

if [ "$srcauthtype" = "" ]
then
	srcauthtype="KEY"
fi

if [ "$srcsftptimeout" = "" ]
then
	srcsftptimeout="10"
fi

#this is to default sftp port to 22
if [ "$srcsftpport" = "" ]
then
	srcsftpportcmd=""
else
      srcsftpportcmd="-oPort=$srcsftpport"
fi

#Expect changes starts
if [ "$srcauthtype" = "PASSWORD" ]
then

 CLASSPATH={$CLASSPATH}:/opt/schneider/applications/SOAFoundation/lib/xref.jar
 export CLASSPATH
 #echo {$CLASSPATH}
 srcpassphrase=`cat $pphdir/$srcpassphrasefile`
 export SNIValueEncodeDecode=true
 #/opt/oracle/soa/jdk/bin/java -cp {$CLASSPATH} sni.foundation.soa.util.EncryptDecryptUtil decrypt "$srcpassword" "$srcpassphrase" Value[ ]Value > $srcdecryptlog
 $JAVA_ENCRYPT_HOME sni.foundation.soa.util.EncryptDecryptUtil decrypt "$srcpassword" "$srcpassphrase" Value[ ]Value > $logdir/$srcdecryptlog
 srcpassword=`grep "Value\[" $logdir/$srcdecryptlog | cut -f 1 -d"]" | cut -f 2 -d"["`
 rm $logdir/$srcdecryptlog
fi
#Expect changes ends


#echoing source details.
echo ........... Source Details ...........
echo locationtype ${srclocationtype}
echo server ${srcserver}
echo location ${srclocation}
echo filename ${srcfilename}
echo userid ${srcuserid}		
echo mode ${srcmode}
echo delete after processing ${deleteafterprocessing}
echo error on file not found ${erroronfilenotfound}
echo ......................................

if [ "$erroronfilenotfound" = "Y" -o "$erroronfilenotfound" = "yes" -o "$erroronfilenotfound" = "Yes" -o "$erroronfilenotfound" = "YES" ]
then
	erroronfilenotfound="y"
fi

if [ "$deleteafterprocessing" = "Y" -o "$deleteafterprocessing" = "yes" -o "$deleteafterprocessing" = "Yes" -o "$deleteafterprocessing" = "YES" ]
then
	deleteafterprocessing="y"
fi



cd $tempinputdir
#getting file from source location.
if [ "$srclocationtype" = "FTP" ]
then
	echo "Connecting to Source FTP"
	ftp -n -i $srcserver > $logdir/$srcreadlog <<SCRIPT
	user $srcuserid $srcpassword
	cd $srclocation
	$srcmode
	mget $srcfilename 
	quit
SCRIPT

#changing to root temp directory
cd $tempdir

	$scriptdir/ftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_FTP_ERROR" "$doctypename" "30" "fileMovement.sh" "ReadfromSource" "$srcdetails"
	ftpexitstatus=`grep -i "errorstatus" $logdir/$srcreadlog | cut -f 2 -d"="`	

	if [ "$ftpexitstatus" = "1" ]
	then		
		echo Error in Source FTP site
		echo ........Source Read Log Details.......
		echo `cat $logdir/$srcreadlog`
		echo ......................................
		filemovementscriptexitstatus=1;
	fi

	nofilesfromftp=`ls -ltr $tempinputdir/$srcfilename | wc -l`
	if [ "$nofilesfromftp" = "0" -a "$ftpexitstatus" != "1" ]
	then		
		ftpexitstatus="1"
		echo "Error in Source FTP site"
		echo "Specified file/files are not present in FTP for tranmission"
		echo "FILE NOT FOUND" | cat >>$logdir/$srcreadlog
		echo ........Source Read Log Details....... 
		echo `cat $logdir/$srcreadlog`				
		if [ "$erroronfilenotfound" = "y" ] 
		then
			echo "Triggering Event for file not found error"
			echo "currenterrorstatus=1" | cat >>$logdir/$srcreadlog
			echo ......................................			
			$scriptdir/ftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_FTP_ERROR" "$doctypename" "30" "fileMovement.sh" "ReadfromSource" "$srcdetails"
			filemovementscriptexitstatus=1;
		fi
	else
		echo File/Files Copied from Source FTP site
		
	fi	

	rm $logdir/$srcreadlog
fi

if [ "$srclocationtype" = "SFTP" -a "$srcauthtype" = "KEY" ]
then
	echo "Connecting to Source SFTP"	
	if [ "$srcprivatekeyfile" = "" ] 
	then
	identityfileoption=""
	else
	identityfileoption="-oIdentityFile=$srcprivatekeyfile"
	echo $identityfileoption
	fi	
	#sftp -oBatchMode=yes $identityfileoption $srcuserid@$srcserver >$logdir/$srcreadlog 2>&1 <<SCRIPT
      sftp $srcsftpportcmd -oBatchMode=yes $identityfileoption $srcuserid@$srcserver >$logdir/$srcreadlog 2>&1 <<SCRIPT
	cd  $srclocation
	get $srcfilename $tempinputdir
	quit
SCRIPT
	$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_SFTP_ERROR" "$doctypename" "30" "fileMovement.sh" "ReadfromSource" "$srcdetails"
	ftpexitstatus=`grep -i "errorstatus" $logdir/$srcreadlog | cut -f 2 -d"="`	

	if [ "$ftpexitstatus" = "1" ]
		then		
		echo Error in Source SFTP site
		echo ........Source Read Log Details.......
		echo `cat $logdir/$srcreadlog`
		echo ......................................
		filemovementscriptexitstatus=1;
	fi	
	
	nofilesfromsftp=`ls -ltr $tempinputdir/$srcfilename | wc -l`
	if [ "$nofilesfromsftp" = "0" -a "$ftpexitstatus" != "1" ]
	then		
		ftpexitstatus="1"
		echo "Error in Source SFTP site"
		echo "Specified file/files are not present in SFTP for tranmission"
		echo "FILE NOT FOUND" | cat >>$logdir/$srcreadlog
		echo ........Source Read Log Details....... 
		echo `cat $logdir/$srcreadlog`				
		if [ "$erroronfilenotfound" = "y" ] 
		then
			echo "Triggering Event for file not found error"
			echo "currenterrorstatus=1" | cat >>$logdir/$srcreadlog
			echo ......................................			
			$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_SFTP_ERROR" "$doctypename" "30" "fileMovement.sh" "ReadfromSource" "$srcdetails"				
			filemovementscriptexitstatus=1;
		fi
	else
		echo File/Files Copied from Source SFTP site
		
	fi
	
	rm $logdir/$srcreadlog
fi

#Expect changes starts for Expect

if [ "$srclocationtype" = "SFTP" -a "$srcauthtype" = "PASSWORD" ]
then
	echo "Connecting to Source SFTP"	
	if [ "$srcprivatekeyfile" = "" ] 
	then
	identityfileoption=""
	else
	identityfileoption="-oIdentityFile=$srcprivatekeyfile"
	echo $identityfileoption
	fi	
      #sftp -oBatchMode=yes $identityfileoption $srcuserid@$srcserver >$logdir/$srcreadlog 2>&1 <<SCRIPT
      #cd  $srclocation
	#get $srcfilename $tempinputdir
	#quit
#SCRIPT
      expect $scriptdir/fileMovementSftpsource.exp "$srcuserid" "$srcserver" "$srcpassword" "$srcfilename" "$tempinputdir" "$srclocation" "$logdir/$srcreadlog" 1 "$srcsftpportcmd" "$srcsftptimeout"

	$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_SFTP_ERROR" "$doctypename" "30" "fileMovement.sh" "ReadfromSource" "$srcdetails"
	ftpexitstatus=`grep -i "errorstatus" $logdir/$srcreadlog | cut -f 2 -d"="`	

	if [ "$ftpexitstatus" = "1" ]
		then		
		echo Error in Source SFTP site
		echo ........Source Read Log Details.......
		echo `cat $logdir/$srcreadlog`
		echo ......................................
		filemovementscriptexitstatus=1;
	fi	
	
	nofilesfromsftp=`ls -ltr $tempinputdir/$srcfilename | wc -l`
	if [ "$nofilesfromsftp" = "0" -a "$ftpexitstatus" != "1" ]
	then		
		ftpexitstatus="1"
		echo "Error in Source SFTP site"
		echo "Specified file/files are not present in SFTP for tranmission"
		echo "FILE NOT FOUND" | cat >>$logdir/$srcreadlog
		echo ........Source Read Log Details....... 
		echo `cat $logdir/$srcreadlog`				
		if [ "$erroronfilenotfound" = "y" ] 
		then
			echo "Triggering Event for file not found error"
			echo "currenterrorstatus=1" | cat >>$logdir/$srcreadlog
			echo ......................................			
			$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_SFTP_ERROR" "$doctypename" "30" "fileMovement.sh" "ReadfromSource" "$srcdetails"				
			filemovementscriptexitstatus=1;
		fi
	else
		echo File/Files Copied from Source SFTP site
		
	fi
	
	rm $logdir/$srcreadlog
      
fi
#Expect changes ends

if [ "$srclocationtype" = "LFS" ]
then
	echo "In Local Path;copying files locally to a working directory"
	cp $srclocation/$srcfilename $tempinputdir 2> $logdir/$srcreadlog
	ftpexitstatus=$?
	cp $srclocation/$srcfilename $tempoutputdir 2> $logdir/$srcreadlog	
	echo srcreadstatus $ftpexitstatus	
	if [ "$ftpexitstatus" != "0" -a "$erroronfilenotfound" = "y" ]
	then
		echo Error in Local Source Location		
		$scriptdir/commonUnixErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$srcreadlog" "INTG_FND_SRC_LOCAL_ERROR" "$doctypename" "30" "filemovement.sh" "ReadfromSource" "$srcdetails"		
		filemovementscriptexitstatus=1;
	fi
	rm $logdir/$srcreadlog
fi

#-----------------------------------------------------------------------------------------------#
# Grepping Source Details and  Get files to working directory -  Ends	        		#
#-----------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------------------------#
# Grepping Target  details, Action details  and completing the actions - Starts  		#
#-----------------------------------------------------------------------------------------------#


#checking the ftp exit status before proceeding 
if [ "$ftpexitstatus" = "0" ]
then
	#defaulting src ftp mode to binary
	tgtmode="binary"

	#grepping target details to variables.	
	count=1
	key="null"	
	while [ "$key" != "" ]
	do
	key=`grep -i 'TargetDetails' $cfgfname | cut -f 2 -d"=" | cut -f $count -d"|" | cut -f 1 -d":" | cut -f 2 -d"["`
	value=`grep -i 'TargetDetails' $cfgfname | cut -f 2 -d"=" | cut -f $count -d"|" | cut -f 2 -d":" | cut -f 1 -d"]"`
	case $key in
		LocationType)
			tgtlocationtype=$value
			;;
		ServerName)
			tgtserver=$value
			;;
		Location)
			tgtlocation=$value
			;;
		FileName)	
			tgtfilename=$value
			;;
		Userid)
			tgtuserid=$value
			;;
		AuthType)
			tgtauthtype=$value
			;;
		PassPhrase)
			tgtpassphrasefile=$value
			;;
            SftpPort)
			tgtsftpport=$value
			;;
		SftpTimeout)
			tgtsftptimeout=$value
			;;
            WriteWithOriginalName)
			tgtwriteorgfilename=$value
			;;
		Mode)
			tgtmode=$value
			;;
		PrivateKeyFile)
			tgtprivatekeyfile=$value
			;;
		*)		
			;;
	esac
	count=`expr $count + 1` 
	done

	#Getting target password from password configuration file.	
	tgtpassword=`grep -i $tgtserver:$tgtuserid $pswdcfgfname | cut -f 3 -d":"`
	$JAVA_ENCRYPT_HOME  -cp {$EXT_CLASSPATH} sni.foundation.soa.util.EncryptDecryptUtil decrypt "$tgtpassword" "$defaultpassphrase" Value[ ]Value > $logdir/$srcdecryptlog
        tgtpassword=`grep "Value\[" $logdir/$srcdecryptlog | cut -f 1 -d"]" | cut -f 2 -d"["`
        rm $logdir/$srcdecryptlog
	#this is done to avoid the script not to wait for password if the password is not provided in password configuration file.
	if [ "$tgtpassword" = "" ]
	then
		tgtpassword="dummy"
	fi

      if [ "$tgtauthtype" = "" ]
      then
	   tgtauthtype="KEY"
      fi

      if [ "$tgtsftptimeout" = "" ]
      then
	   tgtsftptimeout="10"
      fi

      #this is to default sftp port to 22
	if [ "$tgtsftpport" = "" ]
	then
		tgtsftpportcmd=""
      else
            tgtsftpportcmd="-oPort=$tgtsftpport"
	fi
      if [ "$tgtwriteorgfilename" = "" ]
	then
		tgtwriteorgfilename="N"
	fi

      if [ "$tgtwriteorgfilename" = "y" -o "$tgtwriteorgfilename" = "yes" -o "$tgtwriteorgfilename" = "Yes" -o "$tgtwriteorgfilename" = "YES" ]
      then
	 tgtwriteorgfilename="Y"
      fi

      #Expect changes starts
      if [ "$tgtauthtype" = "PASSWORD" ]
      then
       #tgtpassword="jiAP/p0aIa8="
       #tgtpassphrase="password123"
       CLASSPATH={$CLASSPATH}:/opt/schneider/applications/SOAFoundation/lib/xref.jar
       export CLASSPATH
       export SNIValueEncodeDecode=true
       tgtpassphrase=`cat $pphdir/$tgtpassphrasefile`
       #/opt/oracle/soa/jdk/bin/java -cp {$CLASSPATH} sni.foundation.soa.util.EncryptDecryptUtil decrypt "$tgtpassword" "$tgtpassphrase" Value[ ]Value > $tgtdecryptlog
       $JAVA_ENCRYPT_HOME sni.foundation.soa.util.EncryptDecryptUtil decrypt "$tgtpassword" "$tgtpassphrase" Value[ ]Value > $logdir/$tgtdecryptlog
       tgtpassword=`grep "Value\[" $logdir/$tgtdecryptlog | cut -f 1 -d"]" | cut -f 2 -d"["`
       rm $logdir/$tgtdecryptlog
      fi      
      #Expect changes ends

	echo  ..........Target Details............ 
	echo locationtype ${tgtlocationtype}
	echo server ${tgtserver}
	echo location ${tgtlocation}
	echo filename ${tgtfilename}
	echo userid ${tgtuserid}		
	echo ......................................	
	
	storedtgtfilename=$tgtfilename

	#for each file we need to move 
	cd $tempinputdir
	for eachfile in `ls` 	
	do
	#-----------------------------------------------------------------------------------------------#
	# Replacing meta characters in target file name - Starts					#
	#-----------------------------------------------------------------------------------------------#
		
		#Replacing meta characters in target file name.
		
		temptgtfilename=""
		tgtfilename=$storedtgtfilename
		tempinputfilename=$eachfile
		isrcfilename=$eachfile		
		srcfilenamealone=`echo $eachfile | cut -f 1 -d"."`		
		metacharstartindex=`expr index $tgtfilename "#"`
		metachar="NULL"
		count=1
		

		#This is done to avoid loop end issue if # is first character and cutting with it results the first string to be blank.
		# This issue happens when #SRC_FILE_NAME# tags are used in target filenames.
		if [ "$metacharstartindex" = "1" ]
		then
			count=2
		fi		

		#Finding the  SRC_FILE_NAME_WITH_EXTN or SRC_FILE_NAME_WITH tag and replacing with source file name.
		if [ "$metacharstartindex" != "0" ]
		then
			while [ "$metachar" != "" ]
			do
				metachar=`echo "$tgtfilename" | cut -f $count -d"#"`
				case $metachar in 
					SRC_FILE_NAME)
						temptgtfilename="$temptgtfilename""$srcfilenamealone"
					;;
					SRC_FILE_NAME_WITH_EXTN)
						temptgtfilename="$temptgtfilename""$isrcfilename"
					;;
					*)
						temptgtfilename=$temptgtfilename$metachar
					;;
				esac
				count=`expr $count + 1`
			done
		else
			temptgtfilename=$tgtfilename
		fi	
		
		tgtfilename=$temptgtfilename
		temptgtfilename=""
		metachar="NULL"
		count=1
		metacharstartindex=`expr index $tgtfilename "@"`

		if [ "$metacharstartindex" = "1" ]
		then
			count=2
		fi

		#Finding the  Date formatting tag and replacing with date information as required
		if [ "$metacharstartindex" != "0" ]
		then
			while [ "$metachar" != "" ]
			do
				metachar=`echo "$tgtfilename" | cut -f $count -d"@"`
				case $metachar in
				*)
				formatteddate=`date +"$metachar"`
				temptgtfilename="$temptgtfilename""$formatteddate"				
				;;
				esac
				count=`expr $count + 1`
			done
		else 
			temptgtfilename=$tgtfilename
		fi	

	tgtfilename=$temptgtfilename		
		
	#-----------------------------------------------------------------------------------------------#
	# Replacing meta characters in target file name - Ends						#
	#-----------------------------------------------------------------------------------------------#
	
		#Copying input file to output directory to FTP it; send to local box if PGP encryption is not available.
		cp $tempinputdir/$eachfile $tempoutputdir/$tgtfilename
		
		#Getting Actions Details
		grpcount=1
		grpkey="null"	
		movedone=""
		while [ "$movedone" != "1" ]
		do
			grpkey=`grep -i "Actions" $cfgfname | cut -f 2 -d"{" | cut -f $grpcount -d"," | cut -f 1 -d"}"| cut -f 1 -d"="`			
			case $grpkey in
			PGP)
				rm -rf $tempoutputdir/*
				count=1
				key="null"
				while [ "$key" != "" ]
				do
					key=`grep -i "Actions" $cfgfname | cut -f 2 -d"{" | cut -f $grpcount -d"," | cut -f 1 -d"}" | cut -f 2 -d"=" | cut -f 2 -d"[" | cut -f $count -d"|" | cut -f 1 -d":" | cut -f 1 -d"]"`
					value=`grep -i "Actions" $cfgfname | cut -f 2 -d"{" | cut -f $grpcount -d"," | cut -f 1 -d"}" | cut -f 2 -d"=" | cut -f 2 -d"[" | cut -f $count -d"|" | cut -f 2 -d":" | cut -f 1 -d"]"`
					case $key in
					        Action)
					           pgpaction=$value
					                ;;
					        TPKey)
					           pgptpkey=$value
					                ;;
							NewTPKey)
					           pgpnewtpkey=$value
									;;
					        SNIKey)
					           pgpsnikey=$value
					                ;;
							NewSNIKey)
					           pgpnewsnikey=$value
					                ;;
					        PPHFILE)
					           pgppphfile=$pphdir/$value
					                ;;
				            TEXTMODE)
							pgptextmode=$value
							;;
							VERBOSE)
							pgpverbosemode=$value
							;;
					        *)
					        ;;
					esac					
					count=`expr $count + 1`
				done
				# Echoing pgp command details
				echo ........... Action Details ...........
				echo pgpcmd ${pgpcmd}
				echo pgpaction ${pgpaction}				
				if [ "$loglevel" = "debug" ]
				then		
					echo tpkey ${pgptpkey}
					echo snikey ${pgpsnikey}		
					echo newtpkey ${pgpnewtpkey}
					echo newsnikey ${pgpnewsnikey}
				fi	
				echo pphfile ${pgppphfile}			
				echo Override Target ${ovrtgtfile}					
				echo ......................................			
				pgpinputfile=$tempinputdir/$tempinputfilename
				pgpoutputfile=$tempoutputdir/$tgtfilename
				
				if [ "$pgpsnikey" != "" ]
				then
					pgpsniappendcmd=" -u ""$pgpsnikey"
				fi
				
				pgpAdvancedOptions=""
				
				if [ "$pgptextmode" = "true" ]
				then
				pgpAdvancedOptions=" --textmode " 
				fi
				if [ "$pgpverbosemode" = "true" ] 
				then
				pgpAdvancedOptions=$pgpAdvancedOptions" -v -v " 
				fi
				
				if [ "$pgpaction" = "ENCRYPT" ]
				then
					$pgpcmd --output $pgpoutputfile -r $pgptpkey $pgpAdvancedOptions --encrypt $pgpinputfile >$logdir/$pgperrlog 2>&1
				elif [ "$pgpaction" = "DECRYPT" ]
				then
					$pgpcmd --output $pgpoutputfile $pgpAdvancedOptions --decrypt --verbose --passphrase-file $pgppphfile $pgpinputfile >$logdir/$pgperrlog 2>&1
				elif [ "$pgpaction" = "SIGN" ]
				then
					$pgpcmd --output $pgpoutputfile $pgpsniappendcmd $pgpAdvancedOption  --passphrase-file $pgppphfile --sign $pgpinputfile >$logdir/$pgperrlog 2>&1
				elif [ "$pgpaction" = "SIGNENCRYPT" ]
				then
					$pgpcmd --output $pgpoutputfile $pgpsniappendcmd -r $pgptpkey -se  $pgpAdvancedOptions --passphrase-file $pgppphfile $pgpinputfile >$logdir/$pgperrlog 2>&1
				fi
				
				pgpresult=$?
				echo ........PGP Execution Details - First Try.......
				echo "PGP result" $pgpresult
				echo `cat $logdir/$pgperrlog`
				echo .................................................
				
				if [ "$pgpresult" != "0" ]
				then					
					echo .................................................
					echo Retrying PGP Action with New Key					
					echo .................................................
					if [ "$pgpnewsnikey" != "" ]
					then
						pgpnewsniappendcmd=" -u ""$pgpnewsnikey"
					else 
						pgpnewsniappendcmd=""
					fi					
					if [ "$pgpaction" = "ENCRYPT" -a "$pgpnewtpkey"!="" ]
					then
						$pgpcmd --output $pgpoutputfile -r $pgpnewtpkey $pgpAdvancedOptions --encrypt $pgpinputfile >$logdir/$pgperrlog 2>&1
						pgpresult=$?
					elif [ "$pgpaction" = "DECRYPT" ]
					then
						$pgpcmd --output $pgpoutputfile $pgpAdvancedOptions --decrypt --verbose --passphrase-file $pgppphfile $pgpinputfile >$logdir/$pgperrlog 2>&1
						pgpresult=$?
					elif [ "$pgpaction" = "SIGN" ]
					then
						$pgpcmd --output $pgpoutputfile $pgpnewsniappendcmd $pgpAdvancedOption  --passphrase-file $pgppphfile --sign $pgpinputfile >$logdir/$pgperrlog 2>&1
						pgpresult=$?
					elif [ "$pgpaction" = "SIGNENCRYPT" -a "$pgpnewtpkey" != "" ]
					then
						$pgpcmd --output $pgpoutputfile $pgpnewsniappendcmd -r $pgpnewtpkey -se  $pgpAdvancedOptions --passphrase-file $pgppphfile $pgpinputfile >$logdir/$pgperrlog 2>&1
						pgpresult=$?
					fi				
										
					filesize=`ls -ltr $logdir/$pgperrlog | cut -f 6 -d" "`					
										
					echo ........PGP Execution Details - Second Try.......
					echo "PGP result" $pgpresult
					echo `cat $logdir/$pgperrlog`			
					echo .................................................
				fi;
				
				if [ "$pgpresult" != "0" ]
				then
					echo PGPError					
					$scriptdir/pgpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$pgperrlog" "INTG_FND_PGP_ACTION_ERROR" "$doctypename" "30" "filemovement.sh" "ExecutingPGPAction" "$actdetails"										
					filemovementscriptexitstatus=1;
				fi
				
				filesize=`ls -ltr $logdir/$pgperrlog | cut -f 6 -d" "`
				
				if [ $filesize != "" ] 
				then
					rm $logdir/$pgperrlog
				fi

				if [ "$pgpresult" = "0" -o  "$pgpresult" = "" ]
				then
					echo PGP Action Completed
				fi
				
				echo PGP Action Result $pgpresult
				echo ......................................
			;;
			Move)
				count=1
				key="null"
				key=`grep -i "Actions" $cfgfname | cut -f 2 -d"{" | cut -f $grpcount -d"," | cut -f 1 -d"}" | cut -f 2 -d"=" | cut -f 2 -d"[" | cut -f $count -d"|" | cut -f 1 -d":" | cut -f 1 -d"]"`
				value=`grep -i "Actions" $cfgfname | cut -f 2 -d"{" | cut -f $grpcount -d"," | cut -f 1 -d"}" | cut -f 2 -d"=" | cut -f 2 -d"[" | cut -f $count -d"|" | cut -f 2 -d":" | cut -f 1 -d"]"`
				case $key in
					OverrideTargetFile)
					ovrtgtfile=$value
					echo ..............Move Details..........
					echo OverrideTargetFile $ovrtgtfile
					echo ....................................
					if [ "$ovrtgtfile" = "Y" -o "$ovrtgtfile" = "yes" -o "$ovrtgtfile" = "Yes" -o "$ovrtgtfile" = "YES" ]
					then
						ovrtgtfile="y"
					fi
					if [ "$pgpresult" = "0" -o  "$pgpresult" = "" ]
					then
						cd $tempoutputdir
						# Pushing file to target loation
						if [ "$tgtlocationtype" = "FTP" ]
						then									
							echo "Connecting to Target FTP"
                                         if [ "$tgtwriteorgfilename" = "Y" ]
                                         then
							ftp -n -i $tgtserver > $logdir/$tgtwritelog <<SCRIPT
							user $tgtuserid $tgtpassword 
							cd $tgtlocation
							$tgtmode
							$ftpdelcmdforovrtgtfile
                                          put $tgtfilename $tgtfilename
							quit
SCRIPT
                                         fi
                                         if [ "$tgtwriteorgfilename" = "N" ]
                                         then
                                          ftp -n -i $tgtserver > $logdir/$tgtwritelog <<SCRIPT
							user $tgtuserid $tgtpassword 
							cd $tgtlocation
							$tgtmode
							$ftpdelcmdforovrtgtfile
                                          put $tgtfilename temp_$tgtfilename
							rename temp_$tgtfilename $tgtfilename 
							quit
SCRIPT
                                         fi      
                                         

							$scriptdir/ftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_FTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
							ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`
							rm $logdir/$tgtwritelog
							if [ "$ftpexitstatus" = "1"  ]
							then
								echo Error in Target FTP site
								filemovementscriptexitstatus=1;
							fi
						fi
						
						if [ "$tgtlocationtype" = "SFTP" -a "$tgtauthtype" = "KEY" ]
						then
														
							if [ "$tgtprivatekeyfile" = "" ] 
							then
								identityfileoption=""
							else
								identityfileoption="-oIdentityFile=$tgtprivatekeyfile"							
							fi
							
							echo "Connecting to Target SFTP for checking target file status"
							sftp $tgtsftpportcmd -oBatchMode=yes $identityfileoption $tgtuserid@$tgtserver >$logdir/$tgtwritelog 2>&1 <<SCRIPT
							cd  $tgtlocation
							$sftpdelcmdforovrtgtfile
							dir $tgtfilename 							
							quit
SCRIPT
											
							echo `cat $logdir/$tgtwritelog`							
							sftptgtfilestatuserrstr=`grep -i "No such file or directory" $logdir/$tgtwritelog`
							sftp_tgt_file_exists_status="1"
							case $sftptgtfilestatuserrstr in
								*"No such file or directory"*)
									sftp_tgt_file_exists_status="0"								
								;;
							esac
							
							echo "target file exists status" $sftp_tgt_file_exists_status
							
							sftpdelcmdforovrtgtfile=""
							ftpexitstatus=""
							
							if [ "$ovrtgtfile" = "y" -a "$sftp_tgt_file_exists_status" = "1" ]
							then
								sftpdelcmdforovrtgtfile="rm $tgtfilename"								
							elif [ "$ovrtgtfile" = "y" -a "$sftp_tgt_file_exists_status" = "0" ]
							then
								sftpdelcmdforovrtgtfile=""
							elif [ "$ovrtgtfile" = "n" -a "$sftp_tgt_file_exists_status" = "1" ]
							then
								echo "TARGET FILE ALREADY PRESENT" | cat >>$logdir/$tgtwritelog
								$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_SFTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`
							elif [ "$ovrtgtfile" = "n" -a "$sftp_tgt_file_exists_status" = "0" ]
							then
								sftpdelcmdforovrtgtfile=""
							fi																	
														
							if [ "$ftpexitstatus" = "1"  ]
							then
								echo Error in Target SFTP site
								filemovementscriptexitstatus=1;
							else 
								$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_SFTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`
							fi
							
							rm $logdir/$tgtwritelog
                                          
							
							if [ "$ftpexitstatus" != "1"  ]
							then
								echo "Connecting to Target SFTP for moving the target file"	
                                                if [ "$tgtwriteorgfilename" = "Y" ]
                                                then
								sftp $tgtsftpportcmd -oBatchMode=yes $identityfileoption $tgtuserid@$tgtserver >$logdir/$tgtwritelog 2>&1 <<SCRIPT
								cd  $tgtlocation
								$sftpdelcmdforovrtgtfile
                                                 put $tgtfilename $tgtfilename
                                                quit
SCRIPT
                                                fi
                                                if [ "$tgtwriteorgfilename" = "N" ]
                                                then
								 sftp $tgtsftpportcmd -oBatchMode=yes $identityfileoption $tgtuserid@$tgtserver >$logdir/$tgtwritelog 2>&1 <<SCRIPT
								 cd  $tgtlocation
								 $sftpdelcmdforovrtgtfile
                                                 put $tgtfilename temp_$tgtfilename
								 rename temp_$tgtfilename $tgtfilename                    
                                                 quit
SCRIPT
                                                fi

								$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_SFTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`						
								
								echo ........Target Write Details.......
								echo `cat $logdir/$tgtwritelog`
								echo ...................................
								
								rm $logdir/$tgtwritelog
								if [ "$ftpexitstatus" = "1"  ]
								then
									echo Error in Target SFTP site
									filemovementscriptexitstatus=1;
								fi
							fi
						fi
						
                                    #Expect changes starts
                                    if [ "$tgtlocationtype" = "SFTP" -a "$tgtauthtype" = "PASSWORD" ]
						then
														
							if [ "$tgtprivatekeyfile" = "" ] 
							then
								identityfileoption=""
							else
								identityfileoption="-oIdentityFile=$tgtprivatekeyfile"							
							fi
							
							echo "Connecting to Target SFTP for checking target file status " $tgtlocation
							#sftp -oBatchMode=yes $identityfileoption $tgtuserid@$tgtserver >$logdir/$tgtwritelog 2>&1 <<SCRIPT
							#cd  $tgtlocation
							#$sftpdelcmdforovrtgtfile
							#dir $tgtfilename 							
							#quit
#SCRIPT
                                          expect $scriptdir/fileMovementSftptarget.exp "$tgtuserid" "$tgtserver" "$tgtpassword" "$tgtfilename" "$tgtlocation" "$logdir/$tgtwritelog" 1 "$sftpdelcmdforovrtgtfile" "$tgtsftpportcmd" "$tgtsftptimeout"
											
							echo `cat $logdir/$tgtwritelog`							
							sftptgtfilestatuserrstr=`grep -i "No such file or directory" $logdir/$tgtwritelog`
							sftp_tgt_file_exists_status="1"
							case $sftptgtfilestatuserrstr in
								*"No such file or directory"*)
									sftp_tgt_file_exists_status="0"								
								;;
							esac
							
							echo "target file exists status" $sftp_tgt_file_exists_status
							 #next 4 lines added as per dinesh mail from 10g changes.
							 if [ "$sftp_tgt_file_exists_status" = "1"  ]
						     then
								filemovementscriptexitstatus=1;
						     fi

							
							sftpdelcmdforovrtgtfile=""
							ftpexitstatus=""
							
							if [ "$ovrtgtfile" = "y" -a "$sftp_tgt_file_exists_status" = "1" ]
							then
								sftpdelcmdforovrtgtfile="rm $tgtfilename"								
							elif [ "$ovrtgtfile" = "y" -a "$sftp_tgt_file_exists_status" = "0" ]
							then
								sftpdelcmdforovrtgtfile=""
							elif [ "$ovrtgtfile" = "n" -a "$sftp_tgt_file_exists_status" = "1" ]
							then
								echo "TARGET FILE ALREADY PRESENT" | cat >>$logdir/$tgtwritelog
								$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_SFTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`
							elif [ "$ovrtgtfile" = "n" -a "$sftp_tgt_file_exists_status" = "0" ]
							then
								sftpdelcmdforovrtgtfile=""
							fi																	
														
							if [ "$ftpexitstatus" = "1"  ]
							then
								echo Error in Target SFTP site
								filemovementscriptexitstatus=1;
							else 
								$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_SFTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`
							fi
							
							rm $logdir/$tgtwritelog
							
							if [ "$ftpexitstatus" != "1"  ]
							then
								echo "Connecting to Target SFTP for moving the target file"	
								#sftp -oBatchMode=yes $identityfileoption $tgtuserid@$tgtserver >$logdir/$tgtwritelog 2>&1 <<SCRIPT
								#cd  $tgtlocation
								#$sftpdelcmdforovrtgtfile
								#put $tgtfilename temp_$tgtfilename
								#rename temp_$tgtfilename $tgtfilename
								#quit
#SCRIPT
                                                if [ "$tgtwriteorgfilename" = "Y" ]
                                                then
                                                  expect $scriptdir/fileMovementSftptarget.exp "$tgtuserid" "$tgtserver" "$tgtpassword" "$tgtfilename" "$tgtlocation" "$logdir/$tgtwritelog" 3 "$sftpdelcmdforovrtgtfile" "$tgtsftpportcmd" "$tgtsftptimeout"
                                                else
                                                  expect $scriptdir/fileMovementSftptarget.exp "$tgtuserid" "$tgtserver" "$tgtpassword" "$tgtfilename" "$tgtlocation" "$logdir/$tgtwritelog" 2 "$sftpdelcmdforovrtgtfile" "$tgtsftpportcmd" "$tgtsftptimeout"
                                                fi

                                                

								$scriptdir/sftpErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_SFTP_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`						
								
								echo ........Target Write Details.......
								echo `cat $logdir/$tgtwritelog`
								echo ...................................
								
								rm $logdir/$tgtwritelog
								if [ "$ftpexitstatus" = "1"  ]
								then
									echo Error in Target SFTP site
									filemovementscriptexitstatus=1;
								fi
							fi
						fi
                                    #Expect changes ends	

						if [ "$tgtlocationtype" = "LFS" ]
						then
							
							nofilesinlfs=`ls -ltr $tgtlocation/$tgtfilename | wc -l`
							lfs_tgt_file_exists_status="$nofilesinlfs"							
							
							echo "target file exists status" $lfs_tgt_file_exists_status
							
							lfsdelcmdforovrtgtfile=""
							ftpexitstatus=""
							
							if [ "$ovrtgtfile" = "y"  -a "$lfs_tgt_file_exists_status" = "1" ]
							then
								lfspdelcmdforovrtgtfile="rm $tgtfilename"
							elif [ "$ovrtgtfile" = "y"  -a "$lfs_tgt_file_exists_status" = "0" ] 
							then
								lfsdelcmdforovrtgtfile=""
							elif [ "$ovrtgtfile" = "n"  -a "$lfs_tgt_file_exists_status" = "1" ] 
							then
								echo "TARGET FILE ALREADY PRESENT" | cat >>$logdir/$tgtwritelog
								$scriptdir/commonUnixErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_LOCAL_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
								ftpexitstatus=`grep -i "errorstatus" $logdir/$tgtwritelog | cut -f 2 -d"="`
								lfsdelcmdforovrtgtfile=""
								filemovementscriptexitstatus=1;
								rm $logdir/$tgtwritelog
							elif [ "$ovrtgtfile" = "n"  -a "$lfs_tgt_file_exists_status" = "0" ] 
							then
								lfsdelcmdforovrtgtfile=""	
							fi							
							
							if [ "$ftpexitstatus" != "1" ]
							then 
								echo `$lfsdelcmdforovrtgtfile` >$logdir/$tgtwritelog 2>&1							
								cp $tempoutputdir/$tgtfilename $tgtlocation/$tgtfilename 2>$logdir/$tgtwritelog
								ftpexitstatus=$?
								
								echo tgtwritestatus $ftpexitstatus
								if [ "$ftpexitstatus" != "0" ]
									then
										echo Error in Local Target Location
										$scriptdir/commonUnixErrorHandler.sh "$cfgfnamealonewithextn" "$logdir/$tgtwritelog" "INTG_FND_TGT_LOCAL_ERROR" "$doctypename" "30" "filemovement.sh" "WriteToTarget" "$tgtdetails"
										filemovementscriptexitstatus=1;
								fi
								
								echo ........Target Write Details.......
								echo `cat $logdir/$tgtwritelog`
								echo ...................................
								
								rm $logdir/$tgtwritelog
							fi	
						fi
					fi
					movedone="1"
					if [ "$filemovementscriptexitstatus" != "1" ]
					then
						echo Move Completed - $eachfile file moved as $tgtfilename
					fi
				;;
				esac
				count=`expr $count + 1`
			;;
			esac
			grpcount=`expr $grpcount + 1`
		done
	done	
#-----------------------------------------------------------------------------------------------#
# Grepping Target  details, Action details  and completing the actions-Ends			#
#-----------------------------------------------------------------------------------------------#
	if [ "$filemovementscriptexitstatus" != "1" ]
	then
		if [ "$deleteafterprocessing" = "y" ]
		then			
			if [ "$srclocationtype" = "LFS" ]
			then
				echo removing source file from local directory
				rm $srclocation/$srcfilename -f
			fi
			
			if [ "$srclocationtype" = "FTP" ]
			then
				echo "Connecting to Source FTP for removing files after processing"
				ftp -n -i $srcserver > $logdir/$srcdellog <<SCRIPT
				user $srcuserid $srcpassword
				cd $srclocation
				$srcmode
				mdel $srcfilename 
				quit
SCRIPT
				echo ........Source Delete Log Details....... 
				echo `cat $logdir/$srcdellog`
				echo ......................................
				rm $logdir/$srcdellog
			fi
			
			if [ "$srclocationtype" = "SFTP" -a "$srcauthtype" = "KEY" ]
			then			
				echo "Connecting to Source SFTP for removing files after processing"
				sftp $srcsftpportcmd -oBatchMode=yes $identityfileoption $srcuserid@$srcserver >$logdir/$srcdellog 2>&1 <<SCRIPT
				cd  $srclocation
				rm $srcfilename
				quit
SCRIPT
				echo ........Source Delete Log Details....... 
				echo `cat $logdir/$srcdellog`
				echo ......................................
				rm $logdir/$srcdellog
			fi
#Expect changes starts
			if [ "$srclocationtype" = "SFTP" -a "$srcauthtype" = "PASSWORD" ]
			then			
				echo "Connecting to Source SFTP for removing files after processing"
				#sftp -oBatchMode=yes $identityfileoption $srcuserid@$srcserver >$logdir/$srcdellog 2>&1 <<SCRIPT
				#cd  $srclocation
				#rm $srcfilename
				#quit
#SCRIPT
				#changed from $srcreadlog to $srcdellog  as per Dinesh's mail from 10g changes.
				 expect $scriptdir/fileMovementSftpsource.exp "$srcuserid" "$srcserver" "$srcpassword" "$srcfilename" "$tempinputdir" "$srclocation" "$logdir/$srcdellog" 2 "$srcsftpportcmd" "$srcsftptimeout"
				echo ........Source Delete Log Details....... 
				echo `cat $logdir/$srcdellog`
				echo ......................................
				rm $logdir/$srcdellog
			fi
#Expect changes ends
		fi	
	fi	
fi

#-----------------------------------------------------------------------------------------------#
# Removing temp direcotory and changing directory to script directory			#
#-----------------------------------------------------------------------------------------------#	
	 #Both the if conditions added as per Dinesh mail from 10g changes
	 if [ "$filemovementscriptexitstatus" != "1" ]         
	 then
		 if [ "$deleteafterprocessing" = "y" ]      
		   then                                                                      
				cd  $originaltempdir
				rm -rf $tempdir
				echo removing temp directory [$tempdir] result $?
				cd "$curdir"
		fi
	 fi
	
	echo filemovementscriptexitstatus $filemovementscriptexitstatus
	exit "$filemovementscriptexitstatus"
