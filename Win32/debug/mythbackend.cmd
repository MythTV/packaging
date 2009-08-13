@Echo off
::
:: Script to run mythbackend through gdb (easily?)
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
:: Check for and Create if needed the .\gdbcommands-backend.txt 
::
:: syntax taken from [ http://www.mythtv.org/docs/mythtv-HOWTO-22.html#ss22.2 ]
::
if not exist ./gdbcommands-backend.txt (
    echo handle SIGPIPE nostop noprint           >  .\gdbcommands-backend.txt
    echo handle SIG33   nostop noprint           >> .\gdbcommands-backend.txt
    echo set logging on                          >> .\gdbcommands-backend.txt
    echo set pagination off                      >> .\gdbcommands-backend.txt
    echo set breakpoint pending on               >> .\gdbcommands-backend.txt
    echo break qFatal                            >> .\gdbcommands-backend.txt
    echo set args -l mythtv-backend.log -v all   >> .\gdbcommands-backend.txt
    echo run                                     >> .\gdbcommands-backend.txt
    echo thread apply all bt full                >> .\gdbcommands-backend.txt
    echo set logging off                         >> .\gdbcommands-backend.txt )
@Echo off

Echo COMMENTS: --------------------------------------
Echo COMMENTS: Clearing old gdb-backend.txt before running gdb again.
Echo COMMENTS: --------------------------------------
Echo. 
::
:: add current data/time to gdb.txt 
::
date /t > .\gdb-backend.txt
time /t >> .\gdb-backend.txt

:gdb
::
:: gdb should be in the path. 
::
Echo COMMENTS: --------------------------------------
Echo COMMENTS: If you need to add any switches to mythbackend edit gdbcommands-backend.txt
Echo COMMENTS: see: "mythbackend.exe --help" for options
Echo COMMENTS: --------------------------------------
Echo.
Echo COMMENTS: --------------------------------------
Echo COMMENTS: Starting: gdb
Echo COMMENTS: --------------------------------------
gdb .\mythbackend.exe -x .\gdbcommands-backend.txt

Echo.
Echo The backtrace can be found in .\gdb-backend.txt
Echo.
