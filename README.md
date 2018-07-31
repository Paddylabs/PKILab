# Windows Server 2016 PKI Lability Lab

Sometimes you want to lab something to learn the set up and configuration of a technology.  Other times you just need access to a preconfigured lab to test changing some settings or a new feature etc.

If it's the former then building the lab step by step is obviously a better plan but if it's the latter you want as much of the build to be as automated as possible to get you to a working lab as quickly as can be. This project is about the latter.

This lab is based on the Lability PowerShell Module and builds a Windows Server 2016 Lab with one DC, an Offline Root CA, 1 (or 2) Enterprise Issuing CAs and a Web Server (acting as a CDP for the PKI). A Windows 10 Client with RSAT Tools can also be deployed if required.

I will *try* and add as much detail to the ReadMe as possible as to what the Lab does, how much of it is automated via DSC or via the included PS scripts and what steps need to be completed by you.

What it won't cover is how DSC works or the setting up and configuring of Lability. Mostly because I'm not an expert at it and there are already many brilliant blog posts out there on this subject and of course there's also the Lability repo too. https://github.com/VirtualEngine/Lability

This ReadMe *may* cover some of the reasoning behind why the PKI is configured the way it is.  A lot of these configurations are neither right nor wrong for me, they may be right or wrong for **YOUR** needs though, each installation would have its own requirements that may change how you go about configuring **YOUR PKI**. Again, there are plenty of good blog posts out there already that explain how and why you might make these configuration decisions.

## Disclaimer:
Feel free to copy and use this for your own purposes but just remember it is a _LAB_. I do try and follow best practice where ever possible or is practical but as it is a lab I haven't gone to the nth degree like configuring RBAC for example.  I am also very much 'standing on the shoulders of giants' when it comes to PowerShell and DSC so every day is a school day for me and you should not view this project as me telling you the best way to do this, it's just how I've managed to acheive it using a combination of knowledge I already had and learning new skills along the way. I am publishing it to GitHub as a place to store and version control the project for me but if it helps anybody else along the way then happy days.

### Instructions

After opening PowerShell as Administrator and importing the Lability module run PKILab.ps1.

This will fire up 4 VMs and configure them as follows:-

# DC01 - Domain Controller
..*Installs an Active Directory domain called corp.paddylab.net
Creates an A Record in DNS for WEB01
Creates OUs for LAB Computers
Creates a User called User1 and places it in Domain and Enterprise Admins with a password of Password1
Creates a AD Intergrated DNS Forward Lookup Zone for paddylab.net
Creates a CNAME record in the paddylab.net zone that points to we01.corp.paddylab.net

# WEB01 - Web Server
Joins the computer to the corp.paddylab.net domain.
Install IIS
Creates a directory c:\PKI
Shares C:\PKI with Share name PKI
Copies PKI_IIS_Config.ps1 to the C:\Resources folder
YOU NEED TO RUN PKI_IIS_Config.ps1 which does the following:-
Adds C:\PKI as a virtual Directory to the Default Web Site
Enables Directory Browsing for the virtual directory
Enabled Double Escaping for the virtual directory (because some of the file names will end with +)

# RootCA - Offline Root CA
IS NOT JOINED TO THE DOMAIN
Installs AD Certificate Services role
Creates file capolicy.inf in c:\windows\ (this contains settings required before installing a CA)
Copies Root_CA_Setup.ps1 and Root_CA_Config.ps1 to c:\resources
YOU NEED TO RUN ROOT_CA_SETUP.ps1 which does the following:-
Installs an Offline Root CA using the settings in the script (also depends on the capolicy.inf file)
YOU NEED TO RUN ROOT_CA_Config.ps1 which does the following:-
Configures the Offline Root CA as per our settings in the file.

# SubCA01 - Enterprise Issuing CA
Joins to the corp.paddylab.net domain
Installs AD Certificate Services Role
Copies the file SubCA_CAPolicy.inf to c:\windows (This needs to be renamed later to capolicy.inf)
Copies Sub_CA_Config.inf and Sub_CA_Setup.inf to c:\resources