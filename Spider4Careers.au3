;;;#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=SpiderCareers.ico
#AutoIt3Wrapper_outfile=SpiderCareers.exe
#AutoIt3Wrapper_Res_Description=SpiderCareers
#AutoIt3Wrapper_Res_Fileversion=0.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=DirectUKJobsdotTK. All rights reserved.
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author: DirectUKJobs
 Contact: directukjobs@gmail.com
 Date: 12 April 2017
 Updated:
 Location: Earth
 Script Function: Spider to find Career Pages on UK domains
 Version: Alpha 1.0

#ce ----------------------------------------------------------------------------

; ########################################################################################################
; # Global Include and Dim                                                                               #
; ########################################################################################################
#include <Array.au3>
#include <file.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Process.au3>
#include <String.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include "WinHttp.au3" ; WinHttp
#include <Date.au3>
#Include "JSMN.au3"    ; JSON Decoder JSMN
#include <Misc.au3>
#include <IE.au3>
#include "VT.au3"   ; Virus Total https://www.virustotal.com/en/documentation/public-api/#
#include <GuiMenu.au3>
#include <WinAPI.au3>

; -------------------------------------------------------------------------------------------------------------

; ###########################################
; # MAKE SURE ONLY ON APP RUNNING AT A TIME #
; ###########################################
If _Singleton("Spider4Careers",1) = 0 Then
If ProcessExists("Spider4Careers.exe") Then
    ProcessClose("Spider4Careers.exe")
Endif
Endif

; -------------------------------------------------------------------------------------------------------------

; ##################################################
; # SET A HOT KEY TO STOP THE PROCESS AND EXIT APP #
; ##################################################
HotKeySet("{ESC}", "_onClick")

; -------------------------------------------------------------------------------------------------------------

; ########################
; # LOCAL DIM GLOBAL VAR #
; ########################
Local $ai = 0, $dData, $hDownload, $iSize, $hFile
Global $file,$html,$nMsg,$Exitloop1,$sFilePath,$aArray_Domains, $PingOK1, $iniset1,$iniset2,$iniset3,$iniset4,$iniset5,$iniset6,$iniset7,$iniset8,$iniset9,$iniset10,$iniset11,$iniset12,$iniset13,$iniset14,$iniset15,$iniset16
Global $VTSubmit, $VTReport, $hVirusTotal, $VTReportReturn, $pe1 = 0, $pe2 = 0, $pe3 = 0, $VTReportScan, $VTReportScan2, $VTReportScan3, $VTReportScan4, $VTReportScan5, $VTReportScan6, $VTReportScan7,$VTReportScan8,$VTReportScan9, $VTAntiVirusData = ""
;;;Global $url = "http://www.google.co.uk" ; Old testing code
; -------------------------------------------------------------------------------------------------------------

; ########################################################################
; # TALK # TELL THE USER THE PROGRAM IS START IF INI = CHECKBOX is valid #
; ########################################################################
If number(IniRead(@ScriptDir & "\settings.ini", "options", "intro", "1")) = 1 then
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 then _TalkOBJ("Starting Spider 4 Careers") ; change the text to suit you desire
endif
; -------------------------------------------------------------------------------------------------------------

; ###############################################
; # CHECK IF THE DATABASE EXISTS ELSE CREATE IT #
; ###############################################
If not FileExists(@ScriptDir & "\spiderCAREERS.db") Then
_SQLiteCreateDB()
EndIf

; -------------------------------------------------------------------------------------------------------------   *** Need to add to meny to read ini file and delete so it can recreate it

; ###################################################
; #  BUILD THE DOMAINS TLDS if it does not EXIST    #
; ###################################################
If not FileExists(@ScriptDir & "\tlds.txt") Then
Local $filecsv1 = @ScriptDir & "\tlds.txt"
Local $hFileOpen = FileOpen($filecsv1, $FO_APPEND)
FileWrite($hFileOpen, _
"uk" & @CRLF & "us" & @CRLF & "com" & @CRLF & "net" & @CRLF & "org" & @CRLF & "london" & @CRLF & "za" & @CRLF & "barclays" & @CRLF & "ie" & @CRLF & "jobs" & @CRLF & "ge" & @CRLF & "edu" & @CRLF & "gov" & @CRLF & "eu" & @CRLF & "de" & @CRLF & "weir" & @CRLF & "st" & @CRLF & "io" & @CRLF & "biz" & @CRLF & "aero" & @CRLF & "cc" & @CRLF & "tv" & @CRLF & "lidl" & @CRLF & "bnpparibas" & @CRLF & "au" & @CRLF & "nz" & @CRLF & "ml" & @CRLF & "coop" & @CRLF & "museum" & @CRLF & "it" & @CRLF & "travel" & @CRLF & "mobi" & @CRLF & "fr" & @CRLF & "pl" & @CRLF & "name" & @CRLF & "nato" & @CRLF & "" _
& "jp" & @CRLF & "xxx" & @CRLF & "ch" & @CRLF & "nl" & @CRLF & "zm" & @CRLF & "zw")
FileClose($hFileOpen)
Endif

; -------------------------------------------------------------------------------------------------------------

; ##############################
; #  BUILD THE EXCLUDE DOMAINS #
; ##############################
If not FileExists(@ScriptDir & "\exclude.txt") Then
Local $fileExclude1 = @ScriptDir & "\exclude.txt"
Local $hFileOpen = FileOpen($fileExclude1, $FO_APPEND)
FileWrite($hFileOpen, _
"escort" & @CRLF & "porn" & @CRLF & "xxx" & @CRLF & "naked" & @CRLF & "glassdoor" & @CRLF & "github" & @CRLF & "w3.org" & @CRLF & "client.ge" & @CRLF & "" _
& "calendars.st" & @CRLF & "days.name" & @CRLF & "months.name" & @CRLF & "years.name" & @CRLF & "youtube.com" & @CRLF & "performance.ge" & @CRLF & "client.de" & @CRLF & "server.ge" & @CRLF & "server.de")
FileClose($hFileOpen)
Endif

; -------------------------------------------------------------------------------------------------------------

; ###################################
; #  BUILD THE META INCLUDE DOMAINS #  If the meta contains one of the folling key words then this is the only site we want to view
; ###################################
If not FileExists(@ScriptDir & "\metainclude.txt") Then
Local $fileExclude1 = @ScriptDir & "\metainclude.txt"
Local $hFileOpen = FileOpen($fileExclude1, $FO_APPEND)
FileWrite($hFileOpen, _
"oil" & @CRLF & "gas" & @CRLF & "drill" & @CRLF & "petrolium" & @CRLF & "stock" & @CRLF & "bond" & @CRLF & "market" & @CRLF & "hedge" & @CRLF & "fund")
FileClose($hFileOpen)
Endif

; ###################################
; #  BUILD THE META EXCLUDE DOMAINS #  If the meta contains one of the folling key words then this is the only site we DONT want to view
; ###################################
If not FileExists(@ScriptDir & "\metaexclude.txt") Then
Local $fileExclude1 = @ScriptDir & "\metaexclude.txt"
Local $hFileOpen = FileOpen($fileExclude1, $FO_APPEND)
FileWrite($hFileOpen, _
"porn" & @CRLF & "adult content" & @CRLF & "xxx" & @CRLF & "recruitment agents" & @CRLF & "staffing" & @CRLF & "nude" & @CRLF & "extreem" & @CRLF & "over 18" & @CRLF & "political")
FileClose($hFileOpen)
Endif

; -------------------------------------------------------------------------------------------------------------   *** Need to add to meny to read ini file and delete so it can recreate it

; ###################################################
; #  CHECK IF domans.INI FILE EXISTS OR CREATE IT   #
; ###################################################
If not FileExists(@ScriptDir & "\domains.ini") Then
IniWrite(@ScriptDir & "\domains.ini", "options", "0", "https://directukjobs.000webhostapp.com/index.php/domains/")
IniWrite(@ScriptDir & "\domains.ini", "options", "1", "file://" & @ScriptDir & "/1.txt")
IniWrite(@ScriptDir & "\domains.ini", "options", "2", "file://" & @ScriptDir & "/2.txt")
IniWrite(@ScriptDir & "\domains.ini", "options", "3", "file://" & @ScriptDir & "/3.txt")
IniWrite(@ScriptDir & "\domains.ini", "options", "4", "file://" & @ScriptDir & "/4.txt")
IniWrite(@ScriptDir & "\domains.ini", "options", "5", "file://" & @ScriptDir & "/5.txt")
IniWrite(@ScriptDir & "\domains.ini", "options", "6", "file://" & @ScriptDir & "/6.txt")
Endif

; -------------------------------------------------------------------------------------------------------------

; ###################################################
; #  CHECK IF SETTINGS.INI FILE EXISTS OR CREATE IT #  Add VERSION
; ###################################################
If not FileExists(@ScriptDir & "\settings.ini") Then
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset1", "Career") ; ALGO Search Value1
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset2", "Vacanc") ; ALGO Search Value2
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset3", "Recruit") ; ALGO Search Value3
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset4", "Job opportunity") ; ALGO Search Value4
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset5", "Work for") ; ALGO Search Value5
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset6", "We're Hiring") ; ALGO Search Value6
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset7", "Join Us") ; ALGO Search Value7
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset8", "Jobs") ; ALGO Search Value8
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset9", "Hiring") ; ALGO Search Value9
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset10", "Join the team") ; ALGO Search Value10
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset11", "1") ; Checkbox Talk Value11  1 = on 4 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset12", "1") ; Checkbox Drum Value12
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset13", "4") ; Checkbox DeepSearch Value13
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset14", "4") ; Checkbox Auto Start Value14
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset15", "4") ; Checkbox Ping On or Off Value15

IniWrite(@ScriptDir & "\settings.ini", "options", "iniset16", "4") ; Checkbox Collect Emails On or Off Value16  (NOW GOOGLE SAFESURF)

IniWrite(@ScriptDir & "\settings.ini", "options", "iniset17", "1") ; Tell the program to do a online antivirus before exploring any urls  1 = on 4 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "colab", "4") ; Set the Colabaration on or off 1 = on 4 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "ShowFoundEmail", "0")

; -----------------------------
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset20", "IT Manager") ; ALGO DEEP Search Value1
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset21", "IT Support") ; ALGO DEEP Search Value2
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset22", "IT Administrator") ; ALGO DEEP Search Value3
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset23", "VAT Manager") ; ALGO DEEP Search Value4
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset24", "Chef") ; ALGO DEEP Search Value5
; -----------------------------

; # THESE NEED TO BE SET IN THE MENU
IniWrite(@ScriptDir & "\settings.ini", "options", "pingserver", "google.com") ; Set the value of the server to ping to make sure the internet is active else we loose scans
IniWrite(@ScriptDir & "\settings.ini", "options", "pingtime", "4000") ; Set the value of the ping time to be alive
IniWrite(@ScriptDir & "\settings.ini", "options", "pingsleep", "1000") ; Set the value of the ping time to wait
IniWrite(@ScriptDir & "\settings.ini", "options", "prospeed", "100") ; Set the value to control the speed of the app as not to kill the CPU at 100%
IniWrite(@ScriptDir & "\settings.ini", "options", "checkversionon", "0") ; Checkversion value 1 = on 0 = off

IniWrite(@ScriptDir & "\settings.ini", "options", "domainlistupdate", "0") ; Tell the program to check if a new domain list file to be looked for value 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "domainext", "uk") ; Tell the program search for this domain eg. uk - co.uk net com depending on domainlist also may need to disable domainlistupdate and inport your own list files in file stucture 0 - last number with no gaps.
IniWrite(@ScriptDir & "\settings.ini", "options", "domaintldson", "1") ; Tell the program to use the TLDS list instead of specific domain search 1 = on 2 = off.
IniWrite(@ScriptDir & "\settings.ini", "options", "avscannumfail", "1") ; Tell the AV the amount of vendor detections to fail on. There are 16 now it scans. 1 is any. 2 and higher to let positive virus match overide.
IniWrite(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20") ; Tell the AV when to asume the AV server failed
IniWrite(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") ; Tell the AV program wait for a time before trying the API again if the server was too busy default is 60 seconds due to only 4 request a minute
IniWrite(@ScriptDir & "\settings.ini", "options", "AVdatediff", "7") ; Tell the AV program to only rescan a site if its older than X days since last scan
IniWrite(@ScriptDir & "\settings.ini", "options", "AVAPIKey", "fd1335fc15d0b0a35771707406c45edd0d726c9c281942e637cc679255517601") ; Tell the AV program to use this API key to allow scanning
IniWrite(@ScriptDir & "\settings.ini", "options", "submitpageshow", "1") ; Tell the program to show the submit jobs webpage 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "postajobURL", "https://directukjobs.000webhostapp.com/index.php/submit/") ; Tell the program what page to open with the POST A JOB Page for each career found (Advertising here)
IniWrite(@ScriptDir & "\settings.ini", "options", "talkredirect", "0") ; Tell the program to tell me if there was a redirect 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "talksorrynolinks", "0") ; Tell the program to tell me if there was no links 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "foundalgoshow", "1") ; Tell the program to show when it finds algos 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "foundalgolinksshow", "1") ; Tell the program to show what links it found when it finds algos 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "showemailfoundON", "1") ; Tell the program to show email results 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "intro", "1") ; Set the talking into on or off 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "music", "0") ; Set the music on or off 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "musiclist", "EGYaxYaxD_M&list=RDtWe19KS-i-c&index=2") ; Set the YOUTUBE CODE of the music you want to play (Check your Broser address bar for the code)

IniWrite(@ScriptDir & "\settings.ini", "options", "freq", "400") ; Set the BEEP Frequency
IniWrite(@ScriptDir & "\settings.ini", "options", "dura", "50") ; Set the BEEP Duration

IniWrite(@ScriptDir & "\settings.ini", "options", "datediff", "30") ; Tell the program to only reprocess a domain if older than x amount of days since last process
IniWrite(@ScriptDir & "\settings.ini", "options", "excludeon", "1") ; Tell the program to check for excluded domains to be looked for value 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "save2file", "0") ; Tell the program to save results to a file 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "enablelinks", "1") ; Tell the program to search for links 1 = on 0 = off

; TO DO
IniWrite(@ScriptDir & "\settings.ini", "options", "founddeepcrawl", "3") ; Tell the program how deep to crawl
IniWrite(@ScriptDir & "\settings.ini", "options", "founddeepinout", "1") ; Tell the program to stay inside the domain when crawling or venture out
IniWrite(@ScriptDir & "\settings.ini", "options", "founddeepalgoshow", "1") ; Tell the program to show deep algo msgbox 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "founddeepalgolinkshow", "1") ; Tell the program to show deep algo links found 1 = on 0 = off

IniWrite(@ScriptDir & "\settings.ini", "options", "showAVmsgbox", "1") ; Tell the program to show anti virus msgboxes 1 = on 0 = off

IniWrite(@ScriptDir & "\settings.ini", "options", "ShowFoundEmail", "0") ; Set the TO email function on or off 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "emaileron", "0") ; Set the TO email function on or off 1 = on 0 = off
IniWrite(@ScriptDir & "\settings.ini", "options", "emailserver", "")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailserverport", "")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailserverTSL", "")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailbodyfile", "")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailusername", "")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailpassword", "")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailreport1FILE", "0")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailreport1JOB", "0")
IniWrite(@ScriptDir & "\settings.ini", "options", "emailthisjobON", "0")

IniWrite(@ScriptDir & "\settings.ini", "options", "IncludeONLYMeta", "0") ; Tell the program to check metadata for keywords from metainclude.txt ONLY DO IT IF FOUND 0 off 1 on
IniWrite(@ScriptDir & "\settings.ini", "options", "ExcludeONLYMeta", "0") ; Tell the program to check metadata for keywords from metaexclude.txt DROP IT IF FOUND 0 off 1 on

endif

; -------------------------------------------------------------------------------------------------------------

; ##########################
; #    SET VERSION         #
; ##########################

IniWrite(@ScriptDir & "\settings.ini", "options", "checkversionval", "0") ; Checkversion value - Should increase after each update

; -------------------------------------------------------------------------------------------------------------

;##################################
; READ SETTING.INI Settings       #  This is the settings for the GUI Screen  / Working With Us / Join Us
;##################################
$iniset1 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset1", "Career")
$iniset2 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset2", "Vacanc")
$iniset3 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset3", "Recruit")
$iniset4 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset4", "Job Opportunity")
$iniset5 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset5", "Work for")
$iniset6 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset6", "We're Hiring")
$iniset7 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset7", "Employment")
$iniset8 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset8", "Jobs")
$iniset9 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset9", "Hiring")
$iniset10 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset10", "Join the")
$iniset11 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1")
$iniset12 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset12", "1")
$iniset13 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset13", "4")
$iniset14 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset14", "4")
$iniset15 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset15", "4")
$iniset16 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset16", "4")
$iniset17 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset17", "1")
$iniset18 = IniRead(@ScriptDir & "\settings.ini", "options", "colab", "4")

$iniset20 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset20", "IT") ; ALGO DEEP Search Value1
$iniset21 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset21", "Manager") ; ALGO DEEP Search Value2
$iniset22 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset22", "Windows") ; ALGO DEEP Search Value3
$iniset23 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset23", "Support") ; ALGO DEEP Search Value4
$iniset24 = IniRead(@ScriptDir & "\settings.ini", "options", "iniset24", "Administrator") ; ALGO DEEP Search Value5

; -------------------------------------------------------------------------------------------------------------

; #####################
; # CHECK THE VERSION #
; #####################
_VersionCheck()

; -------------------------------------------------------------------------------------------------------------

; ##########################
; # Create the GUI         #
; ##########################
;Opt('GUIOnEventMode', 1)

#Region ### START Koda GUI section ### Form=C:\Users\Pookie\Desktop\DirectUKjobs\Koda\Forms\DirectUKJobs.kxf
$Form1 = GUICreate("Spider4Careers", 710, 420, 192, 124, $WS_EX_TOOLWINDOW)
;GUISetOnEvent(-3, '_exit')

; --------------------------
; # MENU #

Local $MenuItem1 = GUICtrlCreateMenu("Options")
Local $MenuItemDB = GUICtrlCreateMenu("Database")
Local $MenuItemAV = GUICtrlCreateMenu("AntiVirus")
Local $MenuItemTune = GUICtrlCreateMenu("Music")
Local $MenuItemDomains = GUICtrlCreateMenu("Domains")
Local $MenuItemShow = GUICtrlCreateMenu("Show Details")
Local $MenuItemTalk = GUICtrlCreateMenu("Talking")
Local $MenuItemEmail = GUICtrlCreateMenu("Email CV")
Local $MenuItemDeep = GUICtrlCreateMenu("Deep Search")

Local $MenuItemNOTHING = GUICtrlCreateMenuItem("Not Avalible in this Version", $MenuItemEmail)

Local $MenuItemNOTHING = GUICtrlCreateMenuItem("Not Avalible in this Version", $MenuItemDeep)

Local $MenuItem2 = GUICtrlCreateMenuItem("Music On/Off", $MenuItemTune)
Local $MenuItem3 = GUICtrlCreateMenuItem("Set Youtube Music List", $MenuItemTune)

Local $MenuItem5 = GUICtrlCreateMenuItem("Set Ping Server", $MenuItem1)
Local $MenuItem6 = GUICtrlCreateMenuItem("Set Ping Timeout", $MenuItem1)
Local $MenuItem7 = GUICtrlCreateMenuItem("Check for Updates On/Off", $MenuItem1)
Local $MenuItem8 = GUICtrlCreateMenuItem("Set Program Speed", $MenuItem1)
Local $MenuItem37 = GUICtrlCreateMenuItem("Output to file On/Off", $MenuItem1)
Local $MenuItem39 = GUICtrlCreateMenuItem("Edit Output file", $MenuItem1)
Local $MenuItem38 = GUICtrlCreateMenuItem("Erase Output file", $MenuItem1)

Local $MenuItem9 = GUICtrlCreateMenuItem("Domain-List Update On/Off", $MenuItemDomains)
Local $MenuItem10 = GUICtrlCreateMenuItem("Set Domain Type", $MenuItemDomains)
Local $MenuItem11 = GUICtrlCreateMenuItem("Enable Domain TLDS On/Off", $MenuItemDomains)
Local $MenuItem48 = GUICtrlCreateMenuItem("Enable Search for Links On/Off", $MenuItemDomains)
Local $MenuItem27 = GUICtrlCreateMenuItem("Enable Exclude On/Off", $MenuItemDomains)
Local $MenuItem30 = GUICtrlCreateMenuItem("Edit Domain File List", $MenuItemDomains)
Local $MenuItem33 = GUICtrlCreateMenuItem("Edit TLDS List", $MenuItemDomains)
Local $MenuItem32 = GUICtrlCreateMenuItem("Edit Exclude List", $MenuItemDomains)
Local $MenuItem31 = GUICtrlCreateMenuItem("Pull Domains From Tool", $MenuItemDomains)
Local $MenuItem43 = GUICtrlCreateMenuItem("Enable Include META On/Off", $MenuItemDomains)
Local $MenuItem44 = GUICtrlCreateMenuItem("Enable Exclude META On/Off", $MenuItemDomains)
Local $MenuItem45 = GUICtrlCreateMenuItem("Edit Include META File List", $MenuItemDomains)
Local $MenuItem46 = GUICtrlCreateMenuItem("Edit Exclude META File List", $MenuItemDomains)

Local $MenuItem12 = GUICtrlCreateMenuItem("Set AntiVirus Min Postitive", $MenuItemAV)
Local $MenuItem13 = GUICtrlCreateMenuItem("Set AntiVirus Server Timeout", $MenuItemAV)
Local $MenuItem14 = GUICtrlCreateMenuItem("Set AntiVirus Retry Time", $MenuItemAV)
Local $MenuItem15 = GUICtrlCreateMenuItem("Set AntiVirus Fresh Scan Date", $MenuItemAV)
Local $MenuItem16 = GUICtrlCreateMenuItem("Set AntiVirus API Key", $MenuItemAV)
Local $MenuItem47 = GUICtrlCreateMenuItem("Show AntiVirus Messages On/Off ", $MenuItemAV)

Local $MenuItem4 = GUICtrlCreateMenuItem("Talk Intro On/Off", $MenuItemTalk)
Local $MenuItem18 = GUICtrlCreateMenuItem("Talk Redirect Found On/Off", $MenuItemTalk)
Local $MenuItem19 = GUICtrlCreateMenuItem("Talk No Links Found On/Off", $MenuItemTalk)

Local $MenuItem20 = GUICtrlCreateMenuItem("Show Algos Found On/Off", $MenuItemShow)
Local $MenuItem21 = GUICtrlCreateMenuItem("Show Links Found On/Off", $MenuItemShow)
Local $MenuItem22 = GUICtrlCreateMenuItem("Show Email Found On/Off", $MenuItemShow)
Local $MenuItem17 = GUICtrlCreateMenuItem("Show Post a Job On/Off", $MenuItemShow)
Local $MenuItem40 = GUICtrlCreateMenuItem("Edit Post a Job URL", $MenuItemShow)

