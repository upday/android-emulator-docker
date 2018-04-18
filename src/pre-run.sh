#!/bin/bash

# wait for the device to come online
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

# disable animations
adb shell "settings put global transition_animation_scale 0"
adb shell "settings put global animator_duration_scale 0"
adb shell "settings put global window_animation_scale 0"

# save the snapshot
expect $HOME/src/save-snapshot.exp
