' Program to recursively copy dll files from the thirdparty directory into bin\debug
' Robert Kulagowski, 2011-03-22
' Cobbled together from examples on the web

option explicit

Dim strStartFolder, strDestinationFolder, objFSO, objFolder, strFilenames, objSubFolder, objSubFile
Dim colFolders, objFile

strStartFolder = "thirdparty"
strDestinationFolder = ".\bin\debug\"

Set objFSO = CreateObject("Scripting.FileSystemObject")

Set objFolder = objFSO.GetFolder(strStartFolder)

ScanSubFolders(objFolder)

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
