# Powershell-Based Botnet
> Setup a network of zombies, manipulate using RCE and manage via a UI.

The client(victim) code is written in Powershell so that every Windows user with Powershell installed
can get infected easily without the need to install additional software (run the client using a base64-encoded powershell string)

The host is a webserver (written in Go) running locally (you can of course host the webapp somewhere publicly).
