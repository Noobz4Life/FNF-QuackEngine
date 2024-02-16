@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime 8.0.1
haxelib install openfl 9.3.2
haxelib install flixel 5.5.0
haxelib install flixel-addons 3.2.1
haxelib install flixel-ui 2.5.0
haxelib install flixel-tools 1.5.1
haxelib install SScript 8.1.6
haxelib install tjson 1.4.0
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc
echo Finished!
pause
