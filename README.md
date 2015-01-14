Readme file for p2p-client
==========================

team: "Silvan Egli, Simon Peyer"
previous contributors: "**"
date: "2015-jan-14"

1. Introduction
---------------
NAT stands for Network Address Translation was introduced to solve the problem of the
internet running out of addresses. It can for example be implemented on a router in
a home network. The router has a public ip-address, lets assume 190.52.187.2. Now it 
can assign new (private )ip-addresses to devices in it's network.  Assume a laptop gets assigned
10.0.0.1. When the laptop sends a packet from port 4111 out of the home network the 
router replaces the source address and source port (10.0.0.1/4111) with it's public ip
and a new port e.g (190.52.187.2/60344) it remembers this mapping (10.0.0.1/4111 -> 190.52.187.2/60344)
in a table. When a packet for the laptop comes in from the internet the router replaces
the destination address and port according to the mapping. i.e replaces  190.52.187.2/60344
with 10.0.0.1/4111
A disadvantage of NAT is that the laptop (generally all devices in a network with NAT) 
can't act as a public server. The reason is that the laptop has no public ip-address anymore as the router
can assign arbitrary private ip-addresses to it.

The avoiding technique used for NAT in this project is UDP Hole Punching and will be explained
later in this document.

This project is a interface that enables two clients to connect through a Rendezvous-Server.
With this tool it is possible to establish a UDP connection between two clients.
As a result the clients are able to send strings to each other.


2. Idea
----------------

We are providing two tools:
a) Rendezvous-Server
b) Client-Interface

a)
The Rendezvous server is in charge to store the public ip, port and username of a specific user.
He always provides,a function to get a list of all users which are in the database of the server, as well 
as a lookup function to get the IP address and Port of a specific user.
The Rendezvous Server must be deployed in the public internet meaning it must have a well known 
public ip and a port and must be accessible on that.

b)
The Client is interested to establish a connection to another Client.
In this example Client_1 tries to connect to CLient_2.
We assume such a connection:

(private: 193.0.0.2/40001) 		(public: 188.4.51.191)		(public	201.2.68.74/8888)		(public: 194.18.15.51)		(private: 10.0.0.1/40001)
	   Client_1	 --------------------	NAT_1  -------------------	Rendezvous	------------------	NAT_2  --------------------- Client_2
															          Server
								
								NAT_1 Translation Table				 Database				NAT_2 Translation Table

In a first stage, the Client_1 and CLient_2 will register themselves to the Rendezvous server.
After registering the entries of the tables and the database look the following

NAT_1 Translation Table:						
193.0.0.2/40001	<-> 188.4.51.191/ 50057	

NAT_2 Translation Table
10.0.0.1/40001 <-> 194.18.15.51/61442

Database:
Client_1:	188.4.51.191/ 50057	
Client_2:	194.18.15.51/61442

The Server has now public IP,PORT,User_name of Client_1 and Client_2 in its database.
Therefore Client_1 can now ask for the userlist of the Rendezvous-Server, this will give him back 
amongst others the username of the Client_2.
With this username he can now ask the server for the pubil Ip-address and port of Client_2.
So Client_1 has now IP,Port, username of client_2.
Ans vice versa, Client_2 can do the same for Client_1.
									

In a second stage, the Client_1 and Client_2 connect to each other using UDP_HolePunch (Discussed later).
Now they are able to connect to each other.

	   _______
	  |Rendez |
	  |Server |
	  |_______|
        
And finally they should be directly connected
     
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

