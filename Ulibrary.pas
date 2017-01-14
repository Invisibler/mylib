unit Ulibrary;

interface
Uses ActiveX,Windows,Vcl.Forms;
type
 TKnownFolderID = TGUID;
 rec=record
       b:boolean;
       n,m:integer;
       a1,a2:array of string;
     end;
function GetKnownFolderPath(const ID: TKnownFolderID): WideString;
Procedure CloseProgram;
const
 FOLDERID_Userdocuments: TKnownFolderID = '{FDD39AD0-238F-46AF-ADB4-6C85480369C7}';

implementation

Procedure ProgOnTop;
begin
//
SetWindowPos(Handle,
HWND_TOPMOST,
Left,
Top,
Width,
Height,
SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;


Procedure CloseProgram;
begin
Application.MainForm.Close;
end;

function GetKnownFolderPath(const ID: TKnownFolderID): WideString;
type
 TSHGetKnownFolderPath = function(const rfid: TKnownFolderID; dwFlags: DWord;
   hToken: THandle; var ppSzPath: LPWSTR) : HResult; stdCall;
var
 hShell: HModule;
 SHGetKnownFolderPath: TSHGetKnownFolderPath;
 Buffer: LPWSTR;
begin
 Result := '';
 hShell := LoadLibrary('shell32.dll');
 if hShell > 0 then
   try
     @SHGetKnownFolderPath := GetProcAddress(hShell, 'SHGetKnownFolderPath');
     if Assigned(SHGetKnownFolderPath) then
       if Succeeded(SHGetKnownFolderPath(ID, 0, 0, Buffer)) then
         try
           Result := Buffer;
         finally
           CoTaskMemFree(Buffer);
         end;
   finally
     FreeLibrary(hShell);
   end;
end;
end.
