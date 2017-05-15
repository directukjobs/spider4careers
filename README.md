# spider4careers
Find any job/vacancy direct to employers without using recruiters (Private Jobs Search Engine)
Join the hunt in finding jobs. Here you will find the newest versions of the software and instructions.

Join the hunt in finding jobs. Here you will find the newest versions of the software and instructions.

WARNING:

This software is "USE AT OWN RISK" and "AS IS". Do not use this software for crime or other nasty stuff. There is a built in Anti-Virus but by no means does it mean it's safe. You are going to be scanning millions of untested and possibly unsafe websites. Make sure your Anti-Virus is up to date and you have backed up your computer. You could get a virus, you could see porn, you could see all sorts of nasty stuff. YOU ARE WARNED! In the next release, we will combine "GOOGLE SAFESURF". This software is on PROTOTYPE LEVEL meaning it's still in concept form and not even close to ALFA OR BETA Release. The are some parts of this program what have not been completed. There is ZERO support for this software. This software was only tested on windows 10. Anti-Virus software may report this software as a false positive and give no explanation as to why and what for.

Warning on using captured EMAILS. The program can capture emails only when a match of the search algo was found. It will display the emails it found on the website. Before you use these emails you need to understand that some admins put fake emails out to catch spammers. For this reason, we don't recommend you use them and instead apply for jobs via the normal route. Its also always a good idea to only use an email address other than your normal one. Create a new email account on Google, Yahoo and apply for jobs in this manner. In case you get BLACKLISTED. If you are a recruiter or marketer use something like https://mailchimp.com/ to do marketing and again an email account other than your own. We been in two minds of giving this out and is strickly use at own risk. The reason its there is because from time to time, the web appliction service on some websites dont work. You been warned.

This software was only tested on windows 10. Anti-Virus software may report this software as a false positive and give no explanation as to why and what for. To bypass it just send it to your vendor and report it as a false positive, windows defender may do the same thing. Add an exclusion in your anti-virus to allow this folder or click allow is all up to your own risk. If all else fails to search for the code on this site or on GitHub and run the script with AutoIT.

WARNING: This is still a concept and very bloated with 4500 lines of code already. Meaning it can be slow. If you click on something, WAIT 5 Seconds before it may respond. It uses to be a simple script and is growing fast. 

TO START THE SEARCH FOR JOBS just press START. Easy as that and follow the prompts. 

You will need your OWN API for the antivirus. Just Register at https://www.virustotal.com/en/
One you have registered get the API key and enter it in the program under Anti-Virus Set API Key. The API is free and you should not pay for it. It is limited to 4 queries a minute and when enabled greatly slows down the process.

Combines with the Anti-Virus we recommend you use Google chrome as your main browser and ensure SAFE SURF is enabled as well as having your computer's antivirus up to date and active. We use AVG and already had stopped 2 viruses from entering the computer. SO USE AT OWN RISK and TAKE CARE. GET AVG FREE HERE 

If you know of sites you don't want to see. Use the EXCLUDE.txt doc and make sure its ENABLED in the menu under excluding DOMAINS on/off. This option looks for keywords to exclude, so if you said "google" it will exclude every domain named with google Example: googlemail, googlestats all will be excluded from downloading and processing.



NOTE TO STOP THIS PROGRAM AND EXIT YOU MUST PRESS THE ESCAPE [ESC] button on your keyboard to stop it. Then Click Exits

BASICS

To start looking for Jobs you need to understand what this program does. Its main job is to process domain names in a file. Once the domain is found it check if it needs to scan it with the Anti-virus scanner.

From here it stores the information in its own database. (SQLite) It then downloads the domain URL to a file on your computer and scans the HTML for the links and if selected email on the page. Depending on what Searching ALGO strings selected. Example: Careers.

If it finds the careers algos it will alert you to finding the careers page and display the links and emails it found.



When the following dialog shows, avoid clicking on the "EXIT SCRIPT" as it will quit the program, just press the X or select the item you want and click copy data.



There are many other settings and tools in the menu and your best bet is if you don't know what they do, DONT CLICK ON THEM and leave everything as default.

When a Career page is found. Another URL will open to POST A JOB here at DirectUKJobs. You can disable this in the menu when you click SHOW Post a Job On/Off

When looking at the careers page on the website it might be difficult to find the links, a popup might show you some links it found based on the algo. Normally the vacancies and careers are in the MENU or Bottom of the webpage.

Please use the Contact Us here for more info and recommendations.

Things still to be done in this app.

Massive Database rework

Deep Search

Email Functions

Collaboration functions

You're going to be just like Neo from the Matrix searching the internet for the white rabbit, except our software is faster! In fact, you can search for the white rabbit, it's not exclusively for the UK or Careers!


This program is not new, a few years back I wrote shotgun CV program what blasted out a CV to as many email address it could find on the internet. NOT a good Idea it seems. It also searches websites for jobs but failed miserably. This program, on the other hand, is much better thought out and much better at finding real jobs

DOWNLOAD THE PROGRAM

Direct Download = Spider4Careers (Version 0)

Package and Source on GitHub where It may be worked on.

Alternative Download = https://github.com/directukjobs/spider4careers

and here is the source code here too.... Nothing to hide   SourceCode (Version 0)

Copy the entire folder to where you want to run this software from and double click on spider4careers.exe to start, This will create some files in the folder.

By default, the domain lists included is not the 3million domain list. It's mostly the jobs recruiters are pedaling. To get the 3 Million UK domain list click here. Backup the numbered files and domains.txt file to another folder and copy the 3million job pack into your Spider4Careers folder. Some domains.txt files tell the program what files to run and also if they come from a website if enabled will update them if there are changes. You can also create your own list, If you know of a website with domains you want to Pull there is a pull to in the menu, Simply create the domain files numbered and then create a domains.txt file to tell the program how many of them there or are or amend the current one to add the extra file.

CHECK BACK HERE SOON FOR JOB PACKS

3MilJobPackUK

JobPackZA

JobPackUSA

and more



If you wish to see the database get a database viewer at

https://github.com/sqlitebrowser/sqlitebrowser/releases
