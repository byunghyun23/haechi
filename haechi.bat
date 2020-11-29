@echo off
cd "%~dp0"
solc --ast-compact-json %1 > %1.ast
java -jar dist\haechi.jar %1