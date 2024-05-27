- GSM_Linux_Kernel_LPE_Nday_Exploit
This worked on Ubuntu 6.5.*, lets try for other Linux
- https://github.com/jmpe4x/GSM_Linux_Kernel_LPE_Nday_Exploit/tree/main
- https://www.jmpeax.dev/The-tale-of-a-GSM-Kernel-LPE.html

On Ubuntu try always for escalation:
```sh
$ find /usr/lib/x86_64-linux-gnu/enlightenment/ -perm /4000 -ls 2>/dev/
./utils/enlightenment_sys
./utils/enlightenment_ckpasswd
./utils/enlightenment_backlight
./modules/cpufreq/linux-gnu-x86_64-0.23.1/freqset
```
Si ceci apparait, Essaye cet exploit:
- https://github.com/MaherAzzouzi/CVE-2022-37706-LPE-exploit