Local $MenuItem23 = GUICtrlCreateMenuItem("Erase Domain Database", $MenuItemDB)
Local $MenuItem24 = GUICtrlCreateMenuItem("Erase Email Database", $MenuItemDB)
Local $MenuItem25 = GUICtrlCreateMenuItem("Erase Links Database", $MenuItemDB)
Local $MenuItem26 = GUICtrlCreateMenuItem("Erase Domain Filelist Database", $MenuItemDB)
Local $MenuItem41 = GUICtrlCreateMenuItem("Erase Deep Links Database", $MenuItemDB)
Local $MenuItem28 = GUICtrlCreateMenuItem("Erase Aged Domains/Links for Rescan", $MenuItemDB)
Local $MenuItem29 = GUICtrlCreateMenuItem("Set Aged Domain Date", $MenuItemDB)
Local $MenuItem34 = GUICtrlCreateMenuItem("Export DB Domains to file", $MenuItemDB)
Local $MenuItem35 = GUICtrlCreateMenuItem("Export DB Emails to file", $MenuItemDB)
Local $MenuItem36 = GUICtrlCreateMenuItem("Export DB Links to file", $MenuItemDB)
Local $MenuItem42 = GUICtrlCreateMenuItem("Export DB DEEP Links to file", $MenuItemDB)

; NEXT MENU = 49

Local $MenuItemE = GUICtrlCreateMenuItem("Exit", $MenuItem1)

; --------------------------

Global $Checkbox1 = GUICtrlCreateCheckbox("Talk to me", 10, 8, 75, 17)
; Check Settings.ini and set the checkbox
If $iniset11 = 4 then GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)
If $iniset11 = 1 then GUICtrlSetState($Checkbox1, $GUI_CHECKED)
Global $Checkbox2 = GUICtrlCreateCheckbox("Drum Beat", 85, 8, 70, 17)
; Check Settings.ini and set the checkbox
If $iniset12 = 4 then GUICtrlSetState($Checkbox2, $GUI_UNCHECKED)
If $iniset12 = 1 then GUICtrlSetState($Checkbox2, $GUI_CHECKED)
Global $Checkbox3 = GUICtrlCreateCheckbox("Deep Search", 160, 8, 80, 17)
; Check Settings.ini and set the checkbox
If $iniset13 = 4 then GUICtrlSetState($Checkbox3, $GUI_UNCHECKED)
If $iniset13 = 1 then GUICtrlSetState($Checkbox3, $GUI_CHECKED)
Global $Checkbox4 = GUICtrlCreateCheckbox("Auto Start", 250, 8, 70, 17)
; Check Settings.ini and set the checkbox
If $iniset14 = 4 then GUICtrlSetState($Checkbox4, $GUI_UNCHECKED)
If $iniset14 = 1 then GUICtrlSetState($Checkbox4, $GUI_CHECKED)
Global $Checkbox5 = GUICtrlCreateCheckbox("Ping", 320, 8, 50, 17)
; Check Settings.ini and set the checkbox
If $iniset15 = 4 then GUICtrlSetState($Checkbox5, $GUI_UNCHECKED)
If $iniset15 = 1 then GUICtrlSetState($Checkbox5, $GUI_CHECKED)
Global $Checkbox6 = GUICtrlCreateCheckbox("Email", 370, 8, 50, 17)
; Check Settings.ini and set the checkbox
If $iniset16 = 4 then GUICtrlSetState($Checkbox6, $GUI_UNCHECKED)
If $iniset16 = 1 then GUICtrlSetState($Checkbox6, $GUI_CHECKED)
Global $Checkbox7 = GUICtrlCreateCheckbox("AntiVirus", 420, 8, 60, 17)
; Check Settings.ini and set the checkbox
If $iniset17 = 4 then GUICtrlSetState($Checkbox7, $GUI_UNCHECKED)
If $iniset17 = 1 then GUICtrlSetState($Checkbox7, $GUI_CHECKED)

Global $Checkbox8 = GUICtrlCreateCheckbox("Colab", 485, 8, 60, 17)
; Check Settings.ini and set the checkbox
If $iniset18 = 4 then GUICtrlSetState($Checkbox8, $GUI_UNCHECKED)
If $iniset18 = 1 then GUICtrlSetState($Checkbox8, $GUI_CHECKED)

Global $Progress1 = GUICtrlCreateProgress(550, 8, 150, 17) ; Progress Bar

Global $Label1 = GUICtrlCreateLabel("Searching Algo 1", 20, 35, 85, 17)
Global $Label2 = GUICtrlCreateLabel("Searching Algo 2", 20, 65, 85, 17)
Global $Label3 = GUICtrlCreateLabel("Searching Algo 3", 20, 95, 85, 17)
Global $Label4 = GUICtrlCreateLabel("Searching Algo 4", 20, 125, 85, 17)
Global $Label5 = GUICtrlCreateLabel("Searching Algo 5", 20, 155, 85, 17)

Global $Label6 = GUICtrlCreateLabel("Searching Algo 6", 315, 35, 85, 17)
Global $Label7 = GUICtrlCreateLabel("Searching Algo 7", 315, 65, 85, 17)
Global $Label8 = GUICtrlCreateLabel("Searching Algo 8", 315, 95, 85, 17)
Global $Label9 = GUICtrlCreateLabel("Searching Algo 9", 315, 125, 85, 17)
Global $Label10 = GUICtrlCreateLabel("Searching Algo 10", 315, 155, 95, 17)

Global $Label99 = GUICtrlCreateLabel("Press Escape Key to Halt/Exit processing", 110, 185, 260, 17)

Global $Label100 = GUICtrlCreateLabel("WARNING: Do not use this software on mobile/cell internet or on limited intenet connections! This software is strickly use at own risk!", 30, 345, 655, 17)

Global $Input1 = GUICtrlCreateInput($iniset1, 120, 35, 180, 21)
Global $Input2 = GUICtrlCreateInput($iniset2, 120, 65, 180, 21)
Global $Input3 = GUICtrlCreateInput($iniset3, 120, 95, 180, 21)
Global $Input4 = GUICtrlCreateInput($iniset4, 120, 125, 180, 21)
Global $Input5 = GUICtrlCreateInput($iniset5, 120, 155, 180, 21)
Global $Input6 = GUICtrlCreateInput($iniset6, 420, 35, 180, 21)
Global $Input7 = GUICtrlCreateInput($iniset7, 420, 65, 180, 21)
Global $Input8 = GUICtrlCreateInput($iniset8, 420, 95, 180, 21)
Global $Input9 = GUICtrlCreateInput($iniset9, 420, 125, 180, 21)
Global $Input10 = GUICtrlCreateInput($iniset10, 420, 155, 180, 21)

Global $Button1 = GUICtrlCreateButton("Save", 620, 32, 73, 33)
;GUICtrlSetOnEvent(-1, '_JobSave')

Global $Button4 = GUICtrlCreateButton("Exit", 620, 70, 73, 33)
;GUICtrlSetOnEvent(-1, '_exit')

Global $Button2 = GUICtrlCreateButton("Start", 620, 108, 73, 33)
;GUICtrlSetOnEvent(-1, '_JobStartit')


;   ------------- DEEP SEARCH INTERFACE ----------------
Global $Label20 = GUICtrlCreateLabel("Deep Search Algo 1", 420, 190, 110, 17)
Global $Label21 = GUICtrlCreateLabel("Deep Search Algo 2", 420, 220, 110, 17)
Global $Label22 = GUICtrlCreateLabel("Deep Search Algo 3", 420, 250, 110, 17)
Global $Label23 = GUICtrlCreateLabel("Deep Search Algo 4", 420, 280, 110, 17)
Global $Label24 = GUICtrlCreateLabel("Deep Search Algo 5", 420, 310, 110, 17)

Global $Input20 = GUICtrlCreateInput($iniset20, 530, 190, 150, 21)
Global $Input21 = GUICtrlCreateInput($iniset21, 530, 220, 150, 21)
Global $Input22 = GUICtrlCreateInput($iniset22, 530, 250, 150, 21)
Global $Input23 = GUICtrlCreateInput($iniset23, 530, 280, 150, 21)
Global $Input24 = GUICtrlCreateInput($iniset24, 530, 310, 150, 21)
;   ------------- DEEP SEARCH INTERFACE ----------------

Global $Edit1 = GUICtrlCreateEdit("", 25, 210, 380, 127)

GUICtrlSetData(-1, "")
GUISetState(@SW_SHOW)
GUISetState(@SW_ENABLE)
#EndRegion ### END Koda GUI section ###

; -------------------------------------------------------------------------------------------------------------

; # MUSIC PLAYER LOAD #
if number(IniRead(@ScriptDir & "\settings.ini", "options", "music", "1")) = 1 then
   _MusicPlayer()
Endif

; -------------------------------------------------------------------------------------------------------------

; INTRO TALK
If number(IniRead(@ScriptDir & "\settings.ini", "options", "intro", "1")) = 1 then
If number(IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1")) = 1 then _TalkOBJ("Click the start button to begin searching")
Endif
; -------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------

; ##########################
; # GUI LOOP TILL EXIT     #
; ##########################
While 1
   Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc") ; Check for errors all the time
; """"""""""""""""""""""""""
$nMsg = GUIGetMsg()

; Set the menu options
If $nMsg = $MenuItem2 Then Call("_idMusic")
If $nMsg = $MenuItem3 Then Call("_idmusiclist")
If $nMsg = $MenuItem4 Then Call("_idIntro")
If $nMsg = $MenuItem5 Then Call("_idPingServer")
If $nMsg = $MenuItem6 Then Call("_idPingTimeout")
If $nMsg = $MenuItem7 Then Call("_idCheckUpdate")
If $nMsg = $MenuItem8 Then Call("_idProSpeed")
If $nMsg = $MenuItem9 Then Call("_idDomainListUpdateON")
If $nMsg = $MenuItem10 Then Call("_idWorkingDomainType")
If $nMsg = $MenuItem11 Then Call("_idWorkingDomainTLDS")
If $nMsg = $MenuItem12 Then Call("_idAVMINPositive")
If $nMsg = $MenuItem13 Then Call("_idAVMServertimeout")
If $nMsg = $MenuItem14 Then Call("_idAVMRetytime")
If $nMsg = $MenuItem15 Then Call("_idAVFreshDate")
If $nMsg = $MenuItem16 Then Call("_idAVAPIKey")
If $nMsg = $MenuItem17 Then Call("_idShowPostaJob")
If $nMsg = $MenuItem18 Then Call("_idTalkRedirecton")
If $nMsg = $MenuItem19 Then Call("_idTalkNoLinksFound")
If $nMsg = $MenuItem20 Then Call("_idShowAlgosFound")
If $nMsg = $MenuItem21 Then Call("_idShowLinksFound")
If $nMsg = $MenuItem22 Then Call("_idShowEmailFound")
If $nMsg = $MenuItem23 Then Call("_idDropDomainDB")
If $nMsg = $MenuItem24 Then Call("_idDropEmailDB")
If $nMsg = $MenuItem25 Then Call("_idDropLinksDB")
If $nMsg = $MenuItem26 Then Call("_idDropFileListDB")
If $nMsg = $MenuItem27 Then Call("_idDomainExcludeOn")
If $nMsg = $MenuItem28 Then Call("_idEraseDatedDomain")
If $nMsg = $MenuItem29 Then Call("_iddatediff")
If $nMsg = $MenuItem30 Then Call("_iddomainlistedit")
If $nMsg = $MenuItem31 Then Call("_idpulldomainsfrom")
If $nMsg = $MenuItem32 Then Call("_idupdateExclude")
If $nMsg = $MenuItem33 Then Call("_idupdateTLDS")
If $nMsg = $MenuItem34 Then Call("_idExportDomain2file")
If $nMsg = $MenuItem35 Then Call("_idExportEmail2file")
If $nMsg = $MenuItem36 Then Call("_idExportLinks2file")
If $nMsg = $MenuItem37 Then Call("_idOutput2file")
If $nMsg = $MenuItem38 Then Call("_idEraseOutput2file")
If $nMsg = $MenuItem39 Then Call("_idEditOutput2file")
If $nMsg = $MenuItem40 Then Call("_idEditPostAJobURL")
If $nMsg = $MenuItem48 Then Call("_EnableLinksSearch") ; Enable Search for Links On/Off
If $nMsg = $MenuItem43 Then Call("_metaincludeon") ; Enable Meta Include On/Off
If $nMsg = $MenuItem44 Then Call("_metaexcludeon") ; Enable Meta Exclude On/Off
If $nMsg = $MenuItem45 Then Call("_idEditmetaincludeon") ; Edit Meta Include file
If $nMsg = $MenuItem46 Then Call("_idEditmetaexcludeon") ; Edit Meta Exclude file

If $nMsg = $MenuItem41 Then Call("_featurenotaval") ; Deep DB Erase
If $nMsg = $MenuItem42 Then Call("_featurenotaval") ; Export Deep Link DB
If $nMsg = $MenuItem47 Then Call("_featurenotaval") ; Show Anti-Virus Messages On/Off

If $nMsg = $MenuItemE Then Call("_exit"); Quit_exit

; Set the buttons options
If $nMsg = $Button4 Then Call("_exit")
If $nMsg = $Button1 Then Call("_JobSave")
If $nMsg = $Button2 Then Call("_JobStartit")

; """"""""""""""""""""""""""
Switch $nMsg
Case $GUI_EVENT_CLOSE
Exit
EndSwitch
; """"""""""""""""""""""""""
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
WEnd
GUIDelete()

; -------------------------------------------------------------------------------------------------------------

; ########################################################################################################
; ########################################################################################################
; # CALLED FUNCTIONS #
; ########################################################################################################
; ########################################################################################################

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
; MENU FUNCTIONS
Func _idMusic()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "music", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "music", "0")
GUICtrlSetData($Edit1,"Music Player is switched OFF" & @CRLF & GUICtrlRead($Edit1))
; # MUSIC SCREEN #
GUIDelete($Form2)
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "music", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "music", "1")
GUICtrlSetData($Edit1,"Music Player is switched ON" & @CRLF & GUICtrlRead($Edit1))
; # MUSIC SCREEN #
_MusicPlayer()
return
Endif
EndFunc

