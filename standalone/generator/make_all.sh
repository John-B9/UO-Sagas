#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sh $SCRIPT_DIR/make_standalone.sh ../../IUIDWand.lua . true
cp ../../IUIDWand_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CARunDexer.lua . true
cp ../../CARunDexer_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CARunDexerUIGump.lua . true
cp ../../CARunDexerUIGump_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CLTayloring.lua . true
cp ../../CLTayloring_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CLSmithing.lua . true
cp ../../CLSmithing_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CLTinkering.lua . true
cp ../../CLTinkering_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CLCooking.lua . true
cp ../../CLCooking_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CLCarpentry.lua . true
cp ../../CLCarpentry_STANDALONE.lua ..
sh $SCRIPT_DIR/make_standalone.sh ../../CLBowcraftFletching.lua . true
cp ../../CLBowcraftFletching_STANDALONE.lua ..