# mainkai-soc-lab
Home SOC lab experimental environment

Mainkai Logistik is a fictitious German logistics company with 10 employees, headquartered in Frankfurt. It organises road and air freight for clients across Germany: booking carriers, preparing
transport and customs documents, and tracking shipments from pickup to delivery.

## The company's IT
Like most small forwarders, Mainkai rents its business software as cloud services:
- A freight forwarding platform for bookings, documents and invoicing
- Customs declarations to the German customs system (ATLAS)
- EDI connections to customers and carriers
- Email and office software

All of these depend on the office backbone: a Windows domain (Active Directory),
staff workstations, and shared files.

## What this lab simulates
The lab rebuilds that backbone - the place where most real attacks on logistics
companies begin - and defends it:

| Component | Lab machine |
| --- | --- |
| Domain controller (Active Directory, DNS) | DC01 - Windows Server 2022 |
| Employee workstation | WS01 - Windows 11 Enterprise |
| SIEM (log collection and detection) | ELK01 - Elastic Stack |
| Attacker | Kali Linux |

Write-ups follow every two weeks.