Func _idIntro()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "intro", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "intro", "0")
GUICtrlSetData($Edit1,"Intro Talk is switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "intro", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "intro", "1")
GUICtrlSetData($Edit1,"Intro Talk is switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idmusiclist()
Local $sAnswerMusicList = InputBox("Music List", "Please enter Youtube Video Code", Iniread(@ScriptDir & "\settings.ini", "options", "musiclist", "EGYaxYaxD_M&list=RDtWe19KS-i-c&index=2"))
;;; EGYaxYaxD_M&list=RDEGYaxYaxD_M#t=42
If $sAnswerMusicList = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "musiclist", $sAnswerMusicList)
GUICtrlSetData($Edit1,"Music List set to " & $sAnswerMusicList & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idPingServer()
Local $sAnswerPingServer = InputBox("Options", "Please enter a ping server", Iniread(@ScriptDir & "\settings.ini", "options", "pingserver", "google.com"))
If $sAnswerPingServer = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "pingserver", $sAnswerPingServer)
GUICtrlSetData($Edit1,"Ping Server set to " & $sAnswerPingServer & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idPingTimeout()
Local $sAnswerPingTimeout = InputBox("Options", "Please enter a ping timeout", Iniread(@ScriptDir & "\settings.ini", "options", "pingtime", "4000"))
If $sAnswerPingTimeout = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "pingtime", $sAnswerPingTimeout)
GUICtrlSetData($Edit1,"Ping Timeout set to " & $sAnswerPingTimeout & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idCheckUpdate()
   if number(IniRead(@ScriptDir & "\settings.ini", "options", "checkversionon", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "checkversionon", "0")
GUICtrlSetData($Edit1,"Check for Updates is switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "checkversionon", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "checkversionon", "1")
GUICtrlSetData($Edit1,"Check for Updates switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idProSpeed()
Local $sAnswerProSpeed = InputBox("Options", "Please enter in Ms Program Speed", Iniread(@ScriptDir & "\settings.ini", "options", "prospeed", "100"))
If $sAnswerProSpeed = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "prospeed", $sAnswerProSpeed)
GUICtrlSetData($Edit1,"Program Speed set to " & $sAnswerProSpeed & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idDomainListUpdateON()
   if number(IniRead(@ScriptDir & "\settings.ini", "options", "domainlistupdate", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "domainlistupdate", "0")
GUICtrlSetData($Edit1,"Update Domain List is switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "domainlistupdate", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "domainlistupdate", "1")
GUICtrlSetData($Edit1,"Update Domain List switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idWorkingDomainType()
Local $sAnswerDomainType = InputBox("Options", "Please enter the domain type to work with", Iniread(@ScriptDir & "\settings.ini", "options", "domainext", "uk"))
If $sAnswerDomainType = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "domainext", $sAnswerDomainType)
GUICtrlSetData($Edit1,"Domain Type set to " & $sAnswerDomainType & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idWorkingDomainTLDS()
   if number(IniRead(@ScriptDir & "\settings.ini", "options", "domaintldson", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "domaintldson", "0")
GUICtrlSetData($Edit1,"Use TLDS Domains switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "domaintldson", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "domaintldson", "1")
GUICtrlSetData($Edit1,"Use TLDS Domains switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idAVMINPositive()
Local $sAnswerAVMINPositive = InputBox("Options", "Please enter AntiVirus Min Positive Matches", Iniread(@ScriptDir & "\settings.ini", "options", "avscannumfail", "1"))
If $sAnswerAVMINPositive = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "avscannumfail", $sAnswerAVMINPositive)
GUICtrlSetData($Edit1,"AntVirus Min Positive Match set to " & $sAnswerAVMINPositive & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idAVMServertimeout()
Local $sAnswerAVServerTimeout = InputBox("Options", "Please enter AntiVirus Server Timeout", Iniread(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20"))
If $sAnswerAVServerTimeout = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "avscanB4fail", $sAnswerAVServerTimeout)
GUICtrlSetData($Edit1,"AntVirus Server Timeout set to " & $sAnswerAVServerTimeout & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idAVMRetytime()
Local $sAnswerAVRetryTime = InputBox("Options", "Please enter AntiVirus Retry Time in Ms", Iniread(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000"))
If $sAnswerAVRetryTime = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "antivirustime", $sAnswerAVRetryTime)
GUICtrlSetData($Edit1,"AntVirus Retry Time in Ms set to " & $sAnswerAVRetryTime & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idAVFreshDate()
Local $sAnswerAVFreshDate = InputBox("Options", "Please enter AntiVirus Days considered Fresh Results", Iniread(@ScriptDir & "\settings.ini", "options", "AVdatediff", "7"))
If $sAnswerAVFreshDate = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "AVdatediff", $sAnswerAVFreshDate)
GUICtrlSetData($Edit1,"AntVirus Days considered Fresh Results set to " & $sAnswerAVFreshDate & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idAVAPIKey()
Local $sAnswerAVAPIKey = InputBox("Options", "Please enter AntiVirus API Key", Iniread(@ScriptDir & "\settings.ini", "options", "AVAPIKey", "fd1335fc15d0b0a35771707406c45edd0d726c9c281942e637cc679255517601"))
If $sAnswerAVAPIKey = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "AVAPIKey", $sAnswerAVAPIKey)
GUICtrlSetData($Edit1,"AntVirus API Key set to " & $sAnswerAVAPIKey & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _idShowPostaJob()
   if number(IniRead(@ScriptDir & "\settings.ini", "options", "submitpageshow", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "submitpageshow", "0")
GUICtrlSetData($Edit1,"Show Post A Job switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "submitpageshow", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "submitpageshow", "1")
GUICtrlSetData($Edit1,"Show Post A Job switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idTalkRedirecton()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "talkredirect", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "talkredirect", "0")
GUICtrlSetData($Edit1,"Talk Redirection Found switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "talkredirect", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "talkredirect", "1")
GUICtrlSetData($Edit1,"Talk Redirection Found switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idTalkNoLinksFound()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "talksorrynolinks", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "talksorrynolinks", "0")
GUICtrlSetData($Edit1,"Talk No Links Found switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "talksorrynolinks", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "talksorrynolinks", "1")
GUICtrlSetData($Edit1,"Talk No Links Found switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idShowAlgosFound()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "foundalgoshow", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "foundalgoshow", "0")
GUICtrlSetData($Edit1,"Show Algos Found switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "foundalgoshow", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "foundalgoshow", "1")
GUICtrlSetData($Edit1,"Show Algos Found switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idShowLinksFound()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "foundalgolinksshow", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "foundalgolinksshow", "0")
GUICtrlSetData($Edit1,"Show Links Found switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "foundalgolinksshow", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "foundalgolinksshow", "1")
GUICtrlSetData($Edit1,"Show Links Found switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idShowEmailFound()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "showemailfoundON", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "showemailfoundON", "0")
GUICtrlSetData($Edit1,"Show Email Found switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "showemailfoundON", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "showemailfoundON", "1")
GUICtrlSetData($Edit1,"Show Email Found switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idDomainExcludeOn()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "excludeon", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "excludeon", "0")
GUICtrlSetData($Edit1,"Domain Excluded switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "excludeon", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "excludeon", "1")
GUICtrlSetData($Edit1,"Domain Excluded switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _iddatediff()
Local $sAnswerDatediff = InputBox("Options", "Please enter the Aged Domains Date", Iniread(@ScriptDir & "\settings.ini", "options", "datediff", "30"))
If $sAnswerDatediff = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "datediff", $sAnswerDatediff)
GUICtrlSetData($Edit1,"the Aged Domains Date set to " & $sAnswerDatediff & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _iddomainlistedit()
GUICtrlSetData($Edit1,"Opening Domains.INI for editing..." & @CRLF & GUICtrlRead($Edit1))
    Local $iPID = Run("notepad.exe domains.ini", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
    WinWait("[CLASS:Notepad]", "", 5)
EndFunc

Func _idOutput2file()
; ---------------------
; NOT AVALABLE IN THIS VERSION
; ---------------------
_featurenotaval()
return
; ---------------------
if number(IniRead(@ScriptDir & "\settings.ini", "options", "save2file", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "save2file", "0")
GUICtrlSetData($Edit1,"Output to File switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "save2file", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "save2file", "1")
GUICtrlSetData($Edit1,"Output to File switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idEraseOutput2file()
; ---------------------
; NOT AVALABLE IN THIS VERSION
; ---------------------
_featurenotaval()
return
; ---------------------
If FileExists(@ScriptDir & "\output.html") Then
; # MSGBOX #
ConsoleWrite("Would you like to erase the current output file output.html" & @CRLF)
GUICtrlSetData($Edit1,"Would you like to erase the current output file output.html" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to erase the current output file")
Local $MyBoxEXPORT = MsgBox(1, "Question","Would you like erase the current output file?" & @CRLF & "output.html" & @CRLF)
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxEXPORT == 1 Then ; OK CHOICE
; # TALK #
ConsoleWrite("Erasing File output.html" & @CRLF)
GUICtrlSetData($Edit1,"Erasing File output.html" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Erasing File")
_FileCreate("output.html")
ElseIf $MyBoxEXPORT == 2 Then ; CANCEL CHOICE
; Do nothing
EndIf
Else
; # TALK #
ConsoleWrite("The output file does not exsist output.html" & @CRLF)
GUICtrlSetData($Edit1,"The output file does not exsist output.html" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("The output file does not exsist")
EndIf
EndFunc

Func _idEditOutput2file()
; ---------------------
; NOT AVALABLE IN THIS VERSION
; ---------------------
_featurenotaval()
return
; ---------------------
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe output.html", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
return
EndFunc

Func _idEditPostAJobURL()
Local $sAnswerPOSTAJOBURL = InputBox("Options", "Please enter the Post A Job URL", Iniread(@ScriptDir & "\settings.ini", "options", "postajobURL", "https://directukjobs.000webhostapp.com/index.php/submit/"))
If $sAnswerPOSTAJOBURL = "" Then
   ; Do nothing
Else
IniWrite(@ScriptDir & "\settings.ini", "options", "postajobURL", $sAnswerPOSTAJOBURL)
GUICtrlSetData($Edit1,"The Post A Job URL set to " & $sAnswerPOSTAJOBURL & @CRLF & GUICtrlRead($Edit1))
Endif
return
EndFunc

Func _EnableLinksSearch()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "enablelinks", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "enablelinks", "0")
GUICtrlSetData($Edit1,"Enable Search Links switched OFF" & @CRLF & GUICtrlRead($Edit1))
;;;GUICtrlSetData($Edit1,number(IniRead(@ScriptDir & "\settings.ini", "options", "enablelinks", "1")) & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "enablelinks", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "enablelinks", "1")
GUICtrlSetData($Edit1,"Enable Search Links switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _metaexcludeon()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "ExcludeONLYMeta", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "ExcludeONLYMeta", "0")
GUICtrlSetData($Edit1,"Enable Meta Exclude switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "ExcludeONLYMeta", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "ExcludeONLYMeta", "1")
GUICtrlSetData($Edit1,"Enable Meta Exclude switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _metaincludeon()
if number(IniRead(@ScriptDir & "\settings.ini", "options", "IncludeONLYMeta", "1")) = 1 then
IniWrite(@ScriptDir & "\settings.ini", "options", "IncludeONLYMeta", "0")
GUICtrlSetData($Edit1,"Enable Meta Include switched OFF" & @CRLF & GUICtrlRead($Edit1))
return
Endif
if number(IniRead(@ScriptDir & "\settings.ini", "options", "IncludeONLYMeta", "0")) = 0 then
IniWrite(@ScriptDir & "\settings.ini", "options", "IncludeONLYMeta", "1")
GUICtrlSetData($Edit1,"Enable Meta Include switched ON" & @CRLF & GUICtrlRead($Edit1))
return
Endif
EndFunc

Func _idEditmetaincludeon()
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe metainclude.txt", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
return
EndFunc

Func _idEditmetaexcludeon()
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe metaexclude.txt", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
return
EndFunc

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------

; #############################
; # DISPLAY THE MUSIC PLAYER  #
; #############################

Func _MusicPlayer()
Global $MusicLister = IniRead(@ScriptDir & "\settings.ini", "options", "musiclist", "EGYaxYaxD_M&list=RDtWe19KS-i-c&index=2")
$HTMLVID = '<body style="margin: 0px; padding: 0px;"><object style="height: 100%; width: 100%; margin: 0px; padding: 0px;">' & _
        '<param name="movie" value="http://www.youtube.com/v/' & $MusicLister & '?version=4"><param name="allowFullScreen" value="true">' & _
        '<param name="allowScriptAccess" value="always"><embed src="http://www.youtube.com/v/' & $MusicLister & '?version=4" ' & _
        'type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="100%" height="100%"></object></body>'

$oIE  = _IECreateEmbedded()
GLOBAL $Form2 = GUICreate("Youtube Music Player", 624, 464, 192, 124 )
$ActiveX = GUICtrlCreateObj($oIE,0,0,624,464)
_IENavigate($oIE,"about:blank",1)
_IEBodyWriteHTML($oIE,$HTMLVID)
$oIE.document.body.scroll = "no"
GUISetState(@SW_SHOW)
EndFunc

; -------------------------------------------------------------------------------------------------------------

; #############################
; # CHECK VERSION AND ADVISE  #
; #############################

Func _VersionCheck()
; # ONLY CHECK VERSIONS IF ACTIVATED
if IniRead(@ScriptDir & "\settings.ini", "options", "checkversionon", "1") = 1 then
Local $url2, $file2, $html2 , $VersionChecked
Local $Version2 = "https://directukjobs.000webhostapp.com/index.php/version/"
$url2 = $Version2
; # TALK #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Checking software version")
; # SET FILE #
Local $file2 = @ScriptDir & "\version.html.txt"
;# PING CHECK INTERNET IS OK #
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
Local $hDownload2 = InetGet($url2, $file2, 1, 0)
; # END INTERNET CONNECTION #
InetClose($hDownload2)
; # READ FILE ON DISK DISK #
Local $html2 = FileRead($file2, FileGetSize($file2))
; # SET SETTING ZERO #
local $vi = 0
local $VersionFound =  ""
$VersionFound = StringRegExp($html2, "(?i)directukjobsversion.[a-zA-Z0-9.-]", 3)
; # TESTING #
;;;_ArrayDisplay($VersionFound, "1D display")
; # LOOP ALGO CHECK #
for $vi = 0 to UBound($VersionFound) - 1
if not $VersionFound[$vi] = "" then
Local $VersionChecked = StringTrimLeft($VersionFound[$vi],20)
Else
; Do Nothing
; # TALK #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Version Could not be found, Continuing")
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
; # READ THE INI FOR CURRENT VERSION
Local  $LocalVersion = IniRead(@ScriptDir & "\settings.ini", "options", "checkversionval", "1")
; # COMPARE VERSIONS AND ADVISE #
If  $LocalVersion <> $VersionChecked Then
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Software Update Available, A Newer version was found online")
; # PROMPT TO OPEN THE URL #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Do you want to open the downloads page?")
 ; # PROMPT USER FOR INPUT #
Local $MyBox1 = MsgBox(1, "Software Update Available","Do you want to open the downloads page?" & @CRLF & "Your Version = " & $LocalVersion & @CRLF & "New Version = " & $VersionChecked & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox1 == 1 Then ; OK CHOICE
; # TALK #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Opening Downloads Page")
; # OPEN BROWSER WITH URL #
_RunDos("start " & "https://directukjobs.000webhostapp.com/index.php/join/" ) ; Open the URL
ElseIf $MyBox1 == 2 Then ; CANCEL CHOICE
; Do nothing
EndIf
Else
; # TALK #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Software is up to date, Continuing")
Endif
Endif
EndFunc

; -------------------------------------------------------------------------------------------------------------

; #############################
; # SEND A ESCAPE KEY TO STOP #
; #############################
Func _SendStop()
Send("{ESC}")
GUICtrlSetData($Progress1, 0)
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ########################
; # Exit the Application #
; ########################
Func _exit()
GUICtrlSetData($Edit1,"Exiting..." & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Exiting")
Exit
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ################################
; # Stop the Application running # This does not seem to work
; ################################
Func _onClick()
GUICtrlSetData($Edit1,"Stop Processes..." & @CRLF & GUICtrlRead($Edit1))
;;;;If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Stopping Process") ; THIS DOES NOT WORK - TALKS TO MUCH AS IT STOPS ALL THE PROCESSES IN EXITLOOPS SLOWS DOWN
$Exitloop1 = 1 ; This sets the value to 1 so in the loops it sees the value changed and exits the loops
GUICtrlSetData($Progress1, 0) ; Set the Progress Bar to Zero
EndFunc

; -------------------------------------------------------------------------------------------------------------

; #################################################################
; # SAVE THE SETTINGS TO THE INI FILE WHEN SAVE BUTTON IS PRESSED #
; #################################################################
Func _JobSave()
GUICtrlSetData($Edit1,"Saving Settings..." & @CRLF & GUICtrlRead($Edit1)) ; This sets the status box
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Saving Settings")
;;   ConsoleWrite(GUICtrlRead($Checkbox1) & @CRLF)  ; FOR TESTING
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset1", GUICtrlRead($Input1)) ; ALGO Search Value1
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset2", GUICtrlRead($Input2)) ; ALGO Search Value2
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset3", GUICtrlRead($Input3)) ; ALGO Search Value3
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset4", GUICtrlRead($Input4)) ; ALGO Search Value4
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset5", GUICtrlRead($Input5)) ; ALGO Search Value5
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset6", GUICtrlRead($Input6)) ; ALGO Search Value6
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset7", GUICtrlRead($Input7)) ; ALGO Search Value7
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset8", GUICtrlRead($Input8)) ; ALGO Search Value8
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset9", GUICtrlRead($Input9)) ; ALGO Search Value9
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset10", GUICtrlRead($Input10)) ; ALGO Search Value10

If GUICtrlRead($Checkbox1) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset11", "1") ; Checkbox Talk Value11
If GUICtrlRead($Checkbox1) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset11", "4") ; Checkbox Talk Value11
If GUICtrlRead($Checkbox2) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset12", "1") ; Checkbox BEEP Value12
If GUICtrlRead($Checkbox2) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset12", "4") ; Checkbox BEEP Value12
If GUICtrlRead($Checkbox3) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset13", "1") ; Checkbox DEEP Value13
If GUICtrlRead($Checkbox3) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset13", "4") ; Checkbox DEEP Value13
If GUICtrlRead($Checkbox4) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset14", "1") ; Checkbox AUTO Value14
If GUICtrlRead($Checkbox4) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset14", "4") ; Checkbox AUTO Value14
If GUICtrlRead($Checkbox5) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset15", "1") ; Checkbox PING Value15
If GUICtrlRead($Checkbox5) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset15", "4") ; Checkbox PING Value15
If GUICtrlRead($Checkbox6) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset16", "1") ; Checkbox EMAIL Value16
If GUICtrlRead($Checkbox6) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset16", "4") ; Checkbox EMAIL Value16
If GUICtrlRead($Checkbox7) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset17", "1") ; Checkbox AntiVirus Value17
If GUICtrlRead($Checkbox7) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "iniset17", "4") ; Checkbox AntiVirus Value17
If GUICtrlRead($Checkbox8) = 1 then IniWrite(@ScriptDir & "\settings.ini", "options", "colab", "1") ; Checkbox Colab Value18
If GUICtrlRead($Checkbox8) = 4 then IniWrite(@ScriptDir & "\settings.ini", "options", "colab", "4") ; Checkbox Colab Value18

IniWrite(@ScriptDir & "\settings.ini", "options", "iniset20", GUICtrlRead($Input20)) ; ALGO DEEP Search Value1
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset21", GUICtrlRead($Input21)) ; ALGO DEEP Search Value2
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset22", GUICtrlRead($Input22)) ; ALGO DEEP Search Value3
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset23", GUICtrlRead($Input23)) ; ALGO DEEP Search Value4
IniWrite(@ScriptDir & "\settings.ini", "options", "iniset24", GUICtrlRead($Input24)) ; ALGO DEEP Search Value5

EndFunc

; -------------------------------------------------------------------------------------------------------------

; ########################
; # START THE PROCCESSES #
; ########################
Func _JobStartit()
local $ySize, $iBytesRead2, $iBytesRead, $iSize , $url

; ######################## ; ----------------------------------; ----------------------------------; ----------------------------------; ----------------------------------
; ######################## ; ----------------------------------; ----------------------------------; ----------------------------------; ----------------------------------
; ######################## ; ----------------------------------; ----------------------------------; ----------------------------------; ----------------------------------

; ########################

; # NOTICES OF CODER TO USER
if GUICtrlRead($Checkbox8) = 1 then
GUICtrlSetData($Edit1,"Collaboration not avalible in this version" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Collaboration not avalible in this version" & @CRLF)
Endif

; ########################

; # SET VALUES TO ZERO #
$ai = 0
$aj = 0
; # DELETE ZERO THE OLD FILEs
_FileCreate(@ScriptDir & "\algo.html.txt")
$Exitloop1 = 0 ; Set to Zero so it can start again if stopped
GUICtrlSetData($Edit1,"") ; Clears status box to start again
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Processing domain source files")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Processing domain source files..." & $ai & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Processing domain source files..." & $ai & @CRLF)
; # START PROCESSING DOMAIN LIST FILES ONLY #
; # BUILD ARRAY #
_ReadPageDomainList() ; Get the list of URL to scan for domain names and build an Array
; # TESTING #
;;;_ArrayDisplay($aArray_Domains, "DomainLists") ; This displays the arrat
; # LOOP #
for $ai = 0 to UBound($aArray_Domains) -1 ; Run though the domain list generated.
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # PROGRESS BAR #
GUICtrlSetData($Progress1, round(($ai/(UBound($aArray_Domains)-1))*100,-1)) ; This sets the progress bar to count the number of items in the array and increase as it loops
; # SQL ADD TO DOMAIN FILE #
Local $DomainFileCheck = _SQLiteSELECTDomainFileCHECKEDDB($aArray_Domains[$ai][1])
if string($DomainFileCheck) = string($aArray_Domains[$ai][1]) Then
GUICtrlSetData($Edit1,"Domain List File aready done..." & $aArray_Domains[$ai][1] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Domain List File aready done..." & $aArray_Domains[$ai][1] & @CRLF)
ExitLoop
Else
_SQLiteInsertDomainfileDB($aArray_Domains[$ai][1])
Endif
; # DISPLAY INFO #
; # This sets the staus box and shows how many domain list files are been processed
GUICtrlSetData($Edit1,"Processing domain source files " & $ai  & "/" & UBound($aArray_Domains) -1 & " - " & $aArray_Domains[$ai][1] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Processing domain source files " & $ai  & "/" & UBound($aArray_Domains) -1 & " - " & $aArray_Domains[$ai][1] & @CRLF)
;# DRUM THE BEEP #
If GUICtrlRead($Checkbox2) = 1 Then Beep(IniRead(@ScriptDir & "\settings.ini","options","freq", "400"),IniRead(@ScriptDir & "\settings.ini","options","dura", "50")) ; Beep so users know its still searching if the checkbox is valid"
; # SET FILE #
$file = @ScriptDir & "\" & $ai & ".txt" ; set the name of the file to download
if not FileExists($file) Then ; Download the file if it does not exist.
;# PING CHECK INTERNET IS OK #
if GUICtrlRead($Checkbox5) = 1 Then
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
EndIf
 ; # CHECK INET FILE SIZE TO AVOID NULL FILES #
 $ySize = InetGetSize($aArray_Domains[$ai][1]) ; This is required to ensure pages are uptodate
 If $ySize > 0 then ; If the file is bigger than 0 bytes then
; # DOWNLOAD DOMAIN FILES IF NOT PRESENT #
$hDownload = InetGet($aArray_Domains[$ai][1], $file, 1, 0) ; Download the url into a file from the domain array list if it does not exist
; # CLOSE THE INET CONNECTION #
InetClose($hDownload)
Else
; # IF THE FILE IS NULL or ZERO CREATE A BLANK FILE IN ITS PLACE #
_FileCreate($file)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Domain List URL Not Valid - Created Zero file - " & $ai & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Domain List URL Not Valid - Created Zero file - " & $ai & @CRLF)
Endif
Endif

; # CHECK FOR NEWER DOMAIN LIST FILE IF VALUE IS SWITCHED ON #
if IniRead(@ScriptDir & "\settings.ini", "options", "domainlistupdate", "1") = 1 then
; # READ FILE SIZE ON DISK DISK #
$iBytesRead = FileGetSize($file)
; # CHECK THE INTERNET FILE SIZE FOR CHANGES
$iSize = InetGetSize($aArray_Domains[$ai][1]) ; This is required to ensure pages are uptodate
if $iSize <> $iBytesRead Then ; Update the file if there is a diffrence on the internet
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("A newer Domain source file list found!, Updating")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"A newer Domain source file list found!, Updating" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("A newer Domain source file list found!, Updating" & @CRLF)
; # DOWNLOAD THE NEW FILE #
$hDownload = InetGet($aArray_Domains[$ai][1], $file, 1, 0) ; Download the url
; # CLOSE THE INET CONNECTION #
InetClose($hDownload)
EndIf
Endif

; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END OF LOOP # X2  loops
Next

; # CHECK STOP APP #
If $Exitloop1 = 0 then
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Domain Source File Processing Completed")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Domain Source File Processing Completed..." & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Domain Source File Processing Completed..." & @CRLF)

; ######################## ; ----------------------------------; ----------------------------------; ----------------------------------; ----------------------------------
; ######################## ; ----------------------------------; ----------------------------------; ----------------------------------; ----------------------------------
; ######################## ; ----------------------------------; ----------------------------------; ----------------------------------; ----------------------------------

; ########################

; # RESET THE STATUS SCREEN AS IT MAY GROW TOO LARGE
GUICtrlSetData($Edit1,"Loading next Domain, Please Wait...")

; ########################

; # START PROCESSING DOMAIN NAMES ONLY #
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Processing Domain Names")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Starting Processing of Domain Names..." & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Starting Processing of Domain Names..." & @CRLF)
Endif

; ########################

; # BUILD AN ARRAY OF THE TLDS LIST #
Local $aArrayCSV
_FileReadToArray(@ScriptDir & "\tlds.txt", $aArrayCSV)
;_FileReadToArray(@ScriptDir & "\tlds.txt", $aArrayCSV, $FRTA_COUNT, ",")
_ArrayDelete($aArrayCSV, 0)

; ########################

; ---------------------------------- LOOP 2
; ---------------------------------- LOOP
; ---------------------------------- LOOP

; # TESTING #
;_ArrayDisplay($aArrayCSV, "Display CSV")
;ConsoleWrite("TEST 1 = " & UBound($aArrayCSV) - 1 & @CRLF)
;ConsoleWrite("TEST 1 = " & $aArrayCSV[1] & @CRLF)

; # LOOP THE TLDS LIST ARRAY #
; # SET VALUES TO ZERO #
Local $csvi = 0
; # LOOP DOMAIN TLDS # BIG LOOP
for $csvi = 0 to UBound($aArrayCSV) - 1
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop

; ---------------------------------- LOOP 1
; ---------------------------------- LOOP
; ---------------------------------- LOOP

; # LOOP DOMAIN FILE LIST # BIG LOOP
; # SET VALUES TO ZERO #
$ai = 0
for $ai = 0 to UBound($aArray_Domains) - 1
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # SET VALUES TO ZERO #
$bi = 0
$domainFound =  ""
$file = ""
$html = ""
; # MISSING FILE FIX #
if FileExists(@ScriptDir & "\" & $ai & ".txt") = 0 Then
_FileCreate(@ScriptDir & "\" & $ai & ".txt")
Endif
; # SET FILE #
$file = @ScriptDir & "\" & $ai & ".txt" ; set the name of the file
; # READ FILE ON DISK DISK #
$html = FileRead($file, FileGetSize($file)) ; Read the file
; # OUT PUT THE FILE SIZE #
$iBytesRead2 = @extended

; ########################



; ########################

; # HERE WE NEED TO LOOP DIFFRENT DOMAIN EXTENTIONS SO IT WORKS WITH ANY DOMAIN FILE LISTS #

if number(IniRead(@ScriptDir & "\settings.ini", "options", "domaintldson", "0")) = 0 then
GUICtrlSetData($Edit1,"Searching single TLDS = " & IniRead(@ScriptDir & "\settings.ini", "options", "domainext", "uk") & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Searching single TLDS = " & IniRead(@ScriptDir & "\settings.ini", "options", "domainext", "uk") & @CRLF)
; # FIND DOMAIN NAMES ARRAY # THIS BUILDS THE ARRAY
;;;$domainFound = StringRegExp($html, "[a-zA-z0-9.-]+\.[a-zA-Z0-9.-]+\." & IniRead(@ScriptDir & "\settings.ini", "options", "domainext", "uk"), 3) ; Only look for . UK domains unless INI file states something else.
$domainFound = StringRegExp($html, "[a-zA-Z0-9.-]+\." & IniRead(@ScriptDir & "\settings.ini", "options", "domainext", "uk"), 3) ; Only look for . UK domains unless INI file states something else.

Else
; # FIND DOMAIN NAMES ARRAY # THIS BUILDS THE ARRAY
GUICtrlSetData($Edit1,"Searching ALL TLDS = " & $aArrayCSV[$csvi] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Searching ALL TLDS = " & $aArrayCSV[$csvi] & @CRLF)
;;;$domainFound = StringRegExp($html, "[a-zA-z0-9.-]+\.[a-zA-Z0-9.-]+\." & $aArrayCSV[$csvi], 3) ; Only look for . ALL domains unless INI file states something else.
$domainFound = StringRegExp($html, "[a-zA-Z0-9.-]+\." & $aArrayCSV[$csvi], 3) ; Only look for . ALL domains unless INI file states something else.

Endif

; ########################

;  # CHECK THE ARRAY IS VALID #
if IsArray($domainFound) = 0 Then
_ArrayAdd($domainFound,"google.com")
GUICtrlSetData($Edit1,"Domain source file no data found - " & $file & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Domain source file no data found - " & $file & @CRLF)
Endif

; ########################

; ---------------------------------- LOOP 3
; ---------------------------------- LOOP
; ---------------------------------- LOOP

; ########################
; # LOOP DOMAIN NAMES ARRAY #
for $bi = 0 to UBound($domainFound) - 1    ;  --------------------------------- > ;;; AROUND HERE WE NEED TO CHECK IF THE DOMAIN CAN BE PROCESSED FOR COLABIRATION ----------- FIX HERE
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 0)

; ########################
; BUILD AN EXLUDE LIST AND REMOVE DOMAINS FROM ARRAY
if number(IniRead(@ScriptDir & "\settings.ini", "options", "excludeon", "0")) = 1 then
if _idExcluded($domainFound[$bi]) >= 1 then
Exitloop
EndIf
EndIf

; ########################
; # SQL CHECK DB FOR DUPLICATES #
If _SQLiteDuplicateDomainDB($domainFound[$bi]) = $domainFound[$bi] then
; Do nothing if duplicate found it will be skipped from database
GUICtrlSetData($Edit1,"Domain already processed - " & $bi & "/" & UBound($domainFound) - 1 & " - " & $domainFound[$bi] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Domain already processed - " & $bi & "/" & UBound($domainFound) - 1 & " - " & $domainFound[$bi] & @CRLF)
Else ; NO DUPLICATES FOUND
   ; #DISPLAY INFO #
GUICtrlSetData($Edit1,"Processing..." & $bi & "/" & UBound($domainFound) - 1 & " - " & $domainFound[$bi] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Processing..." & $bi & "/" & UBound($domainFound) - 1  & " - " &  $domainFound[$bi] & @CRLF)

 ; -----------------------------

; # PROGRESS BAR #
GUICtrlSetData($Progress1, 10) ; Set progress bar 10% done

; -----------------------------

; ######################## STRIP THE FOUND DOMAINS AND REBUILD THEM FOR URL AND DOMAIN VARS

Local $wPosition = "" , $Findwww2 = "" , $url = "" , $NewDomainFe, $urladders1 = 0 , $urladders2 = 0, $urladders3 = 0

$url = $domainFound[$bi]
$NewDomainFe = $domainFound[$bi]

; ######################## ; THIS CODE CAN BE REDUCED AS IT DOES NOT NEED TO CHECK FOR THE STRING AND THEN - JUST REPLACE www. or http


$wPosition = StringInStr($domainFound[$bi], "https://www.")
if $wPosition >= 1 then
$NewDomainFe = StringReplace($domainFound[$bi], "https://www.","")
Endif

$wPosition = StringInStr($domainFound[$bi], "http://www.")
if $wPosition >= 1 then
$NewDomainFe = StringReplace($domainFound[$bi], "https://www.","")
Endif



$wPosition = StringInStr($domainFound[$bi], "https://")
if $wPosition >= 1 then
;;$NewDomainFe = StringTrimLeft($domainFound[$bi],8)
$NewDomainFe = StringReplace($domainFound[$bi], "https://","")
$urladders1 = 1
Endif

; ########################

$wPosition = StringInStr($domainFound[$bi], "http://")
if $wPosition >= 1 then
;;$NewDomainFe = StringTrimLeft($domainFound[$bi],7)
$NewDomainFe = StringReplace($domainFound[$bi], "http://","")
$urladders2 = 1
Endif

; ########################

$wPosition = StringInStr($domainFound[$bi], "www.")
if $wPosition >= 1 then
;;$NewDomainFe = StringTrimLeft($domainFound[$bi],7)
$NewDomainFe = StringReplace($domainFound[$bi], "www.", "")
$urladders3 = 1
Endif

; ########################

; # REBUILD THE URL THE WAY IT WAS #

if $urladders1 = 1 and $urladders3 = 0 then $url = "https://" & $NewDomainFe
if $urladders2 = 1 and $urladders3 = 0 then $url = "http://" & $NewDomainFe
if $urladders3 = 1 and $urladders1 = 0 and $urladders2 = 0 then $url = "http://www." & $NewDomainFe

if $urladders1 = 1 and $urladders3 = 1 then $url = "https://www." & $NewDomainFe
if $urladders1 = 2 and $urladders3 = 1 then $url = "http://www." & $NewDomainFe

if $urladders1 = 0 and $urladders2 = 0 and $urladders3 = 0 then $url = "http://www." & $NewDomainFe


;Local $iTimeout = 5
;MsgBox($MB_SYSTEMMODAL, "Title",@CRLF & $NewDomainFe & @CRLF & $url & @CRLF & "This message box will timeout after " & $iTimeout & " seconds or select the OK button.", $iTimeout)


; ########################

; -----------------------------

$VTAntiVirusData = ""
; # SCAN THE URL FOR VIRUSES  #
If GUICtrlRead($Checkbox7) = 1 Then

;# PING CHECK INTERNET IS OK #
if GUICtrlRead($Checkbox5) = 1 Then
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
EndIf

$VTAntiVirusData = _VTAntiVirus($url)  ; This is where it starts to check URLS and either returns OK or the url for the threat report
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 15) ; Set progress bar 15% done
If string($VTAntiVirusData) = "OK" Then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Anti-Virus has found no threats, domain " & $NewDomainFe & " is = " & $VTAntiVirusData & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Anti-Virus has found no threats, domain " & $NewDomainFe & " is = " & $VTAntiVirusData & @CRLF)
EndIf

If string($VTAntiVirusData) = "NILL" then
$VTAntiVirusData = "NILL"
EndIf

If not string($VTAntiVirusData) = "NILL" and not string($VTAntiVirusData) = "OK" then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"ALARM! ALARM! ALARM! Anti-Virus has detected Threats!, See report at = " & $VTAntiVirusData & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("ALARM! ALARM! ALARM! Anti-Virus has detected Threats!, See report at = " & $VTAntiVirusData & @CRLF)
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("VIRUS WARNING! Anti-Virus has detected Threats!, Would you like to see the report?")
; ----------------------
; # MSGBOX #
; # PROMPT USER FOR INPUT #
Local $MyBox2 = MsgBox(1, "Question","Would you like to see the Anti-virus report?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox2 == 1 Then ; OK CHOICE
; # TALK #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Opening Report Page")
; # OPEN BROWSER WITH URL #
_RunDos("start " & $VTAntiVirusData ) ; Open the URL
ElseIf $MyBox2 == 2 Then ; CANCEL CHOICE
; Do nothing
EndIf
; ----------------------
; # PROMPT USER FOR INPUT #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to mark this domain as OK")
Local $MyBox3 = MsgBox(1, "Question","Would you like to mark this domain as OK?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox3 == 1 Then ; OK CHOICE
$VTAntiVirusData = "OK"
ElseIf $MyBox3 == 2 Then ; CANCEL CHOICE
; Do nothing
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Continuing")
GUICtrlSetData($Edit1,"Domain will be recorded as bad = " & $NewDomainFe & @CRLF & GUICtrlRead($Edit1))      ; -------------- ASK IF THE SITE SHOULD BE MARKED AS BAD
ConsoleWrite("Domain will be recorded as bad = " & $NewDomainFe & @CRLF)
EndIf
; ----------------------
Endif ; end of Check if result is OK
; ----------------------
Else
$VTAntiVirusData = ""
Endif ; End of Checkbox is active for AV

; -----------------------------

; ########################

; # SQL INSERT NEW RECORD #
_SQLiteInsertDomainDB($NewDomainFe,_NowCalc(),$VTAntiVirusData) ; New Domain name found record
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"New Domain - " & $NewDomainFe & " - Recorded" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("New Domain - " & $NewDomainFe & " - Recorded" &  @CRLF)
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 20) ; Set progress bar 20% done

; ########################

; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Scanning..." & $bi & "/" & UBound($domainFound) - 1 & " - " & $NewDomainFe & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Scanning..." & $bi & "/" & UBound($domainFound) - 1  & " - " &  $NewDomainFe & @CRLF)
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))

; ########################
; ######################## CALL A FUNCTION TO CONTINUE
; ########################

; # START SCANNING THE PAGE AND COLLECT ALGO POINTS AND EMAILS #
If string($VTAntiVirusData) = "OK" or string($VTAntiVirusData) = "" Then ; The AV said its OK to continue
_AlgoSearch($url,$NewDomainFe) ; # START THE ALGO to see if there is a careers page or email
Else
; # SQL UPDATE THE OLD DOMAIN AS COMPLETED # IF VIRUS IS FOUND
_SQLiteDomainCHECKEDDB($NewDomainFe)
Endif

; # FINISHED SCANNING DOMAINS #
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Completed Processing domain - " & $NewDomainFe & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Completed Processing domain - " & $NewDomainFe & @CRLF)

EndIf ; End of check duplicate domains

; ########################
; ########################
; ########################

; ########################

; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # DRUM THE BEEP #
If GUICtrlRead($Checkbox2) = 1 Then Beep(IniRead(@ScriptDir & "\settings.ini","options","freq", "400"),IniRead(@ScriptDir & "\settings.ini","options","dura", "50"))
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 100)
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # END DOMAIN NAMES LOOP #
Next
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; ########################

; ########################

; ########################
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END Loop for TLDS #
Next ; ---------------------------------- LOOP END
; ########################

; ########################

; ########################
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
;  # SQL UPDATE # DOMAIN FILE LIST COMPLETED
_SQLiteDomainFileCHECKEDDB($aArray_Domains[$ai][1])
Next  ; Loop for TLDS

; ########################
; ########################
; ########################
; ########################

; # THIS IS THE END OF SCANNING ALL DOMAIN LIST FILES - RESTART AGAIN MAY NOT BE NEEDED OLD CODE
;;;;;;;;;;;;;_SQLiteDomainCHECKEDALLDB()
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"THE END ......" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("THE END ......" & @CRLF)
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("The End, Lekka to be Saffa!")
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
;;;;_restart() ; RESTART THE PROGRAM

; ########################

EndFunc

; -------------------------------------------------------------------------------------------------------------

; ########################
; # Read the Domain Page #
; ########################
Func _ReadPageDomainList()
; # BUILD ARRAY 2D WITH DOMAIN FILE NAMES STORED IN INI FILE #
Global $aArray_Domains = IniReadSection(@ScriptDir & "\domains.ini", "options")
_ArrayDelete($aArray_Domains, 0) ; This removed the empty space in the first record what is a count record

; ###################################################################################

;  HERE WE NEED TO CHECK WHAT FILES ARE TOO OLD AND EXCLUDED TO AVOID ANY EXTRA WORK            --------------------------------------------------- FIX HERE
;  WE ALSO NEED TO BUILD A DOMAIN DATABASE - SCAN IT FOR CHANGES AND RECORD THE ONES ALREADY SCANNED, THEN WHEN ALL DONE AND NONE LEFT WE NEED TO CLEAR ALL THE CHECKS SO IT STARTS AGAIN

; ###################################################################################
; # TESTING #
;;;_ArrayDisplay($aArray_Domains, "DomainLists") ; This displays the arrat
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ##############################################
; # Check if there are any career hits on page #
; ##############################################
Func _AlgoSearch($url,$domain)
Local $ci,$cii,$careerFound,$file1,$hDownload1,$html1,$iBytesRead1,$yPosition,$xPosition
Local $oi1,$oi2,$oi3,$oi4,$oi5,$oi6,$oi7,$oi8,$oi9,$oi10,$Findwww1,$NewDomainRe,$urlold1,$DomainOld1,$NewURL,$urlold
Global $sStatusR

; ########################

; # PROGRESS BAR #
GUICtrlSetData($Progress1, 50)
; # SET VALUES TO ZERO #
$urlold = $url ; This sets the domain before it gets process to recall later
$url = $urlold
$DomainOld1 = $domain
$NewDomainRe = $DomainOld1  ; This is the new domain name
$yPosition = 0
$Findwww1 = 0
$NewURL = $urlold
Local $RedirectD = 0
; ########################     THIS CHECK FOR REDIRECTION and STRIPS OUT THE FOUND DOMAIN between //  and /

; # CHECK THE SOURCE URL DOMAIN HAS NOT CHANGED
local $ssi = 0, $urladder1 = 0, $urladder2 = 0, $urladder3 = 0

$sStatusR = $urlold
_RedirectUrl($urlold) ; This goes and sees if the url has redirected

; # FIND THE NEW URL #
Local $aArrayNewURL = _StringBetween($sStatusR,"//","/")
; # LOOP 1 #
 for $ssi = 0 to UBound($aArrayNewURL) - 1
$RedirectD = 1
$NewURL = ""
$NewURL = $aArrayNewURL[$ssi] ; If found the new domain is collected
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # END LOOP 1 #
Next

; ######################## ; THIS CODE CAN BE REDUCED AS IT DOES NOT NEED TO CHECK FOR THE STRING - JUST REPLACE
If $RedirectD = 1 then
$yPosition = StringInStr($NewURL, "https://www.")
if $yPosition >= 1 then
$NewDomainRe = StringReplace($NewURL, "https://www.","")
Endif

$yPosition = StringInStr($NewURL, "http://www.")
if $yPosition >= 1 then
$NewDomainRe = StringReplace($NewURL, "https://www.","")
Endif

; ########################

$yPosition = StringInStr($NewURL, "https://")
if $yPosition >= 1 then
;;$NewDomainRe = StringTrimLeft($NewURL,8)
$NewDomainRe = StringReplace($NewURL, "https://","")
local $urladder1 = 1
Endif

; ########################

$yPosition = StringInStr($NewURL, "http://")
if $yPosition >= 1 then
$NewDomainRe = StringReplace($NewURL, "http://","")
;;$NewDomainRe = StringTrimLeft($NewURL,7)
local $urladder2 = 1
Endif

; ########################

$yPosition = StringInStr($NewURL, "www.")
if $yPosition >= 1 then
$NewDomainRe = StringReplace($NewURL, "www.","")
;;$NewDomainRe = StringTrimLeft($NewURL,4)
local $urladder3 = 1
Endif

; ########################

; # REBUILD THE URL THE WAY IT WAS BEFORE #

if $urladder1 = 1 and $urladder3 = 0 then $url = "https://" & $NewDomainRe
if $urladder2 = 1 and $urladder3 = 0 then $url = "http://" & $NewDomainRe
if $urladder3 = 1 and $urladder1 = 0 and $urladder2 = 0 then $url = "http://www." & $NewDomainRe

if $urladder1 = 1 and $urladder3 = 1 then $url = "https://www." & $NewDomainRe
if $urladder1 = 2 and $urladder3 = 1 then $url = "http://www." & $NewDomainRe

if $urladder1 = 0 and $urladder2 = 0 and $urladder3 = 0 then $url = "http://www." & $NewDomainRe

EndIf ; End if for redirection found fix url and domains

;Local $iTimeout = 5
;MsgBox($MB_SYSTEMMODAL, "Title",@CRLF & $NewDomainRe & @CRLF & $url & @CRLF & "This message box will timeout after " & $iTimeout & " seconds or select the OK button.", $iTimeout)

; ########################

; DISPLAY IF THERE WAS A URL FOUND TO REDIRECT and MARK OLD DOMAIN as Retired or tell the DB it was checked so no more processing

 ; # COMPARE THE URLS TO SEE IF THEY MATCH OR NOT #    -------- Small bug with false positive when some domains are the same but www in one or https in other it works but its extra work
;;;if $urlold <> $sStatusR Then ; If the url is not the same
if string($urlold) <> string($url) Then ; If the url is not the same
; # DISPLAY INFO #
;;;GUICtrlSetData($Edit1,"Redirected " & $urlold & " --> " & $sStatusR & @CRLF & GUICtrlRead($Edit1))
GUICtrlSetData($Edit1,"Redirected " & $urlold & " --> " & $url & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Redirected " & $urlold & " --> " & $url & @CRLF)
GUICtrlSetData($Edit1,"Old domain will be recorded as retired - " & $urlold & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Old domain will be recorded as retired - " & $urlold & @CRLF)
; # SQL UPDATE THE OLD URL AS COMPLETED #
_SQLiteDomainCHECKEDDB($DomainOld1)
; # TALK IF SET IN INI ABOUT REDIRECTS FOUND #
If number(IniRead(@ScriptDir & "\settings.ini","options","talkredirect", "1")) = 1 then
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("A domain redirection was found, processing new domain!")
Endif

; ########################

; ----------------------
$VTAntiVirusData = ""
; # SCAN THE URL FOR VIRUSES  #
If GUICtrlRead($Checkbox7) = 1 Then
$VTAntiVirusData = _VTAntiVirus($url)  ; This is where it starts to check URLS and either returns OK or the url for the threat report
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 60) ; Set progress bar 60% done
If string($VTAntiVirusData) = "OK" Then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Anti-Virus has found no threats, domain " & $NewDomainRe & " is = " & $VTAntiVirusData & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Anti-Virus has found no threats, domain " & $NewDomainRe & " is = " & $VTAntiVirusData & @CRLF)
; # TALK #
;If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Anti-Virus has found no threats, continuing")
;;Else
EndIf

If string($VTAntiVirusData) = "NILL" then
$VTAntiVirusData = "NILL"
EndIf

If not string($VTAntiVirusData) = "NILL" and not string($VTAntiVirusData) = "OK" then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"ALARM! ALARM! ALARM! Anti-Virus has detected Threats!, See report at = " & $VTAntiVirusData & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("ALARM! ALARM! ALARM! Anti-Virus has detected Threats!, See report at = " & $VTAntiVirusData & @CRLF)
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("VIRUS WARNING! Anti-Virus has detected Threats!, Would you like to see the report?")
; ----------------------
; # MSGBOX #
; # PROMPT USER FOR INPUT #
Local $MyBox2 = MsgBox(1, "Question","Would you like to see the Ant-Virus report?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox2 == 1 Then ; OK CHOICE
; # TALK #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Opening Report Page")
; # OPEN BROWSER WITH URL #
_RunDos("start " & $VTAntiVirusData ) ; Open the URL
ElseIf $MyBox2 == 2 Then ; CANCEL CHOICE
; Do nothing
EndIf
; ----------------------
; # PROMPT USER FOR INPUT #
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to mark this domain as OK")
Local $MyBox3 = MsgBox(1, "Question","Would you like to mark this domain as OK?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox3 == 1 Then ; OK CHOICE
$VTAntiVirusData = "OK"
ElseIf $MyBox3 == 2 Then ; CANCEL CHOICE
; Do nothing
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Continuing")
GUICtrlSetData($Edit1,"Domain will be recorded as bad = " & $NewDomainRe & @CRLF & GUICtrlRead($Edit1))      ; -------------- ASK IF THE SITE SHOULD BE MARKED AS BAD
ConsoleWrite("Domain will be recorded as bad = " & $NewDomainRe & @CRLF)
EndIf
; ----------------------
EndIf ; end of Check if result is OK
Else
$VTAntiVirusData = ""
Endif ; end of Check If Checkbox is on for Antivirus

; ########################

; # SQL DUPLCATES AND INSERT IF NEEDED #
If _SQLiteDuplicateDomainDB($NewDomainRe) = $NewDomainRe then
; Do nothing the domain already exists
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Domain from redirection already processed " & $NewDomainRe & " Continuing... " & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Domain from redirection already processed " & $NewDomainRe & " Continuing... " & @CRLF)
return ; No need to continue the domain is already done
Else
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"New domain found from redirection - " & $NewDomainRe & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("New domain found from redirection - " & $NewDomainRe & @CRLF)
_SQLiteInsertDomainDB($NewDomainRe,_NowCalc(),$VTAntiVirusData) ; New Domain name found recorded
Endif

; ########################


; EXIT FUNCTION IF VIRUS NO MORE PROCESSING #
If string($VTAntiVirusData) = "OK" or string($VTAntiVirusData) = "" then
; Continue
Else
; # SQL UPDATE THE OLD URL AS COMPLETED #
_SQLiteDomainCHECKEDDB($NewDomainRe)
; # RETURN #
Return ; If the AV found something other than OK or "" nothing return so the domain / url is not processed
Endif

; ########################

else
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"No redirection found for domain, continuing... " & $NewDomainRe & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("No redirection found for domain, continuing... " & $NewDomainRe & @CRLF)
Endif ; If the url and domain not the same

; ########################

; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Checking url " & $url & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Checking url " & $url & @CRLF)
; # SET FILE #
$file1 = @ScriptDir & "\algo.html.txt"
;# PING CHECK INTERNET IS OK #
if GUICtrlRead($Checkbox5) = 1 Then
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
EndIf
; # DOWNLOAD THE FILE #
$hDownload1 = InetGet($url, $file1, 1, 0)
; # END INTERNET CONNECTION #
InetClose($hDownload1)
; # READ FILE ON DISK DISK #
$html1 = FileRead($file1, FileGetSize($file1))
; # GET THE BYTE SIZE OF FILE #
$iBytesRead1 = @extended
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"File Size = " & $iBytesRead1 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("File Size = " & $iBytesRead1  & @CRLF)

; ########################

; # IF FILE NOT VALID #
if $iBytesRead1 = 0 then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Webpage Not Valid - Updating Record -  " & $NewDomainRe & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Webpage Not Valid - Updating Record -  " & $NewDomainRe & @CRLF)
; # SQL UPDATE # Domain not valid reading is zero
_SQLiteDomainNotValidDB($NewDomainRe)
Else ; If it is valid contine
; # SQL UPDATE # Domain IS VALID
_SQLiteDomainValidDB($NewDomainRe)

; -------------------------------------------------------------META WORK HERE

; ########################
; # DO THE META WORK HERE
Local $MetaExcludeFound = 0
Local $MetaIncludeFound = 0

if number(IniRead(@ScriptDir & "\settings.ini", "options", "ExcludeONLYMeta", "0")) = 1 then
$MetaExcludeFound = _idMETAExcluded($html1)
If $MetaExcludeFound = 0 Then
; Continue and do nothing
Else
return
Endif
Endif

if number(IniRead(@ScriptDir & "\settings.ini", "options", "IncludeONLYMeta", "0")) = 1 then
$MetaIncludeFound = _idMETAIncluded($html1)
If $MetaIncludeFound = 0 Then
return
Else
; Comtinue
Endif
Endif

; -------------------------------------------------------------

; ########################
; # BUILD A ARRAY OF FOUND URLS WITH ALGO # Called Later with _JobUrlfound Function ALGO SEATCH STARTS HERE
; ########################

Global $aArray_BaseFound[0]
Global $aArrayAlgoFound = $aArray_BaseFound
Local $IfoundALink, $TotalfoundALink
$IfoundALink = 0
$TotalfoundALink = 0

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input1) = "" then
$ci = 0
$cii = 0
$oi1 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input1), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi1 = $oi1 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT # THIS CHECKS LINKS IF THEY HAVE ANY ALGOS in Them
If $oi1 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input1),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input2) = "" then
$ci = 0
$oi2 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input2), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi2 = $oi2 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi2 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input2),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input3) = "" then
$ci = 0
$oi3 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input3), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi3 = $oi3 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi3 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input3),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input4) = "" then
$ci = 0
$oi4 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input4), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi4 = $oi4 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi4 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input4),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input5) = "" then
$ci = 0
$oi5 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input5), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi5 = $oi5 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi5 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input5),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input6) = "" then
$ci = 0
$oi6 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input6), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi6 = $oi6 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi6 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input6),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input7) = "" then
$ci = 0
$oi7 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input7), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi7 = $oi7 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi7 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input7),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input8) = "" then
$ci = 0
$oi8 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input8), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi8 = $oi8 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi8 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input8),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input9) = "" then
$ci = 0
$oi9 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input9), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi9 = $oi9 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # SEE WHAT I FOUND ARRAY INSERT PROMPT DISPLAY CALL FUNCTION #
If $oi9 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input9),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # CHECK ALGO INPUT SETTING #
If not GUICtrlRead($Input10) = "" then
$ci = 0
$oi10 = 0
$careerFound =  ""
$careerFound = StringRegExp($html1, "(?i)" & GUICtrlRead($Input10), 3)
; # LOOP ALGO CHECK #
for $ci = 0 to UBound($careerFound) - 1
if not $careerFound[$ci] = "" then
; # ALGO COUNTER = #
$cii = $cii + 1 ; Build the number of alerts for careers
$oi10 = $oi10 + 1
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; # WHAT I FOUND ARRAY INSERT #
If $oi10 > 0 then
$IfoundALink = _JobUrlfound($html1,GUICtrlRead($Input10),$url,$NewDomainRe)
$TotalfoundALink = number($TotalfoundALink) + number($IfoundALink)
Endif

; ########################

; # FIND EMAIL ADDRESSES # IF SELECTED CHECK BOX IT WILL Store the found email and domain it was found in the DB
Local $EmailCount = 0
; # IF CHECKBOX ACTIVE #
If GUICtrlRead($Checkbox6) = 1 then ; IF EMAIL CHECK IS SELECTED DO ELSE SKIP
; # IF WEBPAGE IS VALID AND ALGO LARGER THAN 0 # To get all emails "@" needs to be entered in one of the fields
if not $iBytesRead1 = 0 and $cii > 0 then
; # SET SETTINGS TO ZERO #
$ci = 0
; # BUILD AN ARRAY WITH FOUND EMAILS #
$EmailFound = StringRegExp($html1, "[A-Za-z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}", 3)
; # LOOP EMAILS FOUND #
for $ai = 0 to UBound($EmailFound) - 1
; # AVOID STRANGE EMAILS  # ; example filenames with @ sign needs to be added here
$varright = StringRight($EmailFound[$ci], 4)
If $varright = """@" or $varright = ";@" or $varright = ">@<" or $varright = "(@" or $varright = "@)" or $varright = ".png" or $varright = ".jpg" or $varright = ".pdf" or $varright = ".xls" or $varright = ".txt" or $varright = ".EXE" or $varright = ".bat" or $varright = ".vbs" or $varright = ".doc" or $varright = ".bmp" or $varright = "html" or $varright = ".php" Then
	;Do Nothing These are not valid emails but files with @ signs in them
 Else ; If files are valid continue
; # SQL CHECK DUPLICATES #
If _SQLiteDuplicateEmailDB($EmailFound[$ci]) = $EmailFound[$ci] then
; Do Nothing if duplicate found
Else
; # SQL INSERT NEW EMAIL #
_SQLiteInsertEmailDB($NewDomainRe,$EmailFound[$ci])
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"New Email Captured - " & $EmailFound[$ci] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("New Email Captured - " & $EmailFound[$ci] & @CRLF)
;_TalkOBJ('New Email found')
EndIf
Endif
; Count the amount of emails captured
$EmailCount = $EmailCount + 1
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
EndIf
EndIf

; ########################

; # WHEN MATCH IS FOUND FOR ALGO S # ALERT USER AND ASK FOR TASKS   -------------------------------------- HERE WE NEED TO SET A MSBOX TIMMER AND INI SETTING FOR CLOSE DIALOG OR OPEN URL AND TIMMER ON OFF

if string($cii) = "" then $cii = 0
if not $cii = 0 then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Careers Match Found in = " & $url  & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Careers Match Found in = " & $url  & @CRLF)
; # TALK #
GUICtrlSetData($Edit1,"Alert, Alert, Alert!" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Alert, Alert, Alert!")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Match Found, The Searching Algo Points found " & $cii & " times" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Match Found, The Searching Algo Points found " & $cii & " times")

; ########################

Local $PressCancel = 0  ; This setting tells the app to show links if msgbox press ok or cancel
; # DISPLAY IF THE INI IS SET TO 1 #
if number(IniRead(@ScriptDir & "\settings.ini","options","foundalgoshow", "1")) = 1 then
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to open the URL?")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Do you want to open the URL?" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Do you want to open the URL?" & @CRLF)
; # MSGBOX #
; # PROMPT USER FOR IMPUT #
$MyBox = MsgBox(1, "Do you want to open the URL?",$url & @CRLF & "Total Algo Hits = " & $cii & _
@CRLF & "Links with Algos = " & $TotalfoundALink & _
@CRLF & "Emails Captured = " & $EmailCount & _
@CRLF & @CRLF & GUICtrlRead($Input1) & " = " & $oi1 & _
@CRLF & GUICtrlRead($Input2) & " = " & $oi2 & _
@CRLF & GUICtrlRead($Input3) & " = " & $oi3 & _
@CRLF & GUICtrlRead($Input4) & " = " & $oi4 & _
@CRLF & GUICtrlRead($Input5) & " = " & $oi5 & _
@CRLF & GUICtrlRead($Input6) & " = " & $oi6 & _
@CRLF & GUICtrlRead($Input7) & " = " & $oi7 & _
@CRLF & GUICtrlRead($Input8) & " = " & $oi8 & _
@CRLF & GUICtrlRead($Input9) & " = " & $oi9 & _
@CRLF & GUICtrlRead($Input10) & " = " & $oi10)
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox == 1 Then ; OK CHOICE
$PressCancel = 1
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Opening URL")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Opening URL " & $url & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Opening URL " & $url & @CRLF)
; # OPEN BROWSER WITH URL #
_RunDos("start " & $url) ; Open the URL
; # DISPLAY IF THE INI IS SET TO 1 # (ADVERTISING Can be switched ON or OFF)
if number(IniRead(@ScriptDir & "\settings.ini","options","submitpageshow", "1")) = 1 then
;_RunDos("start https://directukjobs.000webhostapp.com/index.php/please/") ; Open the URL of the SUBMIT Page in directUKjobs ; postajobURL
;_RunDos("start https://directukjobs.000webhostapp.com/index.php/submit/") ; Open the URL of the SUBMIT Page in directUKjobs ; postajobURL
_RunDos("start " & IniRead(@ScriptDir & "\settings.ini","options","postajobURL", "https://directukjobs.000webhostapp.com/index.php/submit/"))
Endif
ElseIf $MyBox == 2 Then ; CANCEL CHOICE
; Do nothing
$PressCancel = 0
EndIf

EndIf ; End if INI set to show msgbox algo found

; ########################

; #  HERE WE SHOULD ASK THE USER IF THEY WANT TO SCAN THIS PAGE IN THE FUTURE for false positives SQL MARK NO with number code
; # This should be recorded as some sites are ugly and could be a sale to upgrade

; We should also explore found links for domains to scan as secondry posible places for UK domains not neccecrly ,uk or other
; This should be in the links page but we have to set the also as special zero and a check ini if we want to do that

; ########################

; # SEE LINKS FOUND #
If number($TotalfoundALink) > 0 and number($PressCancel) = 1 then
; # DISPLAY IF THE INI IS SET TO 1 #
If number(IniRead(@ScriptDir & "\settings.ini","options","foundalgolinksshow", "1")) = 1 then
; # ASK IF THE USER WANTS TO SEE IF THERE WERE ANY ALGO HITS ON LINKS AND IF THEY WANT TO SEE IT #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Would you like to see what URL links I've found?")
; # MSGBOX #
; # PROMPT USER FOR IMPUT #
$MyBox = MsgBox(1, "Question!","Would you like to see what URL links I've found?")
If $MyBox == 1 Then ; OK CHOICE
$PressCancel = 1
ConsoleWrite("Opening URL links I found " & $url & @CRLF)
; # DISPLAY THE DATA FOUND #
_ArrayDisplay($aArrayAlgoFound, "Career links found")
ElseIf $MyBox == 2 Then ; CANCEL CHOICE
$PressCancel = 0
; Do nothing
EndIf
Endif ; End if ini set to show

; ########################

if number($TotalfoundALink) <= 0 then ;;;or string($IfoundALink) = "" then
; # WHEN NO LINKS FOUND SAY SO
If number(IniRead(@ScriptDir & "\settings.ini","options","talksorrynolinks", "1")) = 1 then
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("I am sorry, There are no Algos in any Url links for this Domain. Continuing")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"No Algos in any Url Links found - " & $url & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("No Algos in any Url Links found - " & $url & @CRLF)
Endif
Endif

Endif ; end of links found

; ########################

; # SEE EMAILS FOUND #
if number(IniRead(@ScriptDir & "\settings.ini","options","showemailfoundON", "1")) = 1 then
; # SHOW THE EMAILS FOUND           ------------------------------------- FIX HERE TO ASK IF ACTIVE EMAIL SEARCH TO SHOW THE EMAILS WITH ANOTHER MSGBOX  ----------------- FIX
; ALSO FIX IF THERE IS NO EMAIL INSIDE
If number($EmailCount) > 0 and number(GUICtrlRead($Checkbox6)) = 1 then
;;;If number($EmailCount) > 0 and number($PressCancel) = 1 and number(GUICtrlRead($Checkbox6)) = 1 then
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Here are the emails I found!")
ConsoleWrite("Showing Emails found for - " & $url & @CRLF)
; # Fetch the array of found emails
Local $aArrayAlgoFoundEmail = _SQLiteSelectEmailDB($NewDomainRe)
_ArrayDisplay($aArrayAlgoFoundEmail, "Found Emails for domain")
EndIf
EndIf

; ########################

; # ASK THE USER IF THEY WANT TO EMAIL THEIR RESUME TO THE COMPANY  --- TO DO

; ########################

Else         ;;;           -------------------------------------------------------- FIX HERE MAY BE PROBLEM AFTER FINDING ALGOS BUT STILL SAYS NON FOUND

; THIS IS DISABLED AS ITS TOO MUCH TALKING
;if number($IfoundALink) >= 0 then ;;; or string($IfoundALink) = "" then
;; # WHEN NO LINKS FOUND SAY SO
;If number(IniRead(@ScriptDir & "\settings.ini","options","talksorrynolinks", "1")) = 1 then
;If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("I am sorry, There are no Algos in any Url links for this Domain. Continuing")
;; # DISPLAY INFO #
GUICtrlSetData($Edit1,"No Algos were found in - " & $url & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("No Algos were found in - " & $url & @CRLF)
;Endif
;Endif

Endif ; end of algo found

; ########################

; # SQL UPDATE DOMAIN AS CHECKED #
_SQLiteDomainCHECKEDDB($NewDomainRe)

; ########################

; # START THE DEEP  #   NOT AVALIBLE AT THE MOMENT
If GUICtrlRead($Checkbox3) = 1 then
;;;_DeepSearch($NewDomainRe,$url,$html1)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Deep Search Not Avalible in this version" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Deep Search Not Avalible in this version" & @CRLF)
Endif

; ########################

Endif ; End if file is valid the html what was read

; ########################

; # DELETE ZERO THE OLD FILE
_FileCreate($file1)

; ########################
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))

EndFunc

; -------------------------------------------------------------------------------------------------------------

; #####################
; # TALKING FUNCTIONS #
Func _TalkOBJ($s_text)
Global $voice = ObjCreate("SAPI.SpVoice")
;;;	If Not IsObj($voice) Then Exit MsgBox(0, "TTS Error", "Could not start SAPI services, please make sure they are installed!") ; Old Code
    If Not IsObj($voice) Then
    GUICtrlSetData($Edit1,$Edit1 & "TTS Error Could not start SAPI services, please make sure they are installed!" & @CRLF)
	ConsoleWrite("TTS Error Could not start SAPI services, please make sure they are installed!" & @CRLF)
	Else
    $voice.Volume = 100
    $voice.Speak($s_text, 11)
    $voice.WaitUntilDone(-1)
    $voice = ""
	Endif
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
 EndFunc

; -------------------------------------------------------------------------------------------------------------

; DEEP SEARCH
 ; ######################################
; # Start the page deep search for jobs #
Func _DeepSearch($domain2,$url2, $html2)

; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Deep Search not avalible in this version" & @CRLF)

return
Local $domain2,$url2, $html2, $dscii = 0, $DeepSearchFound, $dsci

; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Deep Search Active Scanning found algo URL - " & $url2 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Deep Search Active Scanning found algo URL - " & $url2 & @CRLF)
; # TALK #
;;;If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Deep Search Completed!")

; ########################

; # CHECK ALGO INPUT SETTING # INPUT 20
If not GUICtrlRead($Input20) = "" then
Local $dsi20 = 0
$dsci = 0
$DeepSearchFound =  ""
$DeepSearchFound = StringRegExp($html2, "(?i)" & GUICtrlRead($Input20), 3)
; # LOOP ALGO CHECK #
for $dsci = 0 to UBound($DeepSearchFound) - 1
if not $DeepSearchFound[$dsci] = "" then
; # ALGO COUNTER = #
$dscii = $dscii + 1 ; Build the number of TOTAL Algo HITS
$dsi20 = $dsi20 + 1 ; The Number of hits for this Algo
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; ########################

; # CHECK ALGO INPUT SETTING # INPUT 21
If not GUICtrlRead($Input21) = "" then
Local $dsi21 = 0
$dsci = 0
$DeepSearchFound =  ""
$DeepSearchFound = StringRegExp($html2, "(?i)" & GUICtrlRead($Input21), 3)
; # LOOP ALGO CHECK #
for $dsci = 0 to UBound($DeepSearchFound) - 1
if not $DeepSearchFound[$dsci] = "" then
; # ALGO COUNTER = #
$dscii = $dscii + 1 ; Build the number of TOTAL Algo HITS
$dsi21 = $dsi21 + 1 ; The Number of hits for this Algo
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; ########################

; # CHECK ALGO INPUT SETTING # INPUT 22
If not GUICtrlRead($Input22) = "" then
Local $dsi22 = 0
$dsci = 0
$DeepSearchFound =  ""
$DeepSearchFound = StringRegExp($html2, "(?i)" & GUICtrlRead($Input22), 3)
; # LOOP ALGO CHECK #
for $dsci = 0 to UBound($DeepSearchFound) - 1
if not $DeepSearchFound[$dsci] = "" then
; # ALGO COUNTER = #
$dscii = $dscii + 1 ; Build the number of TOTAL Algo HITS
$dsi22 = $dsi22 + 1 ; The Number of hits for this Algo
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; ########################

; # CHECK ALGO INPUT SETTING # INPUT 23
If not GUICtrlRead($Input23) = "" then
Local $dsi23 = 0
$dsci = 0
$DeepSearchFound =  ""
$DeepSearchFound = StringRegExp($html2, "(?i)" & GUICtrlRead($Input23), 3)
; # LOOP ALGO CHECK #
for $dsci = 0 to UBound($DeepSearchFound) - 1
if not $DeepSearchFound[$dsci] = "" then
; # ALGO COUNTER = #
$dscii = $dscii + 1 ; Build the number of TOTAL Algo HITS
$dsi23 = $dsi23 + 1 ; The Number of hits for this Algo
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; ########################

; # CHECK ALGO INPUT SETTING # INPUT 24
If not GUICtrlRead($Input24) = "" then
Local $dsi24 = 0
$dsci = 0
$DeepSearchFound =  ""
$DeepSearchFound = StringRegExp($html2, "(?i)" & GUICtrlRead($Input24), 3)
; # LOOP ALGO CHECK #
for $dsci = 0 to UBound($DeepSearchFound) - 1
if not $DeepSearchFound[$dsci] = "" then
; # ALGO COUNTER = #
$dscii = $dscii + 1 ; Build the number of TOTAL Algo HITS
$dsi24 = $dsi24 + 1 ; The Number of hits for this Algo
Else
; Do Nothing
Endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # END LOOP #
Next
Endif

; ########################
; ########################
; ########################
; ########################

; # WHEN MATCH IS FOUND FOR ALGO S # ALERT USER AND ASK FOR TASKS   -------------------------------------- HERE WE NEED TO SET A MSBOX TIMMER AND INI SETTING FOR CLOSE DIALOG OR OPEN URL AND TIMMER ON OFF

if string($cii) = "" then $cii = 0
if not $cii = 0 then
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Careers Match Found in = " & $url  & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Careers Match Found in = " & $url  & @CRLF)
; # TALK #
GUICtrlSetData($Edit1,"Alert, Alert, Alert!" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Alert, Alert, Alert!")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Match Found, The Careers Algo Points found " & $cii & " times" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Match Found, The Careers Algo Points found " & $cii & " times")

; ########################

Local $PressCancel = 0  ; This setting tells the app to show links if msgbox press ok or cancel
; # DISPLAY IF THE INI IS SET TO 1 #
if number(IniRead(@ScriptDir & "\settings.ini","options","foundalgoshow", "1")) = 1 then
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to open the URL?")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Do you want to open the URL?" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Do you want to open the URL?" & @CRLF)
; # MSGBOX #
; # PROMPT USER FOR IMPUT #
$MyBox = MsgBox(1, "Do you want to open the URL?",$url & @CRLF & "Total Algo Hits = " & $cii & _
@CRLF & "Links with Algos = " & $TotalfoundALink & _
@CRLF & "Emails Captured = " & $EmailCount & _
@CRLF & @CRLF & GUICtrlRead($Input1) & " = " & $oi1 & _
@CRLF & GUICtrlRead($Input2) & " = " & $oi2 & _
@CRLF & GUICtrlRead($Input3) & " = " & $oi3 & _
@CRLF & GUICtrlRead($Input4) & " = " & $oi4 & _
@CRLF & GUICtrlRead($Input5) & " = " & $oi5 & _
@CRLF & GUICtrlRead($Input6) & " = " & $oi6 & _
@CRLF & GUICtrlRead($Input7) & " = " & $oi7 & _
@CRLF & GUICtrlRead($Input8) & " = " & $oi8 & _
@CRLF & GUICtrlRead($Input9) & " = " & $oi9 & _
@CRLF & GUICtrlRead($Input10) & " = " & $oi10)
; # SELECTED CHOICES FROM MSGBOX #
If $MyBox == 1 Then ; OK CHOICE
$PressCancel = 1
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Opening URL")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Opening URL " & $url & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Opening URL " & $url & @CRLF)
; # OPEN BROWSER WITH URL #
_RunDos("start " & $url) ; Open the URL
; # DISPLAY IF THE INI IS SET TO 1 #
if number(IniRead(@ScriptDir & "\settings.ini","options","submitpageshow", "1")) = 1 then
_RunDos("start https://directukjobs.000webhostapp.com/index.php/please/") ; Open the URL of the SUBMIT Page in directUKjobs
endif
ElseIf $MyBox == 2 Then ; CANCEL CHOICE
; Do nothing
$PressCancel = 0
EndIf
EndIf
EndIf ; End if INI set to show msgbox algo found

; ########################
; ########################
; ########################
; ########################

; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ CREATE THE DATABASE IF NOT THERE ################
Func _SQLiteCreateDB()
_SQLite_Startup ()
If @error Then
    MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite.dll Can't be Loaded!")
    Exit -1
 EndIf
 ; # TESTING #
;;ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQLite_Exec (-1, "CREATE TABLE tblSpiderDomain (domain,dated,checked,valid,exclude,antivirus);") ; CREATE a Table
_SQLite_Exec (-1, "CREATE TABLE tblSpiderEmail (domain,email);") ; CREATE a Table
_SQLite_Exec (-1, "CREATE TABLE tblSpiderLinks (domain,link,dated,valid,checked);") ; CREATE a Table
_SQLite_Exec (-1, "CREATE TABLE tblSpiderDomainfile (domainfile,dated,valid,checked);") ; CREATE a Table
_SQLite_Exec (-1, "CREATE TABLE tblSpiderDeepLinks (domain,link,dated,valid,checked);") ; CREATE a Table
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------


; ############ UPDATE CHECKED domainfile IN THE DATABASE #########
Func _SQLiteDomainFileCHECKEDDB($domfile)
Local $text
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($domfile, "'", "''")
_SQLite_Exec (-1, "UPDATE tblSpiderDomainfile SET checked = '1' WHERE domainfile = '" & $text & "';")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ SELECT CHECKED domainfile IN THE DATABASE #########
Func _SQLiteSELECTDomainFileCHECKEDDB($domfile)
Local $text, $hQuery, $aRow, $srow1
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($domfile, "'", "''")
_SQlite_Query (-1, "SELECT * FROM tblSpiderDomainfile WHERE checked = '1' AND domainfile = '" & $text & "';", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()
Return $srow1
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ INSERT Found Domain file urls THE DATABASE #########
Func _SQLiteInsertDomainfileDB($domainfile)
Local $text, $hQuery, $aRow, $srow1
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($domainfile, "'", "''")
_SQlite_Query (-1, "SELECT domainfile FROM tblSpiderDomainfile WHERE domainfile = '" & $text & "';", $hQuery)

While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
WEnd
_SQLite_QueryFinalize($hQuery)

If $srow1 = "" Then
_SQLite_Exec (-1, "INSERT INTO tblSpiderDomainfile(domainfile,dated,valid,checked) VALUES ('" & $text & "','" & _Now() & "','1','0');")
Endif

;_SQLite_Exec (-1, "IF NOT EXISTS (SELECT domainfile FROM tblSpiderDomainfile WHERE domainfile = '" & $text & "') THEN INSERT INTO tblSpiderDomainfile(domainfile) VALUES ('" & $text & "');")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ##############
; # SQL DELETE #
; ############## Drop the AGED Domain FROM DATABASE #########
Func _idEraseDatedDomain()
Local $text, $hQuery, $aRow, $srow1, $srow2, $srow3
;;;Local $iDateDELCalc = _DateDiff('D',$sStringJSON1, _NowCalc())
; # PROMPT USER FOR IMPUT #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to remove the DATED domains and Links in the database?")
Local $MyBoxDel = MsgBox(1, "WARNING QUESTION?","Do you want to remove the DATED domains and Links in the database?")
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxDel == 1 Then ; OK CHOICE
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Dated Database domains and links will be removed")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Removed Dated Domains and Links in the Database" & @CRLF & GUICtrlRead($Edit1))
ElseIf $MyBoxDel == 2 Then ; CANCEL CHOICE
Return
EndIf
; # SQL DELETE #
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
 ;;;SELECT julianday('now') - julianday(DateCreated) FROM Payment;
;_SQLite_Exec (-1, "DELETE * FROM tblSpiderDomain WHERE julianday('" & _NowCalc() & "') - julianday(dated) > '" & number(IniRead(@ScriptDir & "\settings.ini","options","datediff", "30")) & "' ;")
_SQlite_Query (-1, "SELECT * FROM tblSpiderDomain ;", $hQuery)
;_SQlite_Query (-1, "SELECT * FROM tblSpiderDomain WHERE julianday(dated) > julianday('" & _NowCalc() & "')  -1;", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0] ; Domain
$srow2 = $aRow[1] ; Date
$srow3 = $aRow[2] ; Checked
;ConsoleWrite("Data =" & $srow1 & " - " & $srow2 & " - " & $srow3 & @CRLF)
Local $iDateCalcDEL = _DateDiff('D',$srow2, _NowCalc())
;ConsoleWrite("Data Diff =" & $iDateCalcDEL & @CRLF)
If number($iDateCalcDEL ) >= number(IniRead(@ScriptDir & "\settings.ini","options","datediff", "30")) then
_SQLite_Exec (-1, "DELETE FROM tblSpiderDomain WHERE domain = '" &  $srow1 & "';")
_SQLite_Exec (-1, "DELETE FROM tblSpiderLinks WHERE domain = '" &  $srow1 & "';")
GUICtrlSetData($Edit1,"Removed Dated Domains = "  &  $srow1 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Removed Dated Domains = " & $srow1 & @CRLF)
Endif
WEnd
_SQLite_QueryFinalize($hQuery)

_SQLite_Close()
_SQLite_Shutdown()
GUICtrlSetData($Edit1,"Removed Dated Domains and Links completed" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Removed Dated Domains and Links completed" & @CRLF)
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ##############
; # SQL DELETE #
; ############ Drop the Domain DATABASE #########
Func _idDropDomainDB()
; # PROMPT USER FOR IMPUT #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to remove the domain processed database?")
Local $MyBoxDel = MsgBox(1, "WARNING QUESTION?","Do you want to remove the domain processed database?")
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxDel == 1 Then ; OK CHOICE
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Database will be removed")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Removed Domain Processed Database" & @CRLF & GUICtrlRead($Edit1))
ElseIf $MyBoxDel == 2 Then ; CANCEL CHOICE
Return
EndIf
; # SQL DELETE #
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQLite_Exec (-1, "DELETE FROM tblSpiderDomain;")
_SQLite_Close()
_SQLite_Shutdown()
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ Drop the Domain FileLIST DATABASE #########
Func _idDropFileListDB()
; # PROMPT USER FOR IMPUT #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to remove the domain file list database?")
Local $MyBoxDel = MsgBox(1, "WARNING QUESTION?","Do you want to remove the domain file listdatabase?")
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxDel == 1 Then ; OK CHOICE
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Database will be removed")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Removed Domain file list Database" & @CRLF & GUICtrlRead($Edit1))
ElseIf $MyBoxDel == 2 Then ; CANCEL CHOICE
Return
EndIf
; # SWL DELETE #
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQLite_Exec (-1, "DELETE FROM tblSpiderDomainfile;")
_SQLite_Close()
_SQLite_Shutdown()
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ Drop the Email DATABASE #########
Func _idDropEmailDB()
; # PROMPT USER FOR IMPUT #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to remove the Email processed database?")
Local $MyBoxDel = MsgBox(1, "WARNING QUESTION?","Do you want to remove the Email processed database?")
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxDel == 1 Then ; OK CHOICE
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Database will be removed")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Removed Email Processed Database" & @CRLF & GUICtrlRead($Edit1))
ElseIf $MyBoxDel == 2 Then ; CANCEL CHOICE
Return
EndIf
; # SWL DELETE #
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQLite_Exec (-1, "DELETE FROM tblSpiderEmail;")
_SQLite_Close()
_SQLite_Shutdown()
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ Drop the Links DATABASE #########
Func _idDropLinksDB()
; # PROMPT USER FOR IMPUT #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Do you want to remove the Links processed database?")
Local $MyBoxDel = MsgBox(1, "WARNING QUESTION?","Do you want to remove the Links processed database?")
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxDel == 1 Then ; OK CHOICE
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Database will be removed")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Removed Links Processed Database" & @CRLF & GUICtrlRead($Edit1))
ElseIf $MyBoxDel == 2 Then ; CANCEL CHOICE
Return
EndIf
; # SWL DELETE #
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQLite_Exec (-1, "DELETE FROM tblSpiderLinks;")
_SQLite_Close()
_SQLite_Shutdown()
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ INSERT Domain links URLS into THE DATABASE #########
Func _SQLiteInsertDomainLinksDB($domain1,$foundlinks)
Local $text, $text1
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($domain1, "'", "''")
$text1 = StringReplace($foundlinks, "'", "''")
_SQLite_Exec (-1, "INSERT INTO tblSpiderLinks(domain,link,dated,valid,checked) VALUES ('" & $text & "','" & $text1 & "','" & _Now() & "','0','0');")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ SELECT THE EMAILS FOUND FOR THE DOMAIN IN THE DATABASE ######### BUILD ARRAYS
Func _SQLiteSelectEmailDB($domain)
Local $hQuery, $aRow, $srow1, $text

; # BUILD THE ARRAY #
Global $aArray_EmailINDomain[0]
Global $aArrayDomainEmail = $aArray_EmailINDomain

; # CHECK WE DONT HAVE AN OLD ARRAY IN THE WORKS #
if IsArray($aArrayDomainEmail) = 1 then
_ArrayDelete($aArrayDomainEmail, $aArray_EmailINDomain)
Endif

$srow1 = ""
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($domain, "'", "''")
_SQlite_Query (-1, "SELECT DISTINCT email FROM tblSpiderEmail WHERE domain = '"& $text & "';", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = ""
$srow1 = $aRow[0]
; # INSERT THE EMAIL FOUND IN ARRAY
_ArrayAdd($aArrayDomainEmail,$srow1)
;;;ConsoleWrite($aRow[0] & @CRLF)
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()

if IsArray($aArrayDomainEmail) = 1 then
return $aArrayDomainEmail
Endif

if IsArray($aArrayDomainEmail) = 0 then
_ArrayAdd($aArrayDomainEmail,"NO EMAIL FOUND")
Endif

EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ FIND DUPLICATED EMAIL SPIDERED IN THE DATABASE #########
Func _SQLiteDuplicateEmailDB($url)
Local $hQuery, $aRow, $srow1, $text
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($url, "'", "''")
_SQlite_Query (-1, "SELECT email FROM tblSpiderEmail WHERE email = '"& $text & "';", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
;;;ConsoleWrite($aRow[0] & @CRLF)
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()
return $srow1
EndFunc

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------

; ############ OUTPUT DOMAINS TO FILE FROM DATABASE #########
Func _idExportDomain2file()
Local $hQuery, $aRow, $srow1
; --------------------------
; # CHECK IF THE FILE EXISTS AND IF THE USER WANTS TO CLEAR IT OUT
If FileExists(@ScriptDir & "\domainsexport.csv") Then
; # MSGBOX #
ConsoleWrite("Would you like to erase the current export file" & @CRLF)
GUICtrlSetData($Edit1,"Would you like to erase the current export file" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to erase the current export file")
Local $MyBoxEXPORT = MsgBox(1, "Question","Would you like erase the current export file?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxEXPORT == 1 Then ; OK CHOICE
; # TALK #
ConsoleWrite("Erasing File domainsexport.csv" & @CRLF)
GUICtrlSetData($Edit1,"Erasing File domainsexport.csv" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Erasing File")
_FileCreate("domainsexport.csv")
ElseIf $MyBoxEXPORT == 2 Then ; CANCEL CHOICE
; Do nothing
ConsoleWrite("Domains will be added to the file domainsexport.csv" & @CRLF)
GUICtrlSetData($Edit1,"Domains will be added to the file domainsexport.csv" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Domains will be added to the file")
EndIf
EndIf
; --------------------------
Local $hFileEXPORTOpen = @ScriptDir & "\domainsexport.csv"
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQlite_Query (-1, "SELECT DISTINCT domain FROM tblSpiderDomain;", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
FileWriteLine($hFileEXPORTOpen,$srow1 & ",")
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()
FileClose ( "$hFileEXPORTOpen" )
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe domainsexport.csv", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------

; ############ OUTPUT EMAILS TO FILE FROM DATABASE #########
Func _idExportEmail2file()
Local $hQuery, $aRow, $srow1
; --------------------------
; # CHECK IF THE FILE EXISTS AND IF THE USER WANTS TO CLEAR IT OUT
If FileExists(@ScriptDir & "\emailsexport.csv") Then
; # MSGBOX #
ConsoleWrite("Would you like to erase the current export file" & @CRLF)
GUICtrlSetData($Edit1,"Would you like to erase the current export file" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to erase the current export file")
Local $MyBoxEXPORT = MsgBox(1, "Question","Would you like erase the current export file?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxEXPORT == 1 Then ; OK CHOICE
; # TALK #
ConsoleWrite("Erasing File emailsexport.csv" & @CRLF)
GUICtrlSetData($Edit1,"Erasing File emailsexport.csv" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Erasing File")
_FileCreate("emailsexport.csv")
ElseIf $MyBoxEXPORT == 2 Then ; CANCEL CHOICE
; Do nothing
ConsoleWrite("Emails will be added to the file emailsexport.csv" & @CRLF)
GUICtrlSetData($Edit1,"Emails will be added to the file emailsexport.csv" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Emails will be added to the file")
EndIf
EndIf
; --------------------------
Local $hFileEXPORTOpen = @ScriptDir & "\emailsexport.csv"
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQlite_Query (-1, "SELECT DISTINCT email FROM tblSpiderEmail;", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
FileWriteLine($hFileEXPORTOpen,$srow1 & ",")
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()
FileClose ( "$hFileEXPORTOpen" )
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe emailsexport.csv", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------

; ############ OUTPUT LINKS TO FILE FROM DATABASE #########
Func _idExportLinks2file()
Local $hQuery, $aRow, $srow1
; --------------------------
; # CHECK IF THE FILE EXISTS AND IF THE USER WANTS TO CLEAR IT OUT
If FileExists(@ScriptDir & "\linksexport.csv") Then
; # MSGBOX #
ConsoleWrite("Would you like to erase the current export file" & @CRLF)
GUICtrlSetData($Edit1,"Would you like to erase the current export file" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to erase the current export file")
Local $MyBoxEXPORT = MsgBox(1, "Question","Would you like erase the current export file?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxEXPORT == 1 Then ; OK CHOICE
; # TALK #
ConsoleWrite("Erasing File linksexport.csv" & @CRLF)
GUICtrlSetData($Edit1,"Erasing File linksexport.csv" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Erasing File")
_FileCreate("linksexport.csv")
ElseIf $MyBoxEXPORT == 2 Then ; CANCEL CHOICE
; Do nothing
ConsoleWrite("Links will be added to the file linksexport.csv" & @CRLF)
GUICtrlSetData($Edit1,"Links will be added to the file linksexport.csv" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Links will be added to the file")
EndIf
EndIf
; --------------------------
Local $hFileEXPORTOpen = @ScriptDir & "\linksexport.csv"
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
_SQlite_Query (-1, "SELECT DISTINCT link FROM tblSpiderLinks;", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
FileWriteLine($hFileEXPORTOpen,$srow1 & ",")
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()
FileClose ( "$hFileEXPORTOpen" )
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe linksexport.csv", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
Return
EndFunc

; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------

; ############ INSERT New Emails IN THE DATABASE #########
Func _SQLiteInsertEmailDB($domain,$email)
Local $text, $text1
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($domain, "'", "''")
$text1 = StringReplace($email, "'", "''")
_SQLite_Exec (-1, "INSERT INTO tblSpiderEmail(domain,email) VALUES ('" & $text & "','" & $text1 & "');")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ FIND DUPLICATED DOMAINS SPIDERED IN THE DATABASE #########
Func _SQLiteDuplicateDomainDB($url)
Local $hQuery, $aRow, $srow1, $text
$srow1 = ""
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($url, "'", "''")
_SQlite_Query (-1, "SELECT domain FROM tblSpiderDomain WHERE domain = '"& $text & "';", $hQuery)
While _SQLite_FetchData ($hQuery, $aRow, False, False) = $SQLITE_OK ; Read Out the next Row
$srow1 = $aRow[0]
;;;ConsoleWrite($aRow[0] & @CRLF)
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
WEnd
_SQLite_QueryFinalize($hQuery)
_SQLite_Close()
_SQLite_Shutdown()
return $srow1
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ INSERT NEW DOMAINS IN THE DATABASE #########
Func _SQLiteInsertDomainDB($url,$dated,$avstat)
Local $text, $text1, $text2
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($url, "'", "''")
$text1 = StringReplace($dated, "'", "''")
$text2 = StringReplace($avstat, "'", "''")
_SQLite_Exec (-1, "INSERT INTO tblSpiderDomain(domain,dated,checked,valid,exclude,antivirus) VALUES ('" & $text & "','" & $text1 & "','0','0','0','" & $text2 & "');")
;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ UPDATE Non valid domain IN THE DATABASE #########
Func _SQLiteDomainNotValidDB($url)
Local $text
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($url, "'", "''")
_SQLite_Exec (-1, "UPDATE tblSpiderDomain SET valid = '0' WHERE domain = '" & $text & "';")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ UPDATE VALID domain IN THE DATABASE #########
Func _SQLiteDomainValidDB($url)
Local $text
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($url, "'", "''")
_SQLite_Exec (-1, "UPDATE tblSpiderDomain SET valid = '1' WHERE domain = '" & $text & "';")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ UPDATE CHECKED domain IN THE DATABASE #########
Func _SQLiteDomainCHECKEDDB($url)
Local $text
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
$text = StringReplace($url, "'", "''")
_SQLite_Exec (-1, "UPDATE tblSpiderDomain SET checked = '1' WHERE domain = '" & $text & "';")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ############ UPDATE CHECKED ALL IN THE DATABASE #########
Func _SQLiteDomainCHECKEDALLDB()
;;;Local $text
_SQLite_Startup ()
_SQLite_Open (@ScriptDir & "\SpiderCAREERS.db") ; open Database
;;;$text = StringReplace($url, "'", "''")
_SQLite_Exec (-1, "UPDATE tblSpiderDomain SET checked = '0' WHERE checked = '1';")
;;SQLite record limits = 18446744073709551616 need to code in auto perge here (select num records then purge or bak"
_SQLite_Close()
_SQLite_Shutdown()
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ###########################
; # RESTART PROGRAM Restart #
; ###########################
Func _restart()
If @Compiled = 1 Then
Run( FileGetShortName(@ScriptFullPath))
Else
Run( FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
EndIf
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Exit
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ########################
; # CUSTOM ERROR HANDLER #
; ########################
Func MyErrFunc()
Local $HexNumber, $strMsg
$HexNumber = Hex($oMyError.Number, 8)
$strMsg = "Error Number: " & $HexNumber & @CRLF
$strMsg &= "WinDescription: " & $oMyError.WinDescription & @CRLF
$strMsg &= "Script Line: " & $oMyError.ScriptLine & @CRLF
; # TALK #
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("WARNING! Critical program error detected!")
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"WARNING! Critical program error detected!" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("WARNING! Critical program error detected!" & @CRLF)
GUICtrlSetData($Edit1,"ERROR = " & $strMsg & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("ERROR = " & $strMsg & @CRLF)
SetError(1)
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Endfunc

; -------------------------------------------------------------------------------------------------------------

; ##############################
; #Scan for Jobs LINKS URL WITH ALGO #   ---------------------------------- FIX the " at the end of URLS here ------------------------------------------- FIX NEEDED
Func _JobUrlfound($htmlS2,$algosearch,$urlF,$domainl)
; # DELETE THE ARRAY SO ITS CLEAN TO START # THIS NEEDS TO BE DONE BECUASE IT A GLOBAL ARRAY - Might be better to return the array later stage instead
; YEAH THIS IS WHAT HAPPENS WHEN YOU SIT ON YOUR ARSE AND THEN START TO CODE AND THEN YOU REALISE SHHHheeeeeeeeiiiiiit! I was meant to out the array here and not make it global or was it meant to be global? Who cares it works! lol
; -------------------------
if number(IniRead(@ScriptDir & "\settings.ini", "options", "enablelinks", "1")) = 0 then
GUICtrlSetData($Edit1,"Searching for Links is Disabled" & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Searching for Links is Disabled" &  @CRLF)
Return 0
Endif
; -------------------------
if IsArray($aArrayAlgoFound) = 1 then
_ArrayDelete($aArrayAlgoFound, $aArray_BaseFound)
Endif
; -------------------------
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Searching for Career Links Algo " & $algosearch & " , Please Wait..." & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Searching for Career Links Algo " & $algosearch & " , Please Wait..." &  @CRLF)
Local $html2, $arraynum, $ei, $dii, $di, $careerUrlFound, $arrayurlfound, $FoundPosition = "" ,$Linkok, $FoundPosition1 = "" , $FoundPosition2 = "" , $Linkrep = 0,$lPosition = 0, $RegExpString = ""
; # SET TO ZERO #
$di = 0
$ei = 0
$Linkok = 0
; -------------------------
; # BUILD ARRAY WITH ALL LINKS - WE SEARCH LINKS BETWEEN href= AND > #
Local $aArrayCurl = _StringBetween($htmlS2,"href=",">")
; -------------------------
; MIGHT NEED TO CHECK IF ARRAY
if IsArray($aArrayCurl) = 0 then
$Linkok = 0
return $Linkok
Endif
; -------------------------
; -------------------------
; -------------------------
; # LOOP 1 #
 for $di = 0 to UBound($aArrayCurl) - 1
; -------------------------
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Extracting link - " & $aArrayCurl[$di] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Extracting link - " & $aArrayCurl[$di] & @CRLF)
; # DRUM THE BEEP #
If GUICtrlRead($Checkbox2) = 1 Then Beep(IniRead(@ScriptDir & "\settings.ini","options","freq", "400"),IniRead(@ScriptDir & "\settings.ini","options","dura", "50"))
; -------------------------
; # BUILD ANOTHER ARRAY FROM SEARCH FOR ALGO IN LINKS FOUND ARRAY #
$careerUrlFound = StringRegExp($aArrayCurl[$di], "(?i)" & $algosearch, 3)
; -------------------------
; -------------------------
; -------------------------
; # LOOP 2 #
for $ei = 0 to UBound($careerUrlFound) - 1
; -------------------------
; # IF DATA FOUND #
if IsArray($careerUrlFound) = 1 and not $careerUrlFound[$ei] = "" then ; INSERT TO GLOBAL ARRAY IF VALID
; INSERT TO GLOBAL ARRAY IF VALID
$Linkrep = 0
$dii = $dii + 1
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"Found Career Link - " & $aArrayCurl[$di] & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Found Career Link = " & $aArrayCurl[$di] & @CRLF)
; SET IF LINK FOUND SO PROGRAM CAN SAY IF IT FOUND ANY LINKS #
$Linkok = number($Linkok) + 1
; -----------
; ----------- HERE WE NEED TO STRIPOUT ANY OTHER DATA WITH and CLEAN UP THE LINK
;$STR_STRIPSPACES
Local $aArrayExplode1 = _StringExplode(StringStripWS($aArrayCurl[$di], $STR_STRIPLEADING)," ", 1)
;Local $aArrayExplode2 = StringReplace($aArrayCurl[$di], " ", "|")
;Local $aArrayExplode1 = _StringExplode($aArrayExplode2,"|", 1)
; # TESTING #
;;;_ArrayDisplay($aArrayExplode1, "StringExplode 0")
; # REMOVE WHITE SPACES #
$FoundPosition = StringStripWS($aArrayCurl[$di], $STR_STRIPLEADING + $STR_STRIPTRAILING)
; USE THESE VARS TO DO THE REST AS ITS REPAIRED AND CLEANER
Local $aArrayCurlEXP = $aArrayExplode1[0]
$FoundPosition = $aArrayExplode1[0]
; # REMOVE THE OLD VALUE FROM THE ARRAY SO ITS NOT THERE FOR NEXT TIME
_ArrayDelete($aArrayExplode1,0)
;;_ArrayDelete($aArrayExplode1,1)
; -----------
; -----------
; # REPAIR THE URL IF NO HTTP FOUND BY INSERTING THE URL GET THE FIRST 4 CHARS to see what it contains #
$FoundPosition = StringLeft($FoundPosition,4)
;-----------------------------
; # REPAIR HREF LINKS FOR CAPTURE # This follows a cronological order dont mix them up - we only need to record the url once
; ----------- skipped
if $Linkrep = 0 then
$lPosition = StringInStr($aArrayCurlEXP , "mailto")
if $lPosition >= 1 then
$Linkrep = 1
$dii = $dii - 1
Endif
Endif

if $Linkrep = 0 then
$lPosition = StringInStr($aArrayCurlEXP , '"//www.')
if $lPosition >= 1 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,'http:' & $FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,'http:' & $FoundPosition2)
ConsoleWrite('Repaired link = ' & 'http:' & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$lPosition = StringInStr($aArrayCurlEXP , "'//www.")
if $lPosition >= 1 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,"http:" & $FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,"http:" & $FoundPosition2)
ConsoleWrite('Repaired link = ' & "http:" & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif

; ----------- THIS IS NOT NEEDED AND JUST EXTRA WORK BEDUASE JAVA WILL NEVER CONTRAIN WORK DETAILS
if $Linkrep = 0 then
$lPosition = StringInStr($aArrayCurlEXP, "javascript:")
if $lPosition >= 1 then
$Linkrep = 1
$dii = $dii - 1
Endif
Endif

; // BUG!!!!!
; Found Career Link = "//www.allenford.com/recruitment/"  title="Allen Ford Are Now Recruiting"
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,3),'"//')
ConsoleWrite('Repaired link string o// = ' & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"//','/')
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
EndIf
EndIf
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,3),"'//")
ConsoleWrite("Repaired link string 0// = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'//","/")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
EndIf
EndIf
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare($FoundPosition,"http")
ConsoleWrite("Repaired link string http = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$FoundPosition2)
ConsoleWrite("Repaired link = " & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare($FoundPosition,'"htt')
ConsoleWrite('Repaired link string ohtt = ' & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$FoundPosition2)
ConsoleWrite('Repaired link = ' & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare($FoundPosition,"'htt")
ConsoleWrite("Repaired link string 0htt = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$FoundPosition2)
ConsoleWrite("Repaired link = " & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
; Check if its just a link direct
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,2),"'/")
ConsoleWrite("Repaired link string 0/ = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & $FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$urlF & $FoundPosition2)
ConsoleWrite("Repaired link = " & $urlF & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,2),'"/')
ConsoleWrite('Repaired link string o/ = ' & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & $FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$urlF & $FoundPosition2)
ConsoleWrite('Repaired link = ' & $urlF & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,1),"/")
ConsoleWrite("Repaired link string / = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & $FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$urlF & $FoundPosition2)
ConsoleWrite("Repaired link = " & $urlF & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,1),"#")
ConsoleWrite("Repaired link string # = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & $FoundPosition2)
_SQLiteInsertDomainLinksDB($domainl,$urlF & $FoundPosition2)
ConsoleWrite("Repaired link = " & $urlF & "/" & $FoundPosition2 & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,2),"'#")
ConsoleWrite("Repaired link string 0# = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,2),'"#')
ConsoleWrite("Repaired link string o# = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & "/" & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,3),'"/#')
ConsoleWrite("Repaired link string o/# = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,2),"'/#")
ConsoleWrite("Repaired link string 0/# = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

; -----------  NOT SURE ABOUT THIS AS ITS WEBSITES SAYING TO THE SERVER ITS ONE DIRECTORY BACK ../ PERHAPS NOT STRIP WHAT ABOUT ./?????
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,3),'"../')
ConsoleWrite('Repaired link string o../ = ' & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"..','')
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif
; ----------- NOT SURE ABOUT THIS AS ITS WEBSITES SAYING TO THE SERVER ITS ONE DIRECTORY BACK ../  PERHAPS NOT STRIP WHAT ABOUT ./?????
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,3),"'../")
ConsoleWrite("Repaired link string o../ = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'..","")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------

; ----------- NOT SURE ABOUT THIS AS ITS WEBSITES SAYING TO THE SERVER ITS ONE DIRECTORY BACK ../  PERHAPS NOT STRIP  WHAT ABOUT ./?????
if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, '../[a-zA-Z0-9.-]+\.', 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,'../','')
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, '"../[a-zA-Z0-9.-]+\.', 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"../','')
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, '"[a-zA-Z0-9.-]+\.', 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, '"www.[a-zA-Z0-9.-]+\.', 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, '"/[a-zA-Z0-9.-]+\.', 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"/','')
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, '"//[a-zA-Z0-9.-]+\.', 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"//','')
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif

; -----------
; -----------

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, "'../[a-zA-Z0-9.-]+\.", 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'../","")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
ConsoleWrite('Repaired link = ' & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, "'[a-zA-Z0-9.-]+\.", 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'","")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, "'www.[a-zA-Z0-9.-]+\.", 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'","")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, "'/[a-zA-Z0-9.-]+\.", 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'/","")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

if $Linkrep = 0 then
$RegExpString = StringRegExp($aArrayCurlEXP, "'//[a-zA-Z0-9.-]+\.", 3)
if IsArray($RegExpString) = 1 then
_ArrayDelete($RegExpString,0)
$FoundPosition2 = StringReplace($aArrayCurlEXP,"'//","")
$FoundPosition2 = StringReplace($FoundPosition2,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif

; -----------
; -----------
if $Linkrep = 0 then
; Here we need to check if the link is just a html page
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,1),"'")
ConsoleWrite("Repaired link string 0 = " & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,"'",""))
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,"'","") & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
if $Linkrep = 0 then
$FoundPosition1 = StringCompare(StringLeft($FoundPosition,1),'"')
ConsoleWrite('Repaired link string o = ' & $FoundPosition1 & @CRLF)
If $FoundPosition1 = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
_ArrayAdd($aArrayAlgoFound,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & '/' & StringReplace($FoundPosition2,'"',''))
ConsoleWrite('Repaired link = ' & $urlF & '/' & StringReplace($FoundPosition2,'"','') & @CRLF)
$Linkrep = 1
Endif
Endif
; -----------
; If its just a webfile and not already repaired - add it as it a career link  --- THIS MIGHT NOT BE NEEDED or the / above is incorrect
If $Linkrep = 0 then
$FoundPosition2 = StringReplace($aArrayCurlEXP,'"','')
$FoundPosition2 = StringReplace($FoundPosition2,"'","")
ConsoleWrite("Repaired link = " & $urlF & "/" & StringReplace($FoundPosition2,'"','') & @CRLF)
_ArrayAdd($aArrayAlgoFound,$urlF & "/" & StringReplace($FoundPosition2,'"',''))
_SQLiteInsertDomainLinksDB($domainl,$urlF & "/" & StringReplace($FoundPosition2,'"',''))
$Linkrep = 1
Endif
;-----------------------------

Endif ; End of Array is valid

;-----------------------------

; -------------------------
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; -------------------------
; -------------------------
; -------------------------
; # END LOOP # of found algos
Next
; -------------------------
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; -------------------------
; -------------------------
; -------------------------
; # END LOOP # of all links
Next
; -------------------------

return $Linkok
EndFunc

; -------------------------------------------------------------------------------------------------------------

; # CHECK THE URL IF IT REDIRECTS
Func _RedirectUrl($url)
$initialurl = $url
; Initialize and get session handle
$hOpen = _WinHttpOpen()
; Get connection handle
$hConnect = _WinHttpConnect($hOpen, $initialurl)
; Register Callback function
$hREDIRECT_CALLBACK = DllCallbackRegister("_Redirect", "none", "handle;dword_ptr;dword;ptr;dword")
; Set callback
_WinHttpSetStatusCallback($hConnect, $hREDIRECT_CALLBACK, $WINHTTP_CALLBACK_FLAG_REDIRECT)
; Make a request
$hRequest = _WinHttpSimpleSendRequest($hConnect, Default, "/") ;Here the request follow the redirection and land on a different webpage
;;;MsgBox(1, "Testing", @error)
; Close handles
_WinHttpCloseHandle($hRequest)
_WinHttpCloseHandle($hConnect)
_WinHttpCloseHandle($hOpen)
; Free callback
DllCallbackFree($hREDIRECT_CALLBACK)
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
EndFunc

; -------------------------------------------------------------------------------------------------------------

; # THIS DISPLAYS THE URL REDIRECTED #
; Define callback function
Func _Redirect($hConnect, $iContext, $iInternetStatus, $pStatusInformation, $iStatusInformationLength)
;;;        $sStatusR = "About to automatically redirect the request to: " & DllStructGetData(DllStructCreate("wchar[" & $iStatusInformationLength & "]", $pStatusInformation), 1) & "    "
 ;;       ConsoleWrite("!>" & $sStatusR & @CRLF)
 ;;;       MsgBox(4096, "REDIRECTION:", $sStatusR)
$sStatusR = DllStructGetData(DllStructCreate("wchar[" & $iStatusInformationLength & "]", $pStatusInformation), 1) & "    "
;;;return $sStatusR
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
EndFunc

; -------------------------------------------------------------------------------------------------------------

; -------------------- ANTI-VIRUS FUNCTIONS
; -------------------------------------------------------------------------------------------------------------

; ################################
; # START THE ANTI VIRUS PROCESS #
; ################################
Func _VTAntiVirus($Url2Scan1)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Started Scanning Url - " & $Url2Scan1 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Started Scanning Url - " & $Url2Scan1 & @CRLF)
Local $avi = 0, $SCDateCalc = "", $SCpositives = "", $SCscan_id = "" ,$ALLGOOD1 = 0
Global $pe1 = 0, $pe2 = 0, $pe3 = 0
Global $INIDIFFDATE = IniRead(@ScriptDir & "\settings.ini","options","AVdatediff","7")
Global $APIkey=IniRead(@ScriptDir & "\settings.ini", "options", "AVAPIKey", "fd1335fc15d0b0a35771707406c45edd0d726c9c281942e637cc679255517601")
; # CALL THE REPORT SERVICE FIRST TO SEE IF ITS ALREADY CHECKED 30 Days max
$VTReportReturn = _VTAntiVirusReport($Url2Scan1)
If number($VTReportReturn) = 9 then                        ; ------------------------------------------------------------- NEED TO PUT A LOOP HERE IF NO AWNSER FROM SERVER
;$VTReportReturn = _VTAntiVirusReportRestart($Url2Scan1) ; OLD CODE DO NOT USE AS IT CANT GET DATA AFTER NO SPI CONNECTION
$VTReportReturn = _VTAntiVirusINITReportRestart($Url2Scan1)
; # TESTING #
;;;_ArrayDisplay($VTReportReturn, "AV Report Array 3")
; # EXTRACT THE REPORT ARRAY #
Local $SCscan_id = $VTReportReturn[0]
Local $SCresource = $VTReportReturn[1]
Local $SCurl = $VTReportReturn[2]
Local $SCresponse_code = $VTReportReturn[3]
Local $SCscan_date = $VTReportReturn[4]
Local $SCpermalink = $VTReportReturn[5]
Local $SCfilescan_id = $VTReportReturn[6]
Local $SCpositives = $VTReportReturn[7]
Local $SCtotal = $VTReportReturn[8]
Local $SCDateCalc = $VTReportReturn[10]
Local $SCverbose_msg = $VTReportReturn[9]
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says " & $SCverbose_msg & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says " & $SCverbose_msg & @CRLF & GUICtrlRead($Edit1))
else
; # TESTING #
;;;_ArrayDisplay($VTReportReturn, "AV Report Array 3")
; # EXTRACT THE REPORT ARRAY #
Local $SCscan_id = $VTReportReturn[0]
Local $SCresource = $VTReportReturn[1]
Local $SCurl = $VTReportReturn[2]
Local $SCresponse_code = $VTReportReturn[3]
Local $SCscan_date = $VTReportReturn[4]
Local $SCpermalink = $VTReportReturn[5]
Local $SCfilescan_id = $VTReportReturn[6]
Local $SCpositives = $VTReportReturn[7]
Local $SCtotal = $VTReportReturn[8]
Local $SCDateCalc = $VTReportReturn[10]
Local $SCverbose_msg = $VTReportReturn[9]
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says " & $SCverbose_msg & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says " & $SCverbose_msg & @CRLF & GUICtrlRead($Edit1))
Endif

; ------------------------

if number($SCDateCalc) > number($INIDIFFDATE) then ; Tell the user if the scan is too old and needs to be re scanned
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says URL scan DATE is " & number($SCDateCalc) - number($INIDIFFDATE) & " days over the limit and needs to be Re-Scanned" & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says URL scan DATE is " & number($SCDateCalc) - number($INIDIFFDATE) & " days over the limit and needs to be Re-Scanned" & @CRLF & GUICtrlRead($Edit1))
else
ConsoleWrite("AntiVirus says URL scan DATE is FRESH!" & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says URL scan DATE is FRESH!" & @CRLF & GUICtrlRead($Edit1))
endif

If not string($SCscan_id) = "" and not string($SCpositives) = "" and number($SCDateCalc) < number($INIDIFFDATE) then
If number($SCpositives) = 0 Then Return "OK" ; Say its OK to Continue
If number($SCpositives) >= number(IniRead(@ScriptDir & "\settings.ini","options","avscannumfail", "1")) Then Return $SCpermalink ; Send the link with the problem
EndIf
If String($VTReportReturn) = "NILL" Then Return "NILL" ; If there was a API Loop problem

; ------------------------

; # SUBMIT URL FOR SCANNING #
; # See if the AV result needs updating DATEDIFF #
If string($SCscan_id) = "" or string($SCpositives) = "" or number($SCDateCalc) > number($INIDIFFDATE) then ; or $RPscan_id = "" or $RPpositives = "" then ; This tells it to rescan the URL if the last scan was older than x days
GUICtrlSetData($Edit1,"AntiVirus submitted Url for scanning " & $Url2Scan1 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus submitted Url for scanning " & $Url2Scan1 & @CRLF)
Local $avi = 0, $SCDateCalc = "", $SCpositives = "", $SCscan_id = "" , $ALLGOOD1
; # SUBMIT URL FOR SCANNING #
$VTReportScan = _VTAntiVirusScan($Url2Scan1)
If number($VTReportScan) = 9 or string($VTReportScan[0]) = "" then
$VTReportScan2 = _VTAntiVirusScanRestart($Url2Scan1)
; # TESTING #
;;;_ArrayDisplay($VTReportScan2, "AV Report Array 4")
; # EXTRACT THE REPORT ARRAY #
Local $SCscan_id = $VTReportScan2[0]
Local $SCresource = $VTReportScan2[1]
Local $SCurl = $VTReportScan2[2]
Local $SCresponse_code = $VTReportScan2[3]
Local $SCscan_date = $VTReportScan2[4]
Local $SCpermalink = $VTReportScan2[5]
Local $SCfilescan_id = $VTReportScan2[6]
Local $SCpositives = $VTReportScan2[7]
Local $SCtotal = $VTReportScan2[8]
Local $SCDateCalc = $VTReportScan2[10]
Local $SCverbose_msg = $VTReportScan2[9]
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says " & $SCverbose_msg & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says " & $SCverbose_msg & @CRLF & GUICtrlRead($Edit1))
Else ; Display the array
; # TESTING #
;;;_ArrayDisplay($VTReportScan, "AV Report Array 5")
; # EXTRACT THE REPORT ARRAY #
Local $SCscan_id = $VTReportScan[0]
Local $SCresource = $VTReportScan[1]
Local $SCurl = $VTReportScan[2]
Local $SCresponse_code = $VTReportScan[3]
Local $SCscan_date = $VTReportScan[4]
Local $SCpermalink = $VTReportScan[5]
Local $SCfilescan_id = $VTReportScan[6]
Local $SCpositives = $VTReportScan[7]
Local $SCtotal = $VTReportScan[8]
Local $SCDateCalc = $VTReportScan[10]
Local $SCverbose_msg = $VTReportScan[9]
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says " & $SCverbose_msg & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says " & $SCverbose_msg & @CRLF & GUICtrlRead($Edit1))
Endif

; ------------------------

If not string($SCscan_id) = "" and not string($SCpositives) = "" and number($SCDateCalc) < number($INIDIFFDATE) then
If number($SCpositives) = 0 Then Return "OK" ; Say its OK to Continue
If number($SCpositives) >= number(IniRead(@ScriptDir & "\settings.ini","options","avscannumfail", "1")) Then Return $SCpermalink ; Send the link with the problem
EndIf
If String($VTReportScan2) = "NILL" Then Return "NILL" ; If there was a API Loop problem

; ------------------------

; # SCAN AGAIN AFTER SUBMIT FOR INFO #
If string($SCscan_id) = "" or string($SCpositives) = "" Then
GUICtrlSetData($Edit1,"AntiVirus Rechecking Report for Url after scanning " & $Url2Scan1 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Rechecking Report for Url after scanning " & $Url2Scan1 & @CRLF)
Local $avi = 0, $SCDateCalc = "", $SCpositives = "", $SCscan_id = "" , $ALLGOOD1
$VTReportScan4 = _VTAntiVirusReport($Url2Scan1)
If number($VTReportScan4) = 9 or string($VTReportScan4[7]) = "" or number($VTReportScan4[10]) > number($INIDIFFDATE) Then ; this checks if the report returned nothing and starts the looper
; SCAN AGAIN LOOPER FUNCTION
$VTReportScan6 = _VTAntiVirusReportRestart($Url2Scan1)
 ; # TESTING #
;;;_ArrayDisplay($VTReportScan6, "AV Report Array 6")
; # EXTRACT THE REPORT ARRAY #
Local $SCscan_id = $VTReportScan6[0]
Local $SCresource = $VTReportScan6[1]
Local $SCurl = $VTReportScan6[2]
Local $SCresponse_code = $VTReportScan6[3]
Local $SCscan_date = $VTReportScan6[4]
Local $SCpermalink = $VTReportScan6[5]
Local $SCfilescan_id = $VTReportScan6[6]
Local $SCpositives = $VTReportScan6[7]
Local $SCtotal = $VTReportScan6[8]
Local $SCDateCalc = $VTReportScan6[10]
Local $SCverbose_msg = $VTReportScan6[9]
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says " & $SCverbose_msg & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says " & $SCverbose_msg & @CRLF & GUICtrlRead($Edit1))
; RETURN RESULTS
If number($SCpositives) = 0 Then Return "OK" ; Say its OK to Continue
If number($SCpositives) >= number(IniRead(@ScriptDir & "\settings.ini","options","avscannumfail", "1")) Then Return $SCpermalink ; Send the link with the problem
If String($VTReportScan6) = "NILL" Then Return "NILL" ; If there was a API Loop problem
Else
; DISPLAY RESULTS
; # TESTING #
;;;_ArrayDisplay($VTReportScan4, "AV Report Array 7")
; # EXTRACT THE REPORT ARRAY #
Local $SCscan_id = $VTReportScan4[0]
Local $SCresource = $VTReportScan4[1]
Local $SCurl = $VTReportScan4[2]
Local $SCresponse_code = $VTReportScan4[3]
Local $SCscan_date = $VTReportScan4[4]
Local $SCpermalink = $VTReportScan4[5]
Local $SCfilescan_id = $VTReportScan4[6]
Local $SCpositives = $VTReportScan4[7]
Local $SCtotal = $VTReportScan4[8]
Local $SCDateCalc = $VTReportScan4[10]
Local $SCverbose_msg = $VTReportScan4[9]
; # DISPLAY INFO  #
ConsoleWrite("AntiVirus says " & $SCverbose_msg & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says " & $SCverbose_msg & @CRLF & GUICtrlRead($Edit1))
; RETURN RESULTS
If number($SCpositives) = 0 Then Return "OK" ; Say its OK to Continue
If number($SCpositives) >= number(IniRead(@ScriptDir & "\settings.ini","options","avscannumfail", "1")) Then Return $SCpermalink ; Send the link with the problem
If String($VTReportScan6) = "NILL" Then Return "NILL" ; If there was a API Loop problem
Endif
Endif

; ------------------------

EndIf

; RETURN RESULTS   --------- ------------------------------------------------------------------------------------I DONT THINK THIS IS NEEDED ANYMORE
If number($SCpositives) = 0 Then Return "OK" ; Say its OK to Continue
If number($SCpositives) >= number(IniRead(@ScriptDir & "\settings.ini","options","avscannumfail", "1")) Then Return $SCpermalink ; Send the link with the problem
;;;;If String($VTReportScan6) = "NILL" Then Return "NILL" ; If there was a API Loop problem

; ------------------------
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Finished Scanning Url - " & $Url2Scan1 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Finished Scanning Url - " & $Url2Scan1 & @CRLF)
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "prospeed", "100")) ; wait 5 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Endfunc

; -------------------- ANTI-VIRUS FUNCTIONS
; -------------------------------------------------------------------------------------------------------------

; ################################################
; # RESTART THE SCAN function REPORT BACK LOOPER #
; ################################################
Func _VTAntiVirusScanRestart($Url2Scan4)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Scan Restart Looper for Url - " & $Url2Scan4 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Scan Restart Looper for Url - " & $Url2Scan4 & @CRLF)
$pe2 = 0
; # LOOP START #
While number($pe2) <= number(IniRead(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20"))
$VTReportScan3 = _VTAntiVirusScan($Url2Scan4)
 ; ----------------------
;;;If IsArray($VTReportScan5) = 1 then             ---------------------------->>> MAY NEED A FIX HERE TESTING ARRAY or if
 ; ----------------------
If number($VTReportScan3) = 9 or number($VTReportScan3[3]) = 0 then
GUICtrlSetData($Edit1,"Waiting for connection to Anti-Virus scan server, please wait... reconnecting in " & IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") / 1000 & "s " & $pe2 & " times " & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Waiting for connection to Anti-Virus scan server, please wait... reconnecting in " & IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") / 1000 & "s " & $pe2 & " times " & @CRLF)
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000")) ; wait 60 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Else
; # TESTING #
;_ArrayDisplay($VTReportScan3, "AV Report Array 10")
Return $VTReportScan3
ExitLoop
Endif
$pe2 = number($pe2) + 1
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # LOOP END #
WEnd
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"There seems to be a problem with the Anti-Virus scan API or Internet Connection, Exiting..." & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("There seems to be a problem with the Anti-Virus scan API or Internet Connection, Exiting..." & @CRLF)
; # WAIT SPEED #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "prospeed", "100"))
; ASK IF THE USER WANTS TO ABORT OR MARK THE DOMAIN AS BAD                      ---------------------------------------------------------- FIX HERE
Return "NILL"
;;Exit
;;If number($pe2) = number(IniRead(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20")) then
Endfunc

; -------------------- ANTI-VIRUS FUNCTIONS
; -------------------------------------------------------------------------------------------------------------

; ###################################################
; # BUILD A REPORT ON URL AVALIBLE ON THE AV SERVER #
; ###################################################
Func _VTAntiVirusReport($Url2Scan2)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Report Server Get Data for Url - " & $Url2Scan2 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Report Server Get Data for Url - " & $Url2Scan2 & @CRLF)
; # BUILD THE ARRAY #
Local $aArray_AntiVirusReport[0]
Local $aArrayAVFound1 = $aArray_AntiVirusReport
;# PING CHECK INTERNET IS OK #
if GUICtrlRead($Checkbox5) = 1 Then
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
EndIf
; # GET REPORT OF URL FOR VIRUS SERVER #
$hVirusTotal = VT_Open()
$VTReport = VT($hVirusTotal,$uReport,$Url2Scan2,$APIkey)
ConsoleWrite("_VTAntiVirusReport AWNSER = " & $VTReport & @CRLF)
if not $VTReport = "" then
; # JSON DECODING RESULT #
Local $objJson = Jsmn_Decode($VTReport)
Local $objJson1 = Jsmn_ObjGet($objJson, "scan_id") ; If you submit a scan this is used to recal the scan
Local $objJson2 = Jsmn_ObjGet($objJson, "resource")
Local $objJson3 = Jsmn_ObjGet($objJson, "url")  ; Display the scanned URL
Local $objJson4 = Jsmn_ObjGet($objJson, "response_code") ; Used to say if it has been scanned before
Local $objJson5 = Jsmn_ObjGet($objJson, "scan_date") ; The last time the url was scanned
Local $objJson6 = Jsmn_ObjGet($objJson, "permalink")  ; Use this to show the scan page result
Local $objJson7 = Jsmn_ObjGet($objJson, "filescan_id")
Local $objJson8 = Jsmn_ObjGet($objJson, "positives") ; Used to show if a problem was found virus extra
Local $objJson9 = Jsmn_ObjGet($objJson, "total") ; Total vendos scanned  by
Local $objJson9a = Jsmn_ObjGet($objJson, "verbose_msg") ; verbose_msg
; # ADD RESULTS TO ARRAY #
_ArrayAdd($aArrayAVFound1,$objJson1) ; scan_id
_ArrayAdd($aArrayAVFound1,$objJson2) ; resource
_ArrayAdd($aArrayAVFound1,$objJson3) ; url
_ArrayAdd($aArrayAVFound1,$objJson4) ; response_code
_ArrayAdd($aArrayAVFound1,$objJson5) ; scan_date
_ArrayAdd($aArrayAVFound1,$objJson6) ; permalink
_ArrayAdd($aArrayAVFound1,$objJson7) ; filescan_id
_ArrayAdd($aArrayAVFound1,$objJson8) ; positives
_ArrayAdd($aArrayAVFound1,$objJson9) ; total
_ArrayAdd($aArrayAVFound1,$objJson9a) ; verbose_msg
;_ArrayDisplay($aArrayAVFound1, "AV Report Array")
; # FORMAT THE DATE STRING SO IT CAN CALCULATE THE NUMBER OF DAYS SINCE LAST SCAN
Local $sStringJSON1 = StringReplace($objJson5, "-", "/")
Local $iDateCalc = _DateDiff('D',$sStringJSON1, _NowCalc())
_ArrayAdd($aArrayAVFound1,$iDateCalc) ; Number of days what have passed since the last scan We check on 30
VT_Close($hVirusTotal) ;
; # TESTING #
;_ArrayDisplay($aArrayAVFound1, "AV Report Array 11")
; # Return the Array #
Return $aArrayAVFound1
else
Return 9 ; This tells the program there was an error and to restart it in the restart function what acts like a loop counting to 10 then exit
Endif
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "prospeed", "100")) ; wait 5 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Endfunc

; -------------------- ANTI-VIRUS FUNCTIONS
; -------------------------------------------------------------------------------------------------------------

; ################################
; # RESTART THE REPORT function  #
; ################################
Func _VTAntiVirusReportRestart($url23)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Report Restart Looper for Url - " & $url23 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Report Restart Looper for Url - " & $url23 & @CRLF)
$pe1 = 0
; # LOOP START #
While number($pe1) <= number(IniRead(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20"))
$VTReportScan5 = _VTAntiVirusReport($url23)
 ; ----------------------
;;;If IsArray($VTReportScan5) = 1 then             ---------------------------->>> MAY NEED A FIX HERE TESTING ARRAY or IF
 ; ----------------------
If number($VTReportScan5) = 9 or number($VTReportScan5[3]) = 0 then
GUICtrlSetData($Edit1,"Waiting for connection to Anti-Virus report server, please wait... reconnecting in " & IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") / 1000 & "s " & $pe1 & " times " & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Waiting for connection to Anti-Virus report server, please wait... reconnecting in " & IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") / 1000 & "s " & $pe1 & " times " & @CRLF)
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000")) ; wait 60 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Else
; # TESTING #
;_ArrayDisplay($VTReportScan3, "AV Report Array 10")

; # CHECK THE URL IS NOT THE OLD ONE IF DATE WAS WRONG #
If IsArray($VTReportScan5) = 1 then
If number($VTReportScan5[10]) < number($INIDIFFDATE) then
Return $VTReportScan5
ExitLoop
Else
ConsoleWrite("AntiVirus says URL DATE is still " & number($VTReportScan5[10]) - number($INIDIFFDATE) & " days over the limit, checking again" & @CRLF)
GUICtrlSetData($Edit1,"AntiVirus says URL scan DATE is still " & number($VTReportScan5[10]) - number($INIDIFFDATE) & " days over the limit, checking again" & @CRLF & GUICtrlRead($Edit1))
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000")) ; wait 60 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Endif
Endif

Endif

$pe1 = number($pe1) + 1
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # LOOP END #
WEnd
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"There seems to be a problem with the Anti-Virus scan API or Internet Connection, Exiting..." & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("There seems to be a problem with the Anti-Virus scan API or Internet Connection, Exiting..." & @CRLF)
; # WAIT SPEED #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "prospeed", "100"))
; ASK IF THE USER WANTS TO ABORT OR MARK THE DOMAIN AS BAD  --------------------------------------------------------------- FIX HERE
Return "NILL"
;;;Exit
;If number($pe2) = number(IniRead(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20")) then

Endfunc

; -------------------- ANTI-VIRUS FUNCTIONS
; -------------------------------------------------------------------------------------------------------------

; ######################################################
; # RESTART THE REPORT function FIRST CHECK IF PROBLEM #
; ######################################################
Func _VTAntiVirusINITReportRestart($url23)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Report Restart 1st Looper for Url - " & $url23 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Report Restart 1st Looper for Url - " & $url23 & @CRLF)
$pe1 = 0
; # LOOP START #
While number($pe1) <= number(IniRead(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20"))
$VTReportScan5 = _VTAntiVirusReport($url23)
If number($VTReportScan5) = 9 then
GUICtrlSetData($Edit1,"Waiting for connection to Anti-Virus 1st report server, please wait... reconnecting in " & IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") / 1000 & "s " & $pe1 & " times " & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("Waiting for connection to Anti-Virus 1st report server, please wait... reconnecting in " & IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000") / 1000 & "s " & $pe1 & " times " & @CRLF)
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "antivirustime", "60000")) ; wait 60 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Else
; # TESTING #
;_ArrayDisplay($VTReportScan3, "AV Report Array 10")
Return $VTReportScan5
ExitLoop
Endif
$pe1 = number($pe1) + 1
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # LOOP END #
WEnd
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"There seems to be a problem with the Anti-Virus scan API or Internet Connection, Exiting..." & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("There seems to be a problem with the Anti-Virus scan API or Internet Connection, Exiting..." & @CRLF)
; # WAIT SPEED #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "prospeed", "100"))
; ASK IF THE USER WANTS TO ABORT OR MARK THE DOMAIN AS BAD  --------------------------------------------------------------- FIX HERE
Return "NILL"
;;;Exit
;If number($pe2) = number(IniRead(@ScriptDir & "\settings.ini", "options", "avscanB4fail", "20")) then

Endfunc

; -------------------- ANTI-VIRUS FUNCTIONS
; -------------------------------------------------------------------------------------------------------------

; #####################################################
; # BUILD A NEW SCAN ON URL AVALIBLE ON THE AV SERVER #
; #####################################################
Func _VTAntiVirusScan($Url2Scan3)
; # DISPLAY INFO #
GUICtrlSetData($Edit1,"AntiVirus Scan Service Submit Url - " & $Url2Scan3 & @CRLF & GUICtrlRead($Edit1))
ConsoleWrite("AntiVirus Scan Service Submit Url - " & $Url2Scan3 & @CRLF)
; # BUILD THE ARRAY #
Local $aArray_AntiVirusScan[0]
Local $aArrayAVFound2 = $aArray_AntiVirusScan
;# PING CHECK INTERNET IS OK #
if GUICtrlRead($Checkbox5) = 1 Then
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
EndIf
; # GET REPORT OF URL FOR VIRUS SERVER #
$hVirusTotal = VT_Open()
$VTScan = VT($hVirusTotal,$uScan,$Url2Scan3,$APIkey)
ConsoleWrite("_VTAntiVirusScan AWNSER = " & $VTScan & @CRLF)
if not $VTScan = "" then
; # JSON DECODING RESULT #
Local $objJson10 = Jsmn_Decode($VTScan)
Local $objJson11 = Jsmn_ObjGet($objJson10, "scan_id") ; If you submit a scan this is used to recal the scan
Local $objJson12 = Jsmn_ObjGet($objJson10, "resource")
Local $objJson13 = Jsmn_ObjGet($objJson10, "url")  ; Display the scanned URL
Local $objJson14 = Jsmn_ObjGet($objJson10, "response_code") ; Used to say if it has been scanned before
Local $objJson15 = Jsmn_ObjGet($objJson10, "scan_date") ; The last time the url was scanned
Local $objJson16 = Jsmn_ObjGet($objJson10, "permalink")  ; Use this to show the scan page result
Local $objJson17 = Jsmn_ObjGet($objJson10, "filescan_id")
Local $objJson18 = Jsmn_ObjGet($objJson10, "positives") ; Used to show if a problem was found virus extra
Local $objJson19 = Jsmn_ObjGet($objJson10, "total") ; Total vendos scanned  by
Local $objJson19a = Jsmn_ObjGet($objJson10, "verbose_msg") ; verbose_msg
; # ADD RESULTS TO ARRAY #
_ArrayAdd($aArrayAVFound2,$objJson11) ; scan_id
_ArrayAdd($aArrayAVFound2,$objJson12) ; resource
_ArrayAdd($aArrayAVFound2,$objJson13) ; url
_ArrayAdd($aArrayAVFound2,$objJson14) ; response_code
_ArrayAdd($aArrayAVFound2,$objJson15) ; scan_date
_ArrayAdd($aArrayAVFound2,$objJson16) ; permalink
_ArrayAdd($aArrayAVFound2,$objJson17) ; filescan_id
_ArrayAdd($aArrayAVFound2,$objJson18) ; positives
_ArrayAdd($aArrayAVFound2,$objJson19) ; total
_ArrayAdd($aArrayAVFound2,$objJson19a) ; verbose_msg
;_ArrayDisplay($aArrayAVFound2, "AV Scan Array")
; # FORMAT THE DATE STRING SO IT CAN CALCULATE THE NUMBER OF DAYS SINCE LAST SCAN
Local $sStringJSON2 = StringReplace($objJson15, "-", "/")
Local $iDateCalc1 = _DateDiff('D',$sStringJSON2, _NowCalc())
_ArrayAdd($aArrayAVFound2,$iDateCalc1) ; Number of days what have passed since the last scan We check on 30
VT_Close($hVirusTotal) ;
; # TESTING #
;_ArrayDisplay($aArrayAVFound2, "AV Report Array 12")
; # Return the Array #
Return $aArrayAVFound2
else
Return 9 ; This tells the program there was an error and to restart it in the restart function what acts like a loop counting to 10 then exit
Endif
; # WAIT #
sleep(IniRead(@ScriptDir & "\settings.ini", "options", "prospeed", "100")) ; wait 5 seconds, the API only allows 4 request a minute and the more people who use it will slow it down
Endfunc

; -------------------- DOMAIN PULLER
; -------------------------------------------------------------------------------------------------------------

; # PULL DOMAIN NAMES FROM A FILE OR URL
Func _idpulldomainsfrom()
GUICtrlSetData($Edit1,"Pulling Domains Tool Started")
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 0) ; Set progress bar 0% done
; ------------------------------------------

; # CHECK IF THE FILE EXISTS AND IF THE USER WANTS TO CLEAR IT OUT
If FileExists(@ScriptDir & "\pulleddomains.txt") Then
; # MSGBOX #
ConsoleWrite("Would you like to erase the current export file" & @CRLF)
GUICtrlSetData($Edit1,"Would you like to erase the current export file" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Would you like to erase the current export file")
Local $MyBoxPull = MsgBox(1, "Question","Would you like erase the current export file?" & @CRLF )
; # SELECTED CHOICES FROM MSGBOX #
If $MyBoxPull == 1 Then ; OK CHOICE
; # TALK #
ConsoleWrite("Erasing File pulleddomains.txt" & @CRLF)
GUICtrlSetData($Edit1,"Erasing File pulleddomains.txt" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Erasing File")
_FileCreate("pulleddomains.txt")
ElseIf $MyBoxPull == 2 Then ; CANCEL CHOICE
; Do nothing
ConsoleWrite("Domains will be added to the file pulleddomains.txt" & @CRLF)
GUICtrlSetData($Edit1,"Domains will be added to the file pulleddomains.txt" & @CRLF & GUICtrlRead($Edit1))
If IniRead(@ScriptDir & "\settings.ini", "options", "iniset11", "1") = 1 Then _TalkOBJ("Domains will be added to the file")
EndIf
EndIf

; ------------------------------------------

; # START #
local $Pullcount = 0
Local $Pullfile = "google.com"
_FileCreate("pulledhtml.txt")

; ------------------------------------------

; GET THE USER INPUT
ConsoleWrite("Please enter the url to pull domains" & @CRLF)
GUICtrlSetData($Edit1,"Please enter the url to pull domains" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Please enter the url to pull domains")
Local $sAnswerPullList = InputBox("Please Enter Information", "Please enter the url to pull domains" & @CRLF & "Enter HTTP://(path)" & @CRLF & " Output will be in file pulleddomains.txt", "")
If $sAnswerPullList = "" Then
; Do nothing
ConsoleWrite("Nothing Selected" & @CRLF)
GUICtrlSetData($Edit1,"Nothing Selected" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Nothing Selected")
return
Else
Local $pullurl = $sAnswerPullList
ConsoleWrite("Entered URL/File = " & $pullurl & @CRLF)
GUICtrlSetData($Edit1,"Entered URL/File = " & $pullurl & GUICtrlRead($Edit1))
Endif

; ------------------------------------------

; # FILE TO DOWNLOAD TOO #
$Pullfile = @ScriptDir & "\pulledhtml.txt"

; # FETCH THE FILE FROM THE INTERNET #
ConsoleWrite("Downloading" & @CRLF)
GUICtrlSetData($Edit1,"Downloading" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Downloading")
;# PING CHECK INTERNET IS OK #
if GUICtrlRead($Checkbox5) = 1 Then
Local $iCheckPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
if $iCheckPing = 0 then _PINKCHECK()
EndIf

; DOWNLOAD THE FILE #
Local $hPullDownload = InetGet($pullurl, $Pullfile, 1, 0)
; # END INTERNET CONNECTION #
InetClose($hPullDownload)

; --------------
; # BUILD AN ARRAY OF THE TLDS LIST #
ConsoleWrite("Building TLDS list" & @CRLF)
; # IF TLDS IS ON OR OFF
if number(IniRead(@ScriptDir & "\settings.ini", "options", "domaintldson", "0")) = 0 then
Local $aArrayREADCSV[0]
_ArrayAdd($aArrayREADCSV,IniRead(@ScriptDir & "\settings.ini", "options", "domainext", "uk"))
Else
Local $aArrayREADCSV
_FileReadToArray(@ScriptDir & "\tlds.txt", $aArrayREADCSV)
_ArrayDelete($aArrayREADCSV, 0)
EndIf
; --------------
; # SET THE FILE TO EXPORT TOO #
Local $hFilePullOpen = @ScriptDir & "\pulleddomains.txt"

; ---------------------------------- LOOP 1
; # PROGRESS BAR #
GUICtrlSetData($Progress1, 10) ; Set progress bar 10% done
Local $pullvi = 0
Local $domainPullFound = "domain.com"
; # LOOP DOMAIN TLDS # BIG LOOP
for $pullvi = 0 to UBound($aArrayREADCSV) - 1
; --------------
; # READ FILE ON DISK DISK #
ConsoleWrite("Reading / Writing File - " & $Pullfile & @CRLF)
;GUICtrlSetData($Edit1,"Reading / Writing File - " & $Pullfile & @CRLF & GUICtrlRead($Edit1))
Local $pullhtml = FileRead($Pullfile) ; Read the file

; # Build and Array of the domains found
ConsoleWrite("Checking TLDS  = " & $aArrayREADCSV[$pullvi] & @CRLF)
GUICtrlSetData($Edit1,"Checking TLDS  = " & $aArrayREADCSV[$pullvi] & @CRLF & GUICtrlRead($Edit1))
$domainPullFound = StringRegExp($pullhtml, "[a-zA-Z0-9.-]+\." & $aArrayREADCSV[$pullvi], 3) ; Only look for . ALL domains unless INI file states something else.
;  # CHECK THE ARRAY IS VALID #
if IsArray($domainPullFound) = 0 Then
ConsoleWrite("No Domains found in url  = " & $pullurl & " For TLDS = " & $aArrayREADCSV[$pullvi] & @CRLF)
GUICtrlSetData($Edit1,"No Domains found in url  = " & $pullurl & " For TLDS = " & $aArrayREADCSV[$pullvi] & @CRLF & GUICtrlRead($Edit1))
EndIf

; ----------------------

for $Pullbi = 0 to UBound($domainPullFound) - 1
; # WRITE THE DOMAIN TO THE EXPORT FILE #

if number(IniRead(@ScriptDir & "\settings.ini", "options", "excludeon", "0")) = 0 then
FileWriteLine($hFilePullOpen, $domainPullFound[$Pullbi] & ",")
ConsoleWrite("Domain Recorded = " & $domainPullFound[$Pullbi] & @CRLF)
GUICtrlSetData($Edit1,"Domain Recorded = " & $domainPullFound[$Pullbi] & @CRLF & GUICtrlRead($Edit1))
$Pullcount = $Pullcount + 1
else
if _idExcluded($domainPullFound[$Pullbi]) = 0 then
FileWriteLine($hFilePullOpen, $domainPullFound[$Pullbi] & ",")
ConsoleWrite("Domain Recorded = " & $domainPullFound[$Pullbi] & @CRLF)
GUICtrlSetData($Edit1,"Domain Recorded = " & $domainPullFound[$Pullbi] & @CRLF & GUICtrlRead($Edit1))
$Pullcount = $Pullcount + 1
EndIf
EndIf
Next

; ---------------------------------- LOOP 2

; # PROGRESS BAR #
GUICtrlSetData($Progress1, 90) ; Set progress bar 60% done
;# DRUM THE BEEP #
If GUICtrlRead($Checkbox2) = 1 Then Beep(IniRead(@ScriptDir & "\settings.ini","options","freq", "400"),IniRead(@ScriptDir & "\settings.ini","options","dura", "50")) ; Beep so users know its still searching if the checkbox is valid"
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
; # LOOP END #
Next

; ---------------------------------- LOOP 1

; # CLOSE THE OPEN EDITED FILE #
FileClose($hFilePullOpen)
ConsoleWrite("Pulled Completed with = " & $Pullcount & " domains" & @CRLF)
GUICtrlSetData($Edit1,"Pulled Completed with = " & $Pullcount & " domains" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Pulled Completed with " & $Pullcount & " domains")

; ----------------------------------

; # PROGRESS BAR #
GUICtrlSetData($Progress1, 100) ; Set progress bar 100% done
; OPEN THE PULLED DOMAINS FILE
Local $iPID = Run("notepad.exe pulleddomains.txt", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)

Return

Endfunc

; -------------------------------------------------------------------------------------------------------------

; # UPDATE THE EXCLUDE LIST FROM THE INTERNET #
Func _idupdateExclude()
Local $iPID = Run("notepad.exe exclude.txt", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
Return
Endfunc

; -------------------------------------------------------------------------------------------------------------

; # UPDATE THE EXCLUDE LIST FROM THE INTERNET #
Func _idupdateTLDS()
Local $iPID = Run("notepad.exe tlds.txt", "", @SW_SHOWMAXIMIZED)
    ; Wait 10 seconds for the Notepad window to appear.
WinWait("[CLASS:Notepad]", "", 5)
Return
Endfunc

; -------------------------------------------------------------------------------------------------------------

; # GET THE EXLUDED DOMAINS LIST AND CHECK DOMAIN # return value bigger than 0 if found
Func _idExcluded($domain)
; # DELETE EXCLUDE FROM ARRAY HERE #
Local $aArrayEXCLUDECSV
_FileReadToArray(@ScriptDir & "\exclude.txt", $aArrayEXCLUDECSV)
_ArrayDelete($aArrayEXCLUDECSV, 0)
for $pullEXi = 0 to UBound($aArrayEXCLUDECSV) - 1
local $PullPosition = StringInStr(string($domain),string($aArrayEXCLUDECSV[$pullEXi]))
if $PullPosition >= 1 then
ConsoleWrite("Domain is EXCLUDED = " & $domain & @CRLF)
GUICtrlSetData($Edit1,"Domain is EXCLUDED = " & $domain & @CRLF & GUICtrlRead($Edit1))
return $PullPosition
endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Next
Endfunc

; -------------------------------------------------------------------------------------------------------------

; #################################################################
; # CHECK FOR INTERNET IS WORKING ELSE IT MAY SKIP CHECKING SITES #
; #################################################################
Func _PINKCHECK()
Local $pi = 0
for $pi = 1 to 20
sleep(7000)
ConsoleWrite("Internet Error checking again...." & @CRLF)
GUICtrlSetData($Edit1,"Internet Error checking again...." & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Internet Error checking again")
local $iPing = Ping(IniRead(@ScriptDir & "\settings.ini","options","pingserver", "google.com"),IniRead(@ScriptDir & "\settings.ini","options","pingtime","4000")) ; Fetch the ini file setting for server to ping to make sure internet is online
;Local $iPing = Ping("yahoo.com",4000)
if $iPing >= 1 then
ConsoleWrite("Internet Connection restored, continuing" & @CRLF)
GUICtrlSetData($Edit1,"Internet Connection restored, continuing" & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Internet Connection restored, continuing")
exitloop
EndIf
If $pi = 20 Then
ConsoleWrite("Internet Problem Please, Fix and Restart program...." & @CRLF)
GUICtrlSetData($Edit1,"Internet Problem, Please Fix and Restart program...." & @CRLF & GUICtrlRead($Edit1))
If GUICtrlRead($Checkbox1) = 1 Then _TalkOBJ("Internet Problem, Please Fix and Restart program")
Exit
Endif
;# DRUM THE BEEP #
If GUICtrlRead($Checkbox2) = 1 Then Beep(IniRead(@ScriptDir & "\settings.ini","options","freq", "400"),IniRead(@ScriptDir & "\settings.ini","options","dura", "50")) ; Beep so users know its still searching if the checkbox is valid"
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
next
Return 1
EndFunc

; -------------------------------------------------------------------------------------------------------------

; ########################################################
; # THIS FEATURE IS NOT AVALIBLE IN THIS VERSION MESSAGE #
; ########################################################

Func _featurenotaval()
Local $iTimeout = 5
MsgBox($MB_SYSTEMMODAL, "Not Avalible Message",@CRLF & "The feature is not avalible in this version " & @CRLF  & "Please check for updates on the developers website" & @CRLF  & "http://www.directukjobs.tk     or" & @CRLF  & "https://directukjobs.000webhostapp.com/", $iTimeout)
EndFunc

; -------------------------------------------------------------------------------------------------------------


; # GET THE META EXLUDED # return value bigger than 0 if found
Func _idMETAExcluded($htmlmeta)
Local $FoundMeta = 0
Local $aArrayMETAURL = _StringBetween($htmlmeta,"<meta",">")
; # CHECK IF THE ARRAY IS VALID #
if IsArray($aArrayMETAURL) = 0 then
ConsoleWrite("No META data found" & @CRLF)
GUICtrlSetData($Edit1,"No META data found" & @CRLF & GUICtrlRead($Edit1))
Return 0
Endif
; # LOOP 1 #
 for $mi = 0 to UBound($aArrayMETAURL) - 1
ConsoleWrite("Reading Meta Data = " & $aArrayMETAURL[$mi] & @CRLF)
GUICtrlSetData($Edit1,"Reading Meta Data = " & $aArrayMETAURL[$mi] & @CRLF & GUICtrlRead($Edit1))
; # EXCLUDE FROM ARRAY HERE #
Local $aArrayEXCLUDEMETA
_FileReadToArray(@ScriptDir & "\metaexclude.txt", $aArrayEXCLUDEMETA)
_ArrayDelete($aArrayEXCLUDEMETA, 0)
for $pullEXi = 0 to UBound($aArrayEXCLUDEMETA) - 1
local $PullPosition = StringInStr(string($aArrayMETAURL[$mi]),string($aArrayEXCLUDEMETA[$pullEXi]))
ConsoleWrite("META DATA Checking for = " & $aArrayEXCLUDEMETA[$pullEXi] & @CRLF)
;GUICtrlSetData($Edit1,"META DATA Checking for = " & $aArrayEXCLUDEMETA[$pullEXi] & @CRLF & GUICtrlRead($Edit1))
if $PullPosition >= 1 then
$FoundMeta = $FoundMeta + 1
endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Next
; # LOOP 1 #
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Next
if $FoundMeta >= 1 Then
ConsoleWrite("META EXCLUDED found = " & $FoundMeta & " times" & @CRLF)
GUICtrlSetData($Edit1,"META EXCLUDED found = " & $FoundMeta & " times" & @CRLF & GUICtrlRead($Edit1))
return $FoundMeta
Else
ConsoleWrite("No META data found" & @CRLF)
GUICtrlSetData($Edit1,"No META data found" & @CRLF & GUICtrlRead($Edit1))
Return 0
Endif
Endfunc

; -------------------------------------------------------------------------------------------------------------

; # GET THE META EXLUDED # return value bigger than 0 if found
Func _idMETAIncluded($htmlmeta)
Local $FoundMeta = 0
Local $aArrayMETAURL = _StringBetween($htmlmeta,"<meta",">")
; # CHECK IF THE ARRAY IS VALID #
if IsArray($aArrayMETAURL) = 0 then
ConsoleWrite("No META data found" & @CRLF)
GUICtrlSetData($Edit1,"No META data found" & @CRLF & GUICtrlRead($Edit1))
Return 0
Endif
; # LOOP 1 #
 for $mi = 0 to UBound($aArrayMETAURL) - 1
ConsoleWrite("Reading Meta Data = " & $aArrayMETAURL[$mi] & @CRLF)
GUICtrlSetData($Edit1,"Reading Meta Data = " & $aArrayMETAURL[$mi] & @CRLF & GUICtrlRead($Edit1))
; # EXCLUDE FROM ARRAY HERE #
Local $aArrayEXCLUDEMETA
_FileReadToArray(@ScriptDir & "\metainclude.txt", $aArrayEXCLUDEMETA)
_ArrayDelete($aArrayEXCLUDEMETA, 0)
for $pullEXi = 0 to UBound($aArrayEXCLUDEMETA) - 1
local $PullPosition = StringInStr(string($aArrayMETAURL[$mi]),string($aArrayEXCLUDEMETA[$pullEXi]))
ConsoleWrite("META DATA Checking for = " & $aArrayEXCLUDEMETA[$pullEXi] & @CRLF)
;GUICtrlSetData($Edit1,"META DATA Checking for = " & $aArrayEXCLUDEMETA[$pullEXi] & @CRLF & GUICtrlRead($Edit1))
if $PullPosition >= 1 then
$FoundMeta = $FoundMeta + 1
endif
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Next
; # LOOP 1 #
; # CHECK STOP APP #
If $Exitloop1 = 1 Then Exitloop
; # APP SPEED #
Sleep(IniRead(@ScriptDir & "\settings.ini","options","prospeed", "10"))
Next
if $FoundMeta >= 1 Then
ConsoleWrite("META INCLUDED found = " & $FoundMeta & " times" & @CRLF)
GUICtrlSetData($Edit1,"META INCLUDED found = " & $FoundMeta & " times" & @CRLF & GUICtrlRead($Edit1))
return $FoundMeta
Else
ConsoleWrite("No META data found" & @CRLF)
GUICtrlSetData($Edit1,"No META data found" & @CRLF & GUICtrlRead($Edit1))
Return 0
Endif
Endfunc

; -------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------------------------------

; END OF TRANSMISION / FILE

; -------------------------------------------------------------------------------------------------------------

; TODO
;Google safe browsing
;https://developers.google.com/safe-browsing/v4/lists
;;https://safebrowsing.googleapis.com/v4/threatLists?key=API_KEY%20HTTP/1.1%20Content-Type:%20application/json

; OTHER BITS OF INTREST BUT NO USED
; VT Functions UDF
;Func AVExample()
;;    _Crypt_Startup()
;;    Local $sFilePath = @WindowsDir & "\Explorer.exe"
;    Local $bHash = _Crypt_HashFile($sFilePath, $CALG_MD5)
;;   _Crypt_Shutdown()
;;    Local $hVirusTotal = VT_Open()
;;    Local $APIkey='fd1335fc15d0b0a35771707406c45edd0d726c9c281942e637cc679255517601'
;    ConsoleWrite(VT($hVirusTotal, $fReport, '20c83c1c5d1289f177bc222d248dab261a62529b19352d7c0f965039168c0654',$APIkey) & @CRLF)
 ;   ConsoleWrite(VT($hVirusTotal, $fScan, $sFilePath,$APIkey) & @CRLF)
 ;   ConsoleWrite(VT($hVirusTotal, $fRescan, hex($bHash),$APIkey) & @CRLF)
;;    ConsoleWrite(VT($hVirusTotal, $uReport, "http://www.virustotal.com",$APIkey) & @CRLF)
;;;    ConsoleWrite(VT($hVirusTotal, $uScan, "http://www.google.com",$APIkey) & @CRLF)
;    ConsoleWrite(VT($hVirusTotal, $Comment, hex($bHash) ,$APIkey,"Hello Word | Hola Mundo") & @CRLF)
;;    VT_Close($hVirusTotal) ;
;EndFunc   ;==>Example
