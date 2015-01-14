Readme file for p2p-client
==========================

team: "Silvan Egli, Simon Peyer"
previous contributors: "**"
date: "2015-jan-14"

1. Introduction
---------------

P2P-client stands for a Interface which ables the user to connect to clients through a Rendezvous-Server.
WIth this tool you can establish a udp connection between two Clients.
As a result the client is able to send strings very easy to another computer.


2. Documentation
----------------

We are providing two tools:
a) Rendevousserver
b) Client-Interface

a)
The Rendezvous server is in charge to store the ip,port and username of a specific user.
He alwalys provides,a function to get a list of all users which are in the database of the server, as well as a lookup function to get the IP address and Port of a specific user.

b)
The Client is intersted to establish a connection to another Client.
In this example Client_1 tries to connect to CLient_2.
We assume such a connection:



In a first stage, the Client_1 and CLient_2 will register themselves to the Rendevous server.
The Server has now IP,PORT,User_name of Client_1 and Client_2 in his database.
Therefore Client_1 can now askes for the userlist of the Rendezvous-Server, this will give him back the username of the Client_2
With this username he can now ask the server for the Ip-address and port of Client_2.
So Client_1 has now IP,Port, username of client_2.
Ans vice versa, Client_2 can do the same for Client_1.
	   _______
	  |Rendez |
	  |Server |
	  |_______|
         /        \
        /	   \
       /	    \
Client_1	     Client_2



In a second stage, the Client_1 and Client_2 connect to each other using UDP_HolePunch (Discussed later).
Now there are able to connect to each other.

	   _______
	  |Rendez |
	  |Server |
	  |_______|
        
 
     
Client_1 <--------> Client_2



3. Contents
-----------

--Explain QUeues
--Explain Keep alive
--Explain UDP_HOLEPUNCH
--Explain NATS???

4. Requirements
---------------
-two clients
-one server which is online somewhere in the INTERNET

5. Step-by-Step Guide
---------------------
--refer to 2, but using the concrete function name


6. Future trends
----------------

--saefty SSH
--tcp connection

