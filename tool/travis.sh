#!/bin/sh

set -e

echo '> pub get ================================================================'
pub get

if [ -f "package.json" ]; then
    echo '> npm install ============================================================'
    npm install
fi

echo "> pub run test -r expanded ==============================================="
pub run test -r expanded

echo '> dartfmt -n --set-exit-if-changed . ====================================='
dartfmt -n --set-exit-if-changed lib/

echo "> dartanalyzer --fatal-infos --fatal-warnings . =========================="
dartanalyzer --fatal-infos --fatal-warnings .
