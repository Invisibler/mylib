unit Ulib;

interface
Uses ActiveX,Windows,Vcl.Forms,Registry,Classes,SysUtils;
type
 TKnownFolderID = TGUID;
Function GetComputerName:string;
function GetSelfVersion:string;
function GetKnownFolderPath(const ID: TKnownFolderID): WideString;
Function keypressed:integer;
Procedure NowTimeIntoVars(var mh,mm,ms,mml:integer);
Procedure ProgOnTop(form1:Tform);
procedure MXY(x,y: word);
procedure ClickXY(x,y: word);
Procedure CloseProgram;
Function WhereCursor:TPoint;
const
 FOLDERID_Userdocuments: TKnownFolderID = '{FDD39AD0-238F-46AF-ADB4-6C85480369C7}';

implementation
Procedure NowTimeIntoVars(var mh,mm,ms,mml:integer);
begin
  Decodetime(now,mh,mm,ms,mml);
end;

function GetSelfVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte; // ненужные нам 48 байт
    Minor,Major,Build,Release: word; // а тут версия
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // достаём ресурс
    if s.Size>0 then begin
      s.Read(v,SizeOf(v)); // читаем нужные нам байты
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // вот и версия...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
  s.Free;
  except; end;
end;

Function GetComputerName:string;
var reg : TRegistry;
begin
  reg:=TRegistry.Create;
  reg.RootKey:=HKEY_LOCAL_MACHINE;
  reg.OpenKey('SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName', true);
  result:=reg.ReadString('ComputerName');
  reg.CloseKey;
  reg.Free;
end;

Procedure ProgOnTop(form1:Tform);
begin
with form1 do SetWindowPos(Handle,
HWND_TOPMOST,
Left,
Top,
Width,
Height,
SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

Function keypressed:integer;
begin
result:=GetKeyState(VK_SPACE);
end;

procedure MXY(x,y: word);
var x1,y1:word;
begin
x1 := Round(x * (65535 / Screen.Width));
y1 := Round(y * (65535 / Screen.Height));
Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, x1, y1, 0, 0);
end;

procedure ClickXY(x,y: word);
var x1,y1:word;
begin
x1:= Round(x * (65535 / Screen.Width));
y1:= Round(y * (65535 / Screen.Height));
Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, x1, y1, 0, 0);
Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, x1, y1, 0, 0);
Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, x1, y1, 0, 0);
end;

procedure tsvet(x,y:word;var pix:cardinal);
var  Dc : HDC;
begin
Dc:=GetDC(0);
Pix:=GetPixel(Dc, X, Y);
ReleaseDC(0, Dc);
end;

Function WhereCursor:TPoint;
Begin
GetCursorPos(Result);
End;

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
