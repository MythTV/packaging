' Program to recursively copy dll files from the thirdparty directory into bin\debug
' Robert Kulagowski, 2011-03-22
' Cobbled together from examples on the web

option explicit

DIM strStartFolder, strDestinationFolder, strQtFolder, strMySQLFolder, strQtDLL, strMySQLDLL
DIM objFSO, objFolder, strFilenames, objSubFolder, objSubFile, colFolders, objFile

' The folder names.  Edit as required for your particular system.
strStartFolder = "thirdparty"
strDestinationFolder = ".\bin\debug\"
strQtFolder = "c:\Qt\4.8.0\bin\"
strMySQLFolder = "c:\Program Files\MySQL\MySQL Connector C 6.0.2\lib\debug\"

strQtDLL = strQtFolder & "\QtSQLd4.dll"
strMySQLDLL = strMySQLFolder & "\libmysql.dll"

Set objFSO = CreateObject("Scripting.FileSystemObject")

' Do the DLLs in thirdparty
Set objFolder = objFSO.GetFolder(strStartFolder)
ScanSubFolders(objFolder)

' Copy the individual DLLs that we also need.
' objFSO.CopyFile strQtDLL,(strDestinationFolder)
objFSO.CopyFile strMySQLDLL,(strDestinationFolder)


Sub ScanSubFolders(objFolder)
Set colFolders = objFolder.SubFolders
For Each objSubFolder In colFolders
  Set strFilenames = objSubFolder.Files
  For Each objFile in strFilenames
    If lcase(Right(objFile.Name,3)) = "dll" Then
      objFSO.CopyFile objFile,(strDestinationFolder)
    End If
  Next
  ScanSubFolders(objSubFolder)
Next
End Sub
