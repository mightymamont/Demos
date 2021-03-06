unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

const inifile = 'params.ini';

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function RunCaptured(const cmdline: string; var outx:string): Boolean;
var
  start: TStartupInfo;
  procInfo: TProcessInformation;
  tmpName: string;
  tmp: Windows.THandle;
  tmpSec: TSecurityAttributes;
  res: TStringList;
  return: Cardinal;
begin
  Result := False;
  try
    { ��������� ���� }
    tmpName := 'middle.tmp';
    FillChar(tmpSec, SizeOf(tmpSec), #0);
    tmpSec.nLength := SizeOf(tmpSec);
    tmpSec.bInheritHandle := True;
    tmp := Windows.CreateFile(PChar(tmpName),  Generic_Write, File_Share_Write, @tmpSec, Create_Always, File_Attribute_Normal, 0);
    try
      FillChar(start, SizeOf(start), #0);
      start.cb := SizeOf(start);
      start.hStdOutput := tmp;
      start.dwFlags := StartF_UseStdHandles or StartF_UseShowWindow;
      start.wShowWindow := SW_Minimize;

      { ��������� ��������� }
      if CreateProcess(nil, PChar(cmdline), nil, nil, True, 0, nil,nil, start, procInfo) then
      begin
        SetPriorityClass(procInfo.hProcess, Idle_Priority_Class);
        WaitForSingleObject(procInfo.hProcess, Infinite);
        GetExitCodeProcess(procInfo.hProcess, return);
        Result := (return = 0);
        CloseHandle(procInfo.hThread);
        CloseHandle(procInfo.hProcess);
        Windows.CloseHandle(tmp);
        { Add the output }
        res := TStringList.Create;
      try
        res.LoadFromFile(tmpName);
        outx := res.Text;
      finally
        res.Free;
      end;
        Windows.DeleteFile(PChar(tmpName));
      end
      else
      begin
        Application.MessageBox(PChar(SysErrorMessage(GetLastError())), 'RunCaptured Error', MB_OK);
      end;
    except
      CloseHandle(tmp);
      DeleteFile(PChar(tmpName));
      raise;
    end;
 finally
 end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var edit:TEdit;
    tag,i : integer;
    s : string;
begin
 tag := TButton(Sender).Tag;
 for I := 0 to ComponentCount-1 do
  if (components[i] is TEdit) and (TEdit(components[i]).Tag = tag) then edit := TEdit(components[i]);
  RunCaptured(edit.Text,s);
  Memo1.Text:=s;
end;

procedure TForm1.FormActivate(Sender: TObject);
var sl:TStringList;
    i : integer;
begin
  // ��������� ��������� �� ����� ������������
  if fileexists(inifile) then
  begin
    sl := TStringList.Create;
    sl.LoadFromFile(inifile);
    i:=0;
    while i<sl.Count do
    begin
      if(sl[i] = ';FILES') then
      begin
        edit1.Text := sl[i+1];
        edit2.Text := sl[i+2];
        i:=i+3;
      end;

      if sl[i] = ';MEMO' then
        repeat
          inc(i);
          if (i<sl.Count) and (sl[i][1] <>';') then Memo1.Lines.Add(sl[i]);
        until (sl[i][1] =';') or (i>=sl.Count);
      inc(i);
    end;
    sl.Free;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var sl:TStringList;
begin
  sl:=TStringList.Create;
  sl.Add(';FILES');
  sl.Add(edit1.Text);
  sl.Add(edit2.Text);

  sl.Add(';MEMO');
  sl.Add(Memo1.Text);

  sl.SaveToFile(inifile);
  sl.Free;
end;

end.
