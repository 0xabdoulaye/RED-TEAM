https://www.vinnie.work/blog/2021-03-19-virtualmachine-to-docker

https://andygreen.phd/2022/01/26/converting-vm-images-to-docker-containers/

```
root@nenandjabhata:~/images# ls
driftingblues6_hmv-disk001.vmdk  driftingblues6_hmv.ovf  driftingblues6.ova  driftingblues6.zip
root@nenandjabhata:~/images# qemu-img convert -f vmdk driftingblues6_hmv-disk001.vmdk -o raw disk.raw
qemu-img: Invalid parameter 'raw'
root@nenandjabhata:~/images# qemu-img convert -f vmdk driftingblues6_hmv-disk001.vmdk -O raw disk.raw


sudo apt-get install parted
root@nenandjabhata:~/images# parted -s disk.raw unit b print
Model:  (file)
Disk /root/images/disk.raw: 3221225472B
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start        End          Size         Type      File system     Flags
 1      1048576B     3034578943B  3033530368B  primary   ext4            boot
 2      3035626496B  3220176895B  184550400B   extended
 5      3035627520B  3220176895B  184549376B   logical   linux-swap(v1)

root@nenandjabhata:~/images# 
root@nenandjabhata:~/images# sudo mount -o loop,ro,offset=1048576 disk.raw ../mnt/noob/
root@nenandjabhata:~/images# rm -rf mnt/noob/
root@nenandjabhata:~/images# ls -la ../mnt/noob/
total 104
drwxr-xr-x 23 root root  4096 Mar 17  2021 .
drwxr-xr-x  3 root root  4096 Dec 21 10:52 ..
drwxr-xr-x  2 root root  4096 Mar 17  2021 bin
drwxr-xr-x  3 root root  4096 Mar 17  2021 boot
drwxr-xr-x  3 root root  4096 Mar 17  2021 dev
drwxr-xr-x 67 root root  4096 Mar 17  2021 etc
drwxr-xr-x  2 root root  4096 Mar 17  2021 home

```