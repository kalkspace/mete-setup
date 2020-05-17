# Setup Dell Venue 8 Pro (3485) fuer mete

## Hardware Info

Das Dingen ist relativ kompliziert. Es hat einen 64 bit Prozessor, aber nur ein 32 Bit EFI. Was es relativ kompliziert macht
da irgendwas drauf zu installieren. Ausserdem hat es nur 1GB RAM

Ich habe probiert:

- Debian 32 Bit
- Ubuntu 64 Bit
- Arch Linux 64 Bit

Unter Debian 32 Bit kam es immer wieder zu black screens nach jedem Booten, weswegen ich einen neuen Kernel haben wollte.
Ubuntu hab ich einfach nicht hinbekommen. Ubuntu Desktop braucht viel zu viel Speicher, um ueberhaupt zu installieren.
Ubuntu Server bootete nach Installation nicht und ich hab das mit dem efi 32 nicht hinbekommen.

Mit Arch linux ging dann alles. Haette lieber was LTSiges gehabt, aber naja.

## Vorraussetzungen

Es wird unbedingt ein aktiver Hub benoetigt. Und den muss man irgendwie an das Geraet dranbringen.

Mein Setup:

- OTG Hub von einem Pi Zero:

https://www.amazon.com/MakerSpot-Accessories-Charging-Extension-Raspberry/dp/B01JL837X8/ref=sr_1_5?dchild=1&keywords=raspberry+pi+zero+usb+hub&qid=1589449967&sr=8-5

- 1 aktiver Hub

Es reicht NICHT den OTG Hub allein zu nutzen. Das Tablet powered nur maximal ein Geraet und es werden Tastatur und Stick gleichzeitig benoetigt. Bitte vor der Installation das Tablet voll laden.

## Installation von Arch Linux

Zuerst braucht man ein 64 Bit iso mit 32 Bit EFI.

https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface#Booting_64-bit_kernel_on_32-bit_UEFI

Das hier hat wunderbar funktioniert.

Dann normal Arch Linux installieren. Beim Wifi mit dem `wpa_supplicant` arbeiten. Ich habe iwd versucht, aber ich bekam immer "Operation failed" beim connecten. Beim Bootloader grub nehmen. Ich hatte mit reFIND und syslinux experimentiert, aber es ging schliesslich nur mit grub.

Grub wird dann auch normal installiert bis auf:

```
grub-install --target=i386-efi --efi-directory=esp --bootloader-id=GRUB # i386 wichtig. kein 64 bit
```

Fuer Netzwerkconfig habe ich systemd-networkd genutzt.

## Setup GDM

```
pacman -S gdm
useradd -m mete
systemctl enable gdm
```

Automatic Login wie im Arch Wiki beschrieben konfigurieren:

```
[daemon]
# Uncomment the line below to force the login screen to use Xorg
#WaylandEnable=false
AutomaticLogin=mete
AutomaticLoginEnable=True
```

## Setup GNOME

```
pacman -S gnome-shell gnome-tweaks gnome-control-center gnome-settings-daemon gdm termite iio-sensor-proxy
```

Per default koennen Nutzer:innen aus dem Fullscreen ausbrechen. Das hier fixt es:

disable-unfullscreen@kalk.space nach /home/mete/.local/share/gnome-shell/extensions/ kopieren.

Nach dem ersten Start muss dann via `gnome-tweaks` diese extension angeschaltet werden.

## Display Orientation fixen

Per default war das Device bei mir falsch rotiert.

Folgendes anlegen:

```
root@kalkspace-mete:/home/mop# cat /etc/udev/hwdb.d/60-venue.hwdb
sensor:modalias:acpi:INVN6500*:dmi:*svnDellInc.*:pnVenue8Pro3845*
 ACCEL_MOUNT_MATRIX=0, -1, 0; -1, 0, 0; 0, 0, 1
```

HWDB updaten:

```
systemd-hwdb update
```

Rebooten

## Disable suspend

Das Ding wacht sonst nicht auf. Kann natuerlich angegangen werden das richtig zu fixen, aber viel Strom frist es ja eh nicht.

```
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
systemctl restart systemd-logind.service
```

Ausserdem muss noch in den gnome settings rumgespielt werden.

## Firefox kiosk mode

copy `mete-kiosk.desktop` to `/home/mete/.local/share/applications/mete-kiosk.desktop`
copy `start-mete-kiosk.sh` to `/home/mete/start-mete-kiosk.sh`

Mit `gnome-tweaks` den kiosk mode als startup application hinzufuegen.

## Docker setup

Damit das hier klappt benoetigst du einen Account auf dem Tablet, der in der Gruppe `docker` ist (mete ist NICHT in der gruppe docker)

```
ssh -L 9000:/var/run/docker.sock 192.168.178.72
```

Dann lokal:

```
export DOCKER_HOST=tcp://localhost:9000
docker-compose up -d
```

## Probleme

- Backup :S
- reboot faehrt runter und rebootet nicht :S
- manchmal hat der firefox nen geilen blauen balken da wo die GNOME status zeile sein sollte
- die onscreen tastatur von gnome ist relativ klein (wurstfinger)
- scaling des displays macht leider die onscreen tastatur kaputt (skaliert nicht mit und ist abgeschnitten)

## TODO

- SSL im Space fixen (vorbereitung schon gemacht)
