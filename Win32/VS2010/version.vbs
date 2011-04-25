' File to dynamically create version.h
' Robert Kulagowski 2011-03-21

' option explicit

Dim objFSO, objShell, strCommand, objExecuteObject, objStdOut
Dim strSourceVersion, strBranch, strTemp, strMythTVSource

' This needs to be set to the location of your MythTV source so that the 
' source version and branch in version.h reflect the MythTV path and not the
' git version of the packaging branch!

strMythTVSource = "c:\git\mythtv"

set objShell = CreateObject("WScript.shell")

set objCommand = objShell.Exec("cmd /C cd " & strMythTVSource & "& c:\" & chr(34) & "program files" & chr(34) & "\git\bin\git.exe describe --dirty")
set objStdOut = objCommand.stdout
strSourceVersion = objStdOut.readline

set objCommand = objShell.Exec("cmd /C cd " & strMythTVSource & "& c:\" & chr(34) & "program files" & chr(34) & "\git\bin\git.exe branch --no-color")
set objStdOut = objCommand.stdout

do until objStdOut.AtEndOfStream
  strTemp = objStdOut.readline
  if left(strTemp,1) = "*" then strBranch=mid(strTemp,3)  
loop

Set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.CreateTextFile("version.h",TRUE)

objFile.writeline("#ifndef MYTH_SOURCE_VERSION")
objFile.writeline("#define MYTH_SOURCE_VERSION " & chr(34) & strSourceVersion & chr(34) )
objFile.writeline("#define MYTH_SOURCE_PATH " & chr(34) & strBranch & chr(34) )
objFile.writeline("#endif")

objFile.close
