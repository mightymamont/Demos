unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,StrUtils,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ImgList, Menus, jpeg, pngimage, xmldom, XMLIntf, msxmldom, XMLDoc;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    Load1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    xd: TXMLDocument;
    ListBox1: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    Timer1: TTimer;
    Clear1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Clear1Click(Sender: TObject);
  private
    { Private declarations }
    column1 : integer;

    picDlg : function(title, first, second, third, path: pstring):integer;stdcall;
    procedure defineLibraries();
  public
    { Public declarations }
    procedure DialogBox(title, first, second, third, path: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var dat : TStringList;
begin
  dat := TStringList.Create;
  dat.Text := ReplaceStr(ListBox1.Items[ListBox1.ItemIndex],#1,#13#10);
  DialogBox('Brief details',dat[2],dat[3],dat[4],dat[5]);
  dat.Free;
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  ListBox1.Items.Clear;
end;

procedure TForm1.defineLibraries;
type pstring = ^string;
var hLib : THandle;
begin
  @picDlg := nil;

  hLib := LoadLibrary('../outres/outres.dll');
  if hLib>=32 then
  begin
    @picDlg := GetProcAddress(hLib,'dialogBox');
  end;
end;

procedure TForm1.DialogBox(title, first, second, third, path: string);
begin
  if @picDlg <> nil then picDlg(@title, @first, @second, @third, @path) else ShowMessage('-Error pic.dlg');
  end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  defineLibraries;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
 TListBox(sender).Repaint
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var cv : TCanvas;
    focused, current : boolean; // ����� �� �������� / ������� ������
    brush_color, textc1, textc2 : TColor;
    pen : TPen;
    dat : TStringList;
begin
  pen := TPen.Create;
  dat := TStringList.Create;
  dat.Delimiter := #1;
  dat.DelimitedText := TListBox(Control).Items[Index];

  focused := TListBox(Control).Focused;
  current := TListBox(Control).ItemIndex = Index;
  cv := TListBox(Control).Canvas;
  {
    ���
    ���� ������������������ �������� - $cccccc
    ������� ���� ���� - $eeeeee
    ���� ���������� ������� - clHighlight

    �����
    ��� ������: 1 ������� - clGray, 2 - clLightGray
    �������: 1 ������� - clBlack, 2 - clGray
    ����������: 1 - clWhite, 2 - $cccccc

    ����� �� ���������� ��������
    ��� ������ - $666666 psDot
    ���� ����� - $333333 psDash

    ������� ���������:
    1. ���
    2. �����
    3. �����
  }

  brush_color := $cccccc;
  pen.Color   := $cccccc;
  pen.Style   := psClear;
  textc1      := clGray;
  textc2      := clWhite;

  if focused then
  begin
    brush_color := $eeeeee;
    pen.Color   := $eeeeee;
    textc1      := clBlack;
    textc2      := clGray;
  end;

  if current then
  begin
    brush_color := clHighlight;
    textc1      := clWhite;
    textc2      := $cccccc;
    // �����
    if focused then
    begin
      pen.Style := psDot;
      pen.Color := $333333;
    end
    else
    begin
      pen.Style := psDot;
      pen.Color := $dddddd;
    end;
  end;
  // ���������
  cv.Brush.Color := brush_color;
  cv.Pen := pen;
  // ���
  cv.FillRect(Rect);
  //�����
  cv.Rectangle(Rect.Left,Rect.Top,Rect.Right,Rect.Bottom);
  // �����
  cv.Font.Color := textc1;
  cv.TextOut(2,Rect.Top+1,dat[0]);
  cv.Font.Color := textc2;
  cv.TextOut(150,Rect.Top+1,dat[1]);

  pen.Free;
  dat.Free;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key = VK_RETURN) and Button1.Enabled then button1.Click;  
end;

procedure TForm1.ListBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 TListBox(sender).Repaint
end;

procedure TForm1.Load1Click(Sender: TObject);
var source : string;
    i : integer;
    node : IXMLNode;
begin
  // �������� �� �����
  ListBox1.Items.Clear;
  source := '../_data/test.xml';
  xd.FileName := source;
  xd.Active := true;
  column1 := 0;

  for i := 0 to xd.DocumentElement.ChildNodes.Count-1 do
  begin
    node := xd.DocumentElement.ChildNodes[i];
    Listbox1.Items.Add(
      node.Attributes['name']+#1+
      node.Attributes['position']+#1+
      node.Attributes['brief']+#1+
      node.Attributes['context']+#1+
      node.Attributes['subcontext']+#1+
      node.getnodevalue
    );
    if length(node.Attributes['name']) > column1 then column1 :=length(node.Attributes['name']);
  end;
  column1:=ListBox1.Canvas.TextWidth('W')*column1;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Button1.Enabled := ListBox1.ItemIndex>-1;
end;

end.
