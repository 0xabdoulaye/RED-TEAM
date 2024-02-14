Un réseau permet à deux ordinateurs de communiquer entre eux. Il existe un large éventail de topologies (maillage/arbre/étoile), de supports (Ethernet/fibre/coaxial/sans fil) et de protocoles (TCP/UDP/IPX) qui peuvent être utilisés pour faciliter le réseau. En tant que professionnels de la sécurité, il est important de comprendre le fonctionnement des réseaux, car lorsque le réseau tombe en panne, l'erreur peut être silencieuse, ce qui nous fait passer à côté de quelque chose.

La plupart des réseaux utilisent un sous-réseau /24, à tel point que de nombreux testeurs de pénétration définissent ce masque de sous-réseau (255.255.255.0) sans le vérifier. Le réseau /24 permet aux ordinateurs de communiquer entre eux tant que les trois premiers octets d'une adresse IP sont identiques (ex : 192.168.1.xxx). Le fait de régler le masque de sous-réseau sur /25 divise cette plage en deux, et l'ordinateur ne pourra communiquer qu'avec les ordinateurs de sa "moitié". Nous avons vu des rapports de tests de pénétration dans lesquels l'évaluateur affirmait qu'un contrôleur de domaine était hors ligne alors qu'il se trouvait en réalité sur un autre réseau. La structure du réseau était à peu près la suivante :

    Passerelle du serveur : 10.20.0.1/25
    Contrôleur de domaine : 10.20.0.10/25
    Passerelle client : 10.20.0.129/25
    Poste de travail client : 10.20.0.200/25
    IP du pentester : 10.20.0.252/24 (définir la passerelle sur 10.20.0.1)

## Types de Reseaux
Chaque réseau est structuré différemment et peut être configuré individuellement. C'est pourquoi des types et des topologies ont été mis au point pour classer ces réseaux.

## Terminologie
Type de réseau Définition
Réseau étendu (WAN) Internet
Réseau local (LAN) Réseaux internes (ex : domicile ou bureau)
Réseau local sans fil (WLAN) Réseaux internes accessibles par Wi-Fi
Réseau privé virtuel (VPN) Connecte plusieurs sites à un seul réseau local.

**WAN**
Le WAN (Wide Area Network) est communément appelé Internet. Lorsqu'il s'agit d'équipements de réseau, nous avons souvent une adresse WAN et une adresse LAN. L'adresse WAN est l'adresse à laquelle on accède généralement par l'internet. Cela dit, elle n'englobe pas l'internet ; un réseau étendu n'est qu'un grand nombre de réseaux locaux reliés entre eux. 

## LAN / WLAN
Les réseaux locaux (LAN) et les réseaux locaux sans fil (WLAN) attribuent généralement des adresses IP destinées à un usage local (RFC 1918, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16). Dans certains cas, comme dans certaines universités ou certains hôtels, une adresse IP routable (internet) peut vous être attribuée lorsque vous rejoignez leur réseau local, mais cela est beaucoup moins courant.

## Proxies
Les professionnels de la sécurité se tournent vers les proxy HTTP (BurpSuite) ou vers les proxy SOCKS/SSH (Chisel, ptunnel, sshuttle).
Les développeurs web utilisent des proxys comme Cloudflare ou ModSecurity pour bloquer le trafic malveillant.
Le commun des mortels peut penser qu'un proxy est utilisé pour masquer votre localisation et accéder au catalogue Netflix d'un autre pays.
Tous les exemples ci-dessus ne sont pas corrects. On parle de proxy lorsqu'un dispositif ou un service se place au milieu d'une connexion et joue le rôle de médiateur. Le médiateur est l'élément d'information essentiel, car il signifie que l'appareil situé au milieu doit être en mesure d'inspecter le contenu du trafic. Sans la capacité de jouer le rôle de médiateur, l'appareil est techniquement une passerelle et non un proxy.