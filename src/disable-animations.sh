#!/bin/bash

adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'
adb shell "settings put global transition_animation_scale 0"
adb shell "settings put global animator_duration_scale 0"
adb shell "settings put global window_animation_scale 0"
