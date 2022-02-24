# add_user_cgi

CGI perl-based scripts to create user in Linux systems

This is a very old set of scripts and I only uploaded here to save valuable bytes of space in local storage.

I encourage not to use this script "as is".

## Some context

At the moment I build this script, there were no tools like *webmin* or any other sysadmin-oriented web based tools to assist in user management.

I managed to create a very simple perl script learning from the book: "CGI Programming on the World Wide Web" by Shishir Gundavaram.

## Things I regret

The main purpose of this script is for internal use only, so I barely followed best practices, not to mention the security considerations were awful. For example:

- Some tasks required sudo privileges. Instead of using suexec, I just recompiled apache to run as root, ignoring all recommendations against this.
- I added a basic http authentication to access the web form. I used probable the most simpler hashing algorithm available.

Anyways ... it worked for my and I did a good use of it.
