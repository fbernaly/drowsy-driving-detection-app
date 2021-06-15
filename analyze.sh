#!/bin/bash
# analyze.sh
#

flutter format --set-exit-if-changed .
flutter analyze .
