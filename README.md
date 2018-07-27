# PKILab

PKI Lability Lab

Sometimes you want to lab something to learn the set up and configuration of something.  Other times you just need access to a preconfigured lab to test changing some settings or test a new feature etc.

If its the former then building the lab step by step is obviously better but if it's the latter you want as much of the lab automated as possible to get you to a working lab as quickly as can be.

This lab is based on the Lability PowerShell Module and builds a Windows Server 2016 Lab with one DC, an Offline Root CA, 1 (or 2) Enterprise Issuing CAs and a Web Server (acting as a CDP for the PKI). A Windows 10 Client with RSAT Tools can also be deployed if required.

I will try and add as much detail to the ReadMe as possible as to what the Lab does, how much of it is automated via DSC or via the included PS scripts and what steps need to be completed by you.

What it won't cover is how DSC works or the setting up and configuring of Lability.  There are some brilliant blog posts out there on this subject and of course the Lability Repo too. https://github.com/VirtualEngine/Lability

It 'may' cover some of the reasoning behind why the PKI is configured the way it is.  A lot of these configurations are neither right or wrong for me, they may be right or wrong for YOUR needs though, each installation would have its own requirements that may change how you go about configuring YOUR PKI. Again, there are plenty of good blog posts out there already that explain how and why you might make these configuration decisions.

Disclaimer: Feel free to copy and use this for your own purposes but it is a LAB. I am also very much 'standing on the shoulders of giants' when it comes to PowerShell and DSC so every day is a school day for me and you should not view this project as the best way to do this.  I am publishing it to GitHub as a place to store and version control the project for me and if it helps anybody else along the way then happy days.
