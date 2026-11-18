# Sprint 1 build log

Chronological record of building the Mainkai lab: what I did, what didn't go as expected, how I fixed it.

## Environment
- Proxmox VE 9.2 on i5-6500, 16 GB RAM; lab VMs on ZFS dataset `photos/lab`
- Isolated network `vmbr1` (10.10.10.0/24), NAT to internet, no access to home network

## 2026-11-04: Home vs lab network segmentation
- **Did:** initial network configuration on Proxmox (creating lab bridge, iptables rules that isolate lab)
- **Problem:** ping from a throaway container to PC timed out, had no route back to 10.10.10.0/24
- **Fix:** add the route from the PC to the Proxmox host

## 2026-11-05: Proxmox storage and first VMs
- **Did:** created DC01 (Server 2022) and WS01 (Windows 11 Enterprise) VMs
- **Problem:** only 40 GB free on `local-lvm`
- **Fix:** ZFS dataset on the NVMe with a 300 GB quota, added as storage `lab`

## 2026-11-09: Install, update and configure DC01 & WS01
- **Did:** install VirtIO for internet access, update to latest release, and configure DC01 & WS01 (date & time, network adapter, DNS)
- **Problem 1:** WS01 ignored the “Press any key to boot from CD” keypresses
- **Fix:** started the VM from inside the console (or used the UEFI Boot Manager)
- **Problem 2:** DC01 shown at 99.9% memory usage
- **Fix:** display effect of ballooning being off, real usage checked in Task Manager

## 2026-11-10: VM validation & snapshots, tool setup
- **Did:** last VM checks, installed Obsidian / VScode, created lab Github account 
- **Problem 1:** pinging DC01 from the PC timed out
- **Fix:** added an allow rule - Windows Firewall blocks incoming ICMP by default
- **Problem 2:** no copy/paste and no Shift possible in the Proxmox console
- **Fix:** switched to RDP (`mstsc`)

## 2026-11-11: Create ELK01 VM, install, update and configure
- **Did:** installed Ubuntu Server, updated and configured it (date & time, storage, network interface)
- **Problem 1:** `sudo` rejected the ELK01 password
- **Fix:** it was saved without capitals (console Shift problem); changed it with `passwd` over SSH
- **Problem 2:** DC01 Administrator password had the same problem
- **Fix:**  changed over RDP with Ctrl+Alt+End

## 2026-11-12: DC01 as domain controller
- **Did:** installed AD DS on DC01, pointed DC's DNS at itself and added an internet forwarder

## 2026-11-13: The users of the mainkai.lan domain
- **Did:** created the Organizational Unit and Groups (by department), initialized all users from the company in AD
- **Problem:** `New-ADUser` failed on password complexity but left a disabled account behind
- **Fix:** set the password and enabled it with `Set-ADAccountPassword` and `Enable-ADAccount`

## 2026-11-14: WS01 joins the domain
- **Did:** added WS01 to the domain and to the Organizational Unit

## 2026-11-16: Windows log expansion
- **Did:** created a GPO and adjusted it to expand the default Windows logs to something more suitable for what a SOC needs
- **Problem:** Audit settings showed “No Auditing” despite the GPO being applied
- **Fix:** the GPO lacked the _Audit Policy Configuration_ extension; re-saving one audit setting registered it, verified with `gpresult /h` and `auditpol`

## 2026-11-17: Sysmon
- **Did:** Enabled Sysmon and loaded it with a custom configuration `sysmonconfig.xml` (from github.com/olafhartong/sysmon-modular)
- **Problem:** tried to move a file to a directory / location that didn't exist yet
- **Fix:** create the directory first, then move the file

## 2026-11-18: Snapshot rollback blocked by automatic ZFS snapshots
- **Did:** Triggered a series of events to see how they were logged and resurfaced through Event Viewer. Tried to roll back WS01 to `s07-before-events` at the end of the day
- **Problem:** Proxmox refused: "s07-before-events is not most recent snapshot", although it was the newest in Proxmox's list
- **Fix:** excluded the lab (`zfs set com.sun:auto-snapshot=false photos/lab`, inherited by all VM disks), deleted the existing automatic snapshots on the lab disks (dry run with `zfs destroy -nv` first), then rolled back successfully. `zfs-auto-snapshot` had been snapshotting all VM disks every 15 minutes. ZFS can only roll back to the newest snapshot