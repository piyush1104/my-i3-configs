#!/usr/bin/sh

echo "This is a self-made script for changing gdm login background."
echo "This script can be found as ~/login-background.sh"
echo "give image as input for your favourite image."
echo "give blank space as an input for image to be same as that of lock-screen."
curr=$(pwd)
#to use this for any general image use following method.
#IMAGE=/usr/local/images/whatever.png sh login-background.sh
IMAGE=$1
temp=$1
IMAGE=$curr"/"$IMAGE
if [ "$1" == "" ]; then
  IMAGE=$(
    dbus-launch gsettings get org.gnome.desktop.screensaver picture-uri |
    sed -e "s/'//g" |
    sed -e "s/^file:\/\///g"
  )
fi
# echo "trying to find given $IMAGE"


if [ ! -f $IMAGE ]; then
  echo "no such $IMAGE"
  echo "trying using original address itself."
  IMAGE=$temp
  echo $IMAGE
fi

if [ ! -f $IMAGE ]; then
  echo "no image like this $IMAGE was found"
  exit 1
fi

echo ''
echo 'using the following image as login background:'
echo $IMAGE
echo ''

if [ -d ~/tmp ]; then
  CREATED_TMP="0"
else
  mkdir -p ~/tmp
  CREATED_TMP="1"
fi

WORKDIR=~/tmp/gdm-login-background
GST=/usr/share/gnome-shell/gnome-shell-theme.gresource
GSTRES=$(basename $GST)

mkdir -p $WORKDIR
cd $WORKDIR
mkdir theme

for r in `gresource list $GST`; do
  gresource extract $GST $r >$WORKDIR$(echo $r | sed -e 's/^\/org\/gnome\/shell\//\//g')
done

cd theme
cp "$IMAGE" ./

echo "
#lockDialogGroup {
  background: #2e3436 url(resource:///org/gnome/shell/theme/$(basename $IMAGE));
  background-size: cover;
  background-repeat: no-repeat;
  border:solid transparent 1px;
}" >>gnome-shell.css

echo '<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell/theme">' >"${GSTRES}.xml"
for r in `ls *.*`; do
  echo "    <file>$r</file>" >>"${GSTRES}.xml"
done
echo '  </gresource>
</gresources>' >>"${GSTRES}.xml"

glib-compile-resources "${GSTRES}.xml"

sudo mv "/usr/share/gnome-shell/$GSTRES" "/usr/share/gnome-shell/${GSTRES}.backup"
sudo mv "$GSTRES" /usr/share/gnome-shell/

rm -r $WORKDIR

if [ "$CREATED_TMP" = "1" ]; then
  rm -r ~/tmp
fi

#echo "Now please restart your gnome-shell by using Alt-F2 and then typing r in that."
killall -HUP gnome-shell
echo ''
echo "Modified by PURU"
