@echo off
setlocal
IF "%*"=="" (set I=-i) ELSE (set I=)
set "LUAROCKS_SYSCONFDIR=C:\Program Files\luarocks"
"C:\Users\Hp\AppData\Local\Programs\LuaJIT\bin\luajit.exe" -e "package.path=\"C:\\Users\\Hp\\Desktop\\Coding\\lua\\lunar\\lua_modules\\share\\lua\\5.1\\?.lua;C:\\Users\\Hp\\Desktop\\Coding\\lua\\lunar\\lua_modules\\share\\lua\\5.1\\?\\init.lua;C:\\Users\\Hp\\AppData\\Roaming\\luarocks\\share\\lua\\5.1\\?.lua;C:\\Users\\Hp\\AppData\\Roaming\\luarocks\\share\\lua\\5.1\\?\\init.lua;\"..package.path;package.cpath=\"C:\\Users\\Hp\\Desktop\\Coding\\lua\\lunar\\lua_modules\\lib\\lua\\5.1\\?.dll;C:\\Users\\Hp\\AppData\\Roaming\\luarocks\\lib\\lua\\5.1\\?.dll;\"..package.cpath" %I% %*
exit /b %ERRORLEVEL%
