@echo off
call lua.bat ./lunar/index.lua %*
exit /b %ERRORLEVEL%
