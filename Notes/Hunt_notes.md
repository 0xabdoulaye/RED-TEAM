**Subs**

```
─# subfinder -dL target.txt > subs.txt

               __    _____           __         
   _______  __/ /_  / __(_)___  ____/ /__  _____
  / ___/ / / / __ \/ /_/ / __ \/ __  / _ \/ ___/
 (__  ) /_/ / /_/ / __/ / / / / /_/ /  __/ /    
/____/\__,_/_.___/_/ /_/_/ /_/\__,_/\___/_/

                projectdiscovery.io

[INF] Current subfinder version v2.6.3 (latest)
[INF] Loading provider config from /root/.config/subfinder/provider-config.yaml
[INF] Enumerating subdomains for hubspot.net
[INF] Found 641 subdomains for hubspot.net in 4 seconds 29 milliseconds
[INF] Enumerating subdomains for *.hs-sites.com
[INF] Found 0 subdomains for *.hs-sites.com in 14 seconds 126 milliseconds
[INF] Enumerating subdomains for hubspot.com
[INF] Found 1001 subdomains for hubspot.com in 16 seconds 366 milliseconds
[INF] Enumerating subdomains for hubspotemail.net
[INF] Found 2704 subdomains for hubspotemail.net in 14 seconds 943 milliseconds

┌──(venv)─(root㉿xXxX)-[~/Hunting]
└─# subfinder -d hs-sites.com > hs.txt 

               __    _____           __         
   _______  __/ /_  / __(_)___  ____/ /__  _____
  / ___/ / / / __ \/ /_/ / __ \/ __  / _ \/ ___/
 (__  ) /_/ / /_/ / __/ / / / / /_/ /  __/ /    
/____/\__,_/_.___/_/ /_/_/ /_/\__,_/\___/_/

                projectdiscovery.io

[INF] Loading provider config from /root/.config/subfinder/provider-config.yaml
[INF] Enumerating subdomains for hs-sites.com
[INF] Found 868 subdomains for hs-sites.com in 30 seconds 766 milliseconds

```
```
└─# cat hs.txt | anew subs.txt

└─# cat target.txt| assetfinder --subs-only > subs2.txt

└─# wc subs2.txt 
 1237  1237 35165 subs2.txt
                                                                                               
┌──(venv)─(root㉿xXxX)-[~/Hunting]
└─# wc subs.txt 
  5214   5214 159002 subs.txt
    
└─# wc subs.txt 
  5313   5313 161669 subs.txt

```
**Live subs**
```
└─# cat subs.txt| httprobe| tee -a livesubs.txt


```

