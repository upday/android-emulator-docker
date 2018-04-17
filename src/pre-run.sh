#!/bin/bash

# wait for the device to come online
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do echo $(getprop sys.boot_completed) && sleep 1; done'

# disable animations
adb shell "settings put global transition_animation_scale 0"
adb shell "settings put global animator_duration_scale 0"
adb shell "settings put global window_animation_scale 0"

# expect $HOME/src/save-snapshot.exp

adb emu kill
#kill -s SIGTERM $(cat $HOME/supervisord.pid)
