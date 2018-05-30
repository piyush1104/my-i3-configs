#!/bin/bash
EXTERNAL_OUTPUT="output:hdmi-stereo"
INTERNAL_OUTPUT="output:analog-stereo"

# if we don't have a file, start at zero
if [ ! -f "/tmp/audio_mode.dat" ] ; then
  audio_mode="INTERNAL"

# otherwise read the value from the file
else
  audio_mode=`cat /tmp/audio_mode.dat`
fi

#if [ $monitor_mode = "all" ]; then
#        monitor_mode="EXTERNAL"
#        xrandr --output $INTERNAL_OUTPUT --off --output $EXTERNAL_OUTPUT --auto
if [ $audio_mode = "EXTERNAL" ]; then
        audio_mode="INTERNAL"
        pactl set-card-profile 0 $INTERNAL_OUTPUT 
else
        audio_mode="EXTERNAL"
        pactl set-card-profile 0  $EXTERNAL_OUTPUT  
fi
echo "${audio_mode}" > /tmp/audio_mode.dat
