# Ontketen de Kracht van Intrusiedetectie

## Introductie
In dit artikel wordt er praktisch besproken hoe Snort als IDS kan toegepast worden in een netwerkomgeving. Snort is een open-source IDS die gebruik maakt van signature-based detection. Dit betekent dat Snort aan de hand van vooraf gedefinieerde regels (signatures) kan detecteren of er zich verdachte activiteiten voordoen in het netwerk. Snort is een van de meest gebruikte IDS'en en is zeer populair in zowel kleine als grote netwerkomgevingen.

## Installatie

### Installatie van de benodigde pakketten
Om Snort 3 te installeren op een Ubuntu 20.04 systeem, kan je de volgende stappen volgen.

```bash
sudo apt update && \
sudo apt upgrade -y

sudo apt install build-essential libpcap-dev libpcre3-dev \
libnet1-dev zlib1g-dev luajit hwloc libdnet-dev \
libdumbnet-dev bison flex liblzma-dev openssl \
libssl-dev pkg-config libhwloc-dev cmake cpputest \
libsqlite3-dev uuid-dev libcmocka-dev \
libnetfilter-queue-dev libmnl-dev autotools-dev \
libluajit-5.1-dev libunwind-dev libfl-dev git -y
```

### Voorbereiding

Ter voorbereiding zal er een nieuwe folder gemaakt worden waarin Snort geïnstalleerd zal worden. Dit kan gedaan worden door de volgende commando's uit te voeren.

```bash
mkdir ~/snort_src && cd ~/snort_src
```

### Installatie van Snort DAQ

Vooraleer Snort zelf geïnstalleerd kan worden, moet de Data Acquisition library (DAQ) geïnstalleerd worden. Dit kan gedaan worden door de volgende commando's uit te voeren.

```bash
git clone https://github.com/snort3/libdaq.git
cd libdaq
./bootstrap
./configure
make
sudo make install
```

### Installatie van gperftools

Snort maakt gebruik van gperftools om de performantie van de IDS te verbeteren. Om gperftools te installeren, kan je de volgende commando's uitvoeren.

```bash
cd ../
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
tar xzf gperftools-2.9.1.tar.gz
cd gperftools-2.9.1/
./configure
make
sudo make install
```

### Installatie van Snort

Nu Snort DAQ en gperftools geïnstalleerd zijn, kan Snort zelf geïnstalleerd worden. Dit kan gedaan worden door de volgende commando's uit te voeren.

```bash
cd ../
wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
unzip master.zip
cd snort3-master
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
```

Hierna moet Snort gecompileerd worden. Dit kan gedaan worden door de volgende commando's uit te voeren.

```bash
cd ./build
make
sudo make install
```

### Update Shared Libraries

Om ervoor te zorgen dat de shared libraries correct geïnstalleerd zijn, kan je de volgende commando's uitvoeren.

```bash
sudo ldconfig
```

### Installatie valideren

Om te controleren of Snort correct geïnstalleerd is, kan je de volgende commando's uitvoeren.

```bash
snort -V
```

## Snort regels configureren

### Test regels toevoegen aan een configuratiebestand

Om regels te kunnen toevoegen aan een configuratiebestand moeten er eerst regels aanwezig zijn. Om de Snort installatie te testen kan je volgende rules file toevoegen in de configuratie folder.

```bash
sudo vim /usr/local/etc/snort/test.rules

alert icmp (msg:"ICMP test"; sid:1000001;)
```

Wanneer deze rules file met bovenstaande regel is toegevoegd kan deze toegevoegd worden aan de configuratie file van Snort.

Om dit aan de configuratie toe te voegen moet **/usr/local/etc/snort/snort.lua** aangepast worden. Voeg volgende regel toe aan de **ips** sectie.

```bash
sudo vim /usr/local/etc/snort/snort.lua

include = 'test.rules',
```

Deze configuratie kan getest worden door volgend commando uit te voeren.

```bash
sudo snort -v -A full -i ens33 -c snort.lua
```

Verander de **ens33** naar de interface die je wilt monitoren.

Hierna kan je een alert uitlokken door gebruik te maken van het ping commando.

## Een netwerk monitoren met een mirror port

Wanneer de basis configuratie van Snort achter de rug is kan je beginnen met het monitoren van een netwerk. Dit kan gedaan worden door gebruik te maken van een mirror port. Een mirror port is een poort op een switch die alle data doorstuurt naar een andere poort. Op deze manier kan je al het verkeer op een netwerk monitoren.

Het instellen van een mirror port is afhankelijk van de switch die je gebruikt. Dit is dus out of scope voor dit artikel.

### Interface configureren

Om Snort te laten luisteren naar een mirror port moet deze port in promiscuous mode gezet worden. Dit kan gedaan worden door volgend commando uit te voeren. De interface kan ingesteld worden door middel van volgende commando's.

```bash
/usr/sbin/ip link set dev ens37 promisc on

/usr/sbin/ethtool -K ens37 gro off lro off
```

Verander de **ens37** naar de interface die je wilt monitoren.

### Netwerk monitoren

Nu de interface juist is ingesteld kan het netwerk gemonitord worden door volgend commando uit te voeren.

```bash
sudo snort -v -A full -i ens37 -c snort.lua
```

Verander de **ens37** naar de interface die je wilt monitoren.

## Implementeren Community Rules

```bash
sudo mkdir /usr/share/rules && cd /usr/share/rules

sudo wget https://www.snort.org/downloads/community/snort3-community-rules.tar.gz

sudo tar -xvzf snort3-community-rules.tar.gz

sudo rm snort3-community-rules.tar.gz
```

Wanneer de community rules gedownload zijn kan je deze toevoegen aan de configuratie file van Snort.

Om dit aan de configuratie toe te voegen moet **/usr/local/etc/snort/snort.lua** aangepast worden. Voeg volgende regel toe aan de **ips** sectie.

```bash
sudo vim /usr/local/etc/snort/snort.lua

include = '/usr/share/rules/snort3-community-rules/snort3-community.rules'
```

Nu kan de configuratie getest worden door volgend commando uit te voeren.

```bash
sudo snort -c /usr/local/etc/snort/snort.lua -T
```

## Tools

### Snort installation script

In deze repo is er een installatie script aanwezig die de installatie van Snort automatiseert. Dit script kan uitgevoerd worden door volgend commando uit te voeren.

```bash
chmod +x install_snort.sh

sudo bash install_snort.sh
```