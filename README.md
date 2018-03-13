# Motivation

I wanted to be able to quickly launch new Virtual Machines in my hypervisor (Proxmox) with minimal interaction. For scenarios where a KVM is preferred over a LXC.

# Purpose 

This script will generate a debian 9 iso with a preseed configuration which provides an semi-automated installation of the standard Debian packages. It is a semi-automatic installation because it will prompt for the machine's hostname.

* Generates a random password for the root user.
* Install only the standard debian packages, `sudo`, `apt-transport-https`, and `aptitude`.
* Create an Admin user with specified password.
* Populate the Admin user's `.ssh/authorized_keys` file with the specified public key.
* Set the timezone to your timezone.
* Set the domain name to desired value or localhost.

# Requirements

You must have already downloaded a Debian 9 iso and mounted it somewhere on your computer.

```
curl -L -O https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.4.0-amd64-netinst.iso
mkdir /tmp/debian-9-iso
sudo mount -o loop debian-9.4.0-amd64-netinst.iso  /tmp/debian-9-iso
```

# Usage

Run the `create-iso.sh` script from anywhere: `/path/to/repository/create-iso.sh` and input the information as you are prompted.

The generated iso will be created in the current working directory.

When the Grub loader for the iso opens, select `Automatic Install`. After a short period of time, you will be prompted to input the hostname. The installation will automatically run to completion after that point.
