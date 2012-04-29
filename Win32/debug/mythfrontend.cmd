@Echo off
::
:: Script to run mythfrontend through gdb (easily?)
:: There is likely a more efficient way of doing this, 
:: but we have to start somewhere.
::
Echo COMMENTS: --------------------------------------
Echo COMMENTS: This script is used for gathering backtraces using gdb
Echo COMMENTS: See: http://www.mythtv.org/docs/mythtv-HOWTO-22.html#ss22.2
Echo COMMENTS: See: http://www.mythtv.org/wiki/index.php/Windows_Port
Echo COMMENTS: --------------------------------------
Echo.
::
:gdbcommands
::
:: Check for and Create if needed the .\gdbcommands-frontend.txt 
::
:: syntax taken from [ http://www.mythtv.org/docs/mythtv-HOWTO-22.html#ss22.2 ]
::
if not exist ./gdbcommands-frontend.txt (
    echo handle SIGPIPE nostop noprint          >  .\gdbcommands-frontend.txt
    echo handle SIG33   nostop noprint          >> .\gdbcommands-frontend.txt
    echo set logging on                         >> .\gdbcommands-frontend.txt
    echo set pagination off                     >> .\gdbcommands-frontend.txt
    echo set breakpoint pending on              >> .\gdbcommands-frontend.txt
    echo set args -l mythtv-frontend.log -d -v all >> .\gdbcommands-frontend.txt
    echo run                                    >> .\gdbcommands-frontend.txt
    echo thread apply all bt full               >> .\gdbcommands-frontend.txt
    echo set logging off                        >> .\gdbcommands-frontend.txt )
@Echo off

Echo COMMENTS: --------------------------------------
Echo COMMENTS: Clearing old gdb.txt before running gdb again.
Echo COMMENTS: --------------------------------------
Echo. 
::
:: add current data/time to gdb.txt 
::
date /t > .\gdb.txt
time /t >> .\gdb.txt

:gdb
::
:: gdb should be in the path. 
::
Echo COMMENTS: --------------------------------------
Echo COMMENTS: If you need to add any switches to mythfrontend edit gdbcommands-frontend.txt
Echo COMMENTS: see: "mythfrontend.exe --help" for options
Echo COMMENTS: --------------------------------------
Echo.
Echo COMMENTS: --------------------------------------
Echo COMMENTS: Starting: gdb
Echo COMMENTS: --------------------------------------
gdb .\mythfrontend.exe -x .\gdbcommands-frontend.txt 
Echo.
Echo The backtrace can be found in .\gdb.txt
Echo.
