@echo off
setlocal
set "LUAROCKS_SYSCONFDIR=C:\Program Files\luarocks"
"C:\Users\Hp\AppData\Local\Programs\LuaJIT\bin\luarocks.exe" --project-tree C:\Users\Hp\Desktop\Coding\lua\lunar\lua_modules %*
exit /b %ERRORLEVEL%
