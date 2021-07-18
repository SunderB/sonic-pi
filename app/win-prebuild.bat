cd %~dp0
call external/win_x64_build_externals.bat

cd %~dp0

if not exist "vcpkg\" (
    echo Download vcpkg from github
    git clone --single-branch --branch master https://github.com/microsoft/vcpkg vcpkg
)

if not exist "vcpkg\vcpkg.exe" (
    cd vcpkg
    echo Building vcpkg
    call bootstrap-vcpkg.bat -disableMetrics
    cd %~dp0
)

cd vcpkg
echo Installing Libraries
vcpkg install kissfft fmt crossguid sdl2 gl3w reproc gsl-lite concurrentqueue platform-folders catch2 --triplet x64-windows-static-md --recurse

cd %~dp0

@echo Cleaning out native dir....
REM del server\native\*.* /s /q
rmdir server\native\erlang /s /q
rmdir server\erlang\tau\priv /s /q
rmdir server\native\plugins /s /q

@echo Copying aubio to the server...
copy external\build\aubio-prefix\src\aubio-build\Release\aubio_onset.exe server\native\

@echo Copying all other native files to server...
xcopy /Y /I /R /E ..\prebuilt\windows\x64\*.* server\native

@echo Copying sp_midi dll to the erlang bin directory...
xcopy /Y /I /R /E external\build\sp_midi-prefix\src\sp_midi-build\Release\*.dll server\erlang\tau\priv\

@echo Translating tutorial...
server\native\ruby\bin\ruby server/ruby/bin/doctools/i18n-tool.rb -t

@echo Generating docs for the Qt GUI...
server\native\ruby\bin\ruby server/ruby/bin/doctools/create-html.rb
copy /Y gui\qt\utils\ruby_help.tmpl gui\qt\utils\ruby_help.h
server\native\ruby\bin\ruby server/ruby/bin/doctools/generate-qt-doc.rb -o gui/qt/utils/ruby_help.h

@echo Updating GUI translation files...
forfiles /p gui\qt\lang /s /m *.ts /c "cmd /c %QT_INSTALL_LOCATION%\bin\lrelease.exe @file"

@echo Compiling Erlang BEAM files...
cd %~dp0\server\erlang\tau
%~dp0\server\native\erlang\bin\erl.exe -make
cd %~dp0\server\erlang\tau
copy /Y src\tau.app.src .\ebin\tau.app
cd %~dp0
