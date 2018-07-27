# PKILab

**PKI Lability Lab**

Sometimes you want to lab something to learn the set up and configuration of a technology.  Other times you just need access to a preconfigured lab to test changing some settings or a new feature etc.

If it's the former then building the lab step by step is obviously a better plan but if it's the latter you want as much of the build to be as automated as possible to get you to a working lab as quickly as can be.

This lab is based on the Lability PowerShell Module and builds a Windows Server 2016 Lab with one DC, an Offline Root CA, 1 (or 2) Enterprise Issuing CAs and a Web Server (acting as a CDP for the PKI). A Windows 10 Client with RSAT Tools can also be deployed if required.

I will *try* and add as much detail to the ReadMe as possible as to what the Lab does, how much of it is automated via DSC or via the included PS scripts and what steps need to be completed by you.

What it won't cover is how DSC works or the setting up and configuring of Lability. Mostly because I'm not an expert at it and there are already many brilliant blog posts out there on this subject and of course there's also the Lability repo too. https://github.com/VirtualEngine/Lability

This ReadMe *may* cover some of the reasoning behind why the PKI is configured the way it is.  A lot of these configurations are neither right nor wrong for me, they may be right or wrong for **YOUR** needs though, each installation would have its own requirements that may change how you go about configuring **YOUR PKI**. Again, there are plenty of good blog posts out there already that explain how and why you might make these configuration decisions.

**Disclaimer:** Feel free to copy and use this for your own purposes but just remember it is a LAB. I do try and follow best practice where ever possible or is practical but as it is a lab I haven't gone to the nth degree like configuring RBAC for example.  I am also very much 'standing on the shoulders of giants' when it comes to PowerShell and DSC so every day is a school day for me and you should not view this project as me telling you the best way to do this, it's just how I've managed to acheive it using a combination of knowledge I already had and learning new skills along the way. I am publishing it to GitHub as a place to store and version control the project for me but if it helps anybody else along the way then happy days.
