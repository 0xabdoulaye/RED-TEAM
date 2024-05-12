## Converting OVA to Raw Data
```sh
root@Hacking-VM:~/files# tar -xvf hundred.ova
hundred.ovf
hundred-disk001.vmdk
root@Hacking-VM:~/files# qemu-img convert -f vmdk hundred-disk001.vmdk -O raw Hunred.raw 

```


```sh
root@Hacking-VM:~/files# parted -s Hunred.raw unit b print
Model:  (file)
Disk /root/files/Hunred.raw: 8589934592B
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start        End          Size         Type      File system     Flags
 1      1048576B     7565475839B  7564427264B  primary   ext4            boot
 2      7566523392B  8588886015B  1022362624B  extended
 5      7566524416B  8588886015B  1022361600B  logical   linux-swap(v1)  swap


root@Hacking-VM:~/files# mount -o loop,ro,offset=1045876 Hunred.raw mnt/
mount: /root/files/mnt: wrong fs type, bad option, bad superblock on /dev/loop0, missing codepage or helper program, or other error.
       dmesg(1) may have more information after failed mount system call.

root@Hacking-VM:~/files# losetup -d /dev/loop0 
root@Hacking-VM:~/files# mount -o loop,ro,offset=1048576 -t ext4 Hunred.raw mnt/
root@Hacking-VM:~/files# ls mnt/
bin   dev  home        initrd.img.old  lib32  libx32      media  opt   root  sbin  sys  usr  vmlinuz
boot  etc  initrd.img  lib             lib64  lost+found  mnt    proc  run   srv   tmp  var  vmlinuz.old

```

## Generate the Docker :
```sh
root@Hacking-VM:~/files# tar -C mnt/ -czf Myimage.gz .
root@Hacking-VM:~/files# ls -lh
total 2.4G
-rw-rw----  1 man  daemon 445M Aug  2  2021 hundred-disk001.vmdk
-rw-r--r--  1 root root   445M Aug  2  2021 hundred.ova
-rw-r-----  1 man  daemon 7.9K Aug  2  2021 hundred.ovf
-rw-r--r--  1 root root   8.0G May 12 09:21 Hunred.raw
drwxr-xr-x 18 root root   4.0K Aug  2  2021 mnt
-rw-r--r--  1 root root   332M May 12 09:38 Myimage.gz
root@Hacking-VM:~/files#

```

## Import it

```sh
root@Hacking-VM:~/files# docker import Myimage.gz hundred_box


```

Je vais donc lancer la Machine et activer les services 

```sh
root@Hacking-VM:~# docker run -dt --network=host hundred_box bash
root@Hacking-VM:/# service --status-all
 [ - ]  apparmor
 [ - ]  console-setup.sh
 [ - ]  cron
 [ - ]  dbus
 [ ? ]  hwclock.sh
 [ - ]  keyboard-setup.sh
 [ ? ]  kmod
 [ ? ]  networking
 [ + ]  nginx
 [ - ]  procps
 [ - ]  rsyslog
 [ + ]  ssh
 [ + ]  udev
 [ + ]  vsftpd


```