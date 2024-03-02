# VMWoL
Wake-on-Lan for Virtual Machines

A simple Powershell script listening UDP (by default on port 99) for Magic Packet and capable of starting VMs with specified MAC address on Hyper-V.

# Requirements
- Terminal must run as Administrator or at least as a user member of the Hyper-V Administrator group
- VM network adapter MAC address must be static if you want to use a smartphone app for waking up your VM
- NAT config must redirect UDP to the host and not the guest machine unlike the true WoL standard

# Context
Script made after 2h of learning about Powershell, feel free to correct me or propose better way of doing.

# Rights
No need to credit, use it as you want
