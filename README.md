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

This project is an interface written in Eiffel that enables two clients to connect through a Rendezvous-Server.
With this tool it is possible to establish a UDP connection between two clients.
As a result the clients are able to send strings to each other.


2. Idea
----------------

We are providing two tools:
a) Rendezvous-Server
b) Client-Interface

a)
The Rendezvous server is in charge to store the public IP, port and username of a specific user.
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
With this username he can now ask the server for the public IP-address and port of Client_2.
So Client_1 has now IP,Port, username of client_2.
Ans vice versa, Client_2 can do the same for Client_1.
									

In a second stage, the Client_1 and Client_2 connect to each other using UDP_HolePunch.
This works the like the following:
Now that both endpoints have public IP/port of the other they start sending UDP Packets
to each other. They must both send because another issue of NAT devices is that they
often won't let a packet pass from the internet to the private network without having 
seen an outgoing packet with the same IP/port before. When a NAT device sees a packet
going out to the internet it creates a rule. This means it remembers the mapping
(in the Translation Table) and also the source and destination IP/port. By sending out
a UDP packet we "punch a hole" in the NAT device such that packets from the other
peer can come in. Therefore the name UDP Hole Punch

Finally if both peers have received a UDP packet from the other one they are connected.
		   ___________
		  |Rendezvous |
		  |  Server   |
		  |___________|
	   
Client_1 <--------> Client_2

In UDP there is no explicit connection teardown like in TCP. So the NAT's generally
don't know when a rule won't be used anymore. Therefore they have Idle Time-outs after
which the rule is deleted. To avoid this both endpoints have to send so called keep-alive
packets to each other periodically.


3. Contents
-----------

--Explain QUeues
--Explain NATS???

4. Requirements
---------------
First there are needed two clients and one server which is running on public IP/port.
Both the Rendezvous_Server and the Client_Interface make use of the Eiffel net, thread
and time library. Furthermore for running multiple threads the Concurrency mode of
the project must be set to EiffelThread in the project settings (or in the .ecf file).
Additionally the project must use a multithreaded precompiled library. This
can also be changed in the project settings by setting the Location of the precompiled
library to $ISE_PRECOMP\base-mt-safe.ecf or by setting the following entry in the .ecf file:
<precompile name="base_pre" location="$ISE_PRECOMP\base-mt-safe.ecf"/>



5. Step-by-Step Guide
---------------------
--refer to 2, but using the concrete function name

6. Example
---------------------
For better understanding there is an implementation of a peer-to-peer chat which can be
found in eiffel-p2p/Client_Interface/examples

7. Future trends
----------------

--safety SSH
--tcp connection

