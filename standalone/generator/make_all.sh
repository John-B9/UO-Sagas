#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sh $SCRIPT_DIR/make_standalone.sh ../../IUIDWand.lua . true
cp ../../IUIDWand_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CARunDexer.lua . true
cp ../../CARunDexer_STANDALONE.lua ..