```
└─# ffuf -u "https://learn.hubspot.com/FUZZ" -w /usr/share/wordlists/dirb/common.txt 

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : https://learn.hubspot.com/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

.htaccess               [Status: 403, Size: 282, Words: 20, Lines: 10, Duration: 211ms]
.htpasswd               [Status: 403, Size: 282, Words: 20, Lines: 10, Duration: 284ms]
.hta                    [Status: 403, Size: 282, Words: 20, Lines: 10, Duration: 278ms]
admin                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 640ms]
auth                    [Status: 301, Size: 321, Words: 20, Lines: 10, Duration: 475ms]
backup                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 331ms]
blog                    [Status: 301, Size: 321, Words: 20, Lines: 10, Duration: 430ms]
blocks                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 449ms]
cache                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 252ms]
calendar                [Status: 301, Size: 325, Words: 20, Lines: 10, Duration: 233ms]
comment                 [Status: 301, Size: 324, Words: 20, Lines: 10, Duration: 332ms]
course                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 274ms]
composer                [Status: 200, Size: 2087, Words: 560, Lines: 67, Duration: 1270ms]
error                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 399ms]
filter                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 328ms]
files                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 366ms]
group                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 265ms]
install                 [Status: 301, Size: 324, Words: 20, Lines: 10, Duration: 307ms]
lang                    [Status: 301, Size: 321, Words: 20, Lines: 10, Duration: 210ms]
lib                     [Status: 301, Size: 320, Words: 20, Lines: 10, Duration: 368ms]
local                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 314ms]
login                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 223ms]
media                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 382ms]
mod                     [Status: 301, Size: 320, Words: 20, Lines: 10, Duration: 254ms]
message                 [Status: 301, Size: 324, Words: 20, Lines: 10, Duration: 899ms]
my                      [Status: 301, Size: 319, Words: 20, Lines: 10, Duration: 214ms]
notes                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 227ms]
package                 [Status: 200, Size: 777, Words: 215, Lines: 30, Duration: 228ms]
pix                     [Status: 301, Size: 320, Words: 20, Lines: 10, Duration: 232ms]
portfolio               [Status: 301, Size: 326, Words: 20, Lines: 10, Duration: 217ms]
question                [Status: 301, Size: 325, Words: 20, Lines: 10, Duration: 292ms]
rating                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 285ms]
README                  [Status: 200, Size: 665, Words: 110, Lines: 24, Duration: 292ms]
report                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 652ms]
repository              [Status: 301, Size: 327, Words: 20, Lines: 10, Duration: 835ms]
robots                  [Status: 200, Size: 26, Words: 3, Lines: 3, Duration: 210ms]
robots.txt              [Status: 200, Size: 26, Words: 3, Lines: 3, Duration: 203ms]
rss                     [Status: 301, Size: 320, Words: 20, Lines: 10, Duration: 359ms]
search                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 311ms]
server-status           [Status: 403, Size: 282, Words: 20, Lines: 10, Duration: 373ms]
tag                     [Status: 301, Size: 320, Words: 20, Lines: 10, Duration: 229ms]
tags                    [Status: 200, Size: 615, Words: 64, Lines: 19, Duration: 254ms]
theme                   [Status: 301, Size: 322, Words: 20, Lines: 10, Duration: 269ms]
user                    [Status: 301, Size: 321, Words: 20, Lines: 10, Duration: 434ms]
vendor                  [Status: 301, Size: 323, Words: 20, Lines: 10, Duration: 352ms]
webservice              [Status: 301, Size: 327, Words: 20, Lines: 10, Duration: 327ms]


https://learn.hubspot.com/package
{
    "name": "totaralms",
    "private": true,
    "description": "Totara LMS",
    "devDependencies": {
        "async": "1.5.2",
        "eslint": "3.7.1",
        "gherkin-lint": "2.11.1",
        "grunt": "1.0.1",
        "grunt-contrib-less": "1.3.0",
        "grunt-contrib-uglify": "1.0.1",
        "grunt-contrib-watch": "1.0.0",
        "grunt-eslint": "19.0.0",
        "grunt-stylelint": "0.6.0",
        "semver": "5.3.0",
        "shifter": "0.5.0",
        "stylelint": "7.4.1",
        "stylelint-checkstyle-formatter": "0.1.0",
        "xmldom": "0.1.22",
        "xpath": "0.0.23",
        "autoprefixer": "^6.3.7",
        "grunt-postcss": "^0.8.0",
        "rtlcss": "^2.0.5",
        "promise": "~6.1.0"
    },
    "engines": {
        "node": "8"
    }
}

https://learn.hubspot.com/composer
{
    "name": "totara/totaralms",
    "description": "Totara LMS is a fully supported Open Source learning platform specifically designed for the requirements of corporate, industry and vocational training.",
    "license": "GPL-3.0-or-later",
    "type": "project",
    "homepage": "https://totaralms.com",
    "require-dev": {
        "phpunit/phpunit": "7.5.*",
        "phpunit/dbunit": "4.0.*",
        "brianium/paratest": "^2.1",
        "behat/mink": "~1.7",
        "behat/mink-extension": "~2.2",
        "behat/mink-goutte-driver": "~1.2",
        "behat/mink-selenium2-driver": "~1.3",
        "symfony/process": "^3.4",
        "behat/behat": "3.3.*",
        "guzzlehttp/guzzle": "^6.3"
```
```
https://learn.hubspot.com/auth/README

```

```
└─# cat livesubs.txt | httpx -mc 200,301,302,404 | tee -a livestatus.txt


└─# cat livestatus.txt| httpx -title -status-code -tech-detect -follow-redirects


└─# cat livestatus.txt | httpx -sc -mc 200,301 -tech-detect

```


```


```