unit Unit_PW;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
   Vcl.ComCtrls, Math, Unit_LP,ClipBrd, IniFiles, SelShape;

const
  PX_Max = 2600;
  PY_Max = 3050;
//  PX_Max = 600;
//  PY_Max = 1300;

type
  TData = array[-50..PY_Max,-50..PX_Max] of double;
  TIData = array[-50..PY_Max,-50..PX_Max] of WORD;

  TForm_PW = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Label9: TLabel;
    Edit_PMin: TEdit;
    Edit_PMax: TEdit;
    CB_Mag: TComboBox;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    BB_ReDraw: TBitBtn;
    Edit_Left: TEdit;
    Edit_Top: TEdit;
    Edit_Right: TEdit;
    Edit_Bottom: TEdit;
    Shape1: TShape;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BB_ImgCopy: TBitBtn;
    Label_Size: TLabel;
    BB_Save: TBitBtn;
    SaveDialog1: TSaveDialog;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label5: TLabel;
    Edit_No: TEdit;
    UD_Tpro: TUpDown;
    SS: TSelShape;
    BC_Auto: TCheckBox;
    SB_Copy: TSpeedButton;
    Label6: TLabel;
    Bevel3: TBevel;
    Label8: TLabel;
    Label10: TLabel;
    BB_ST_BK: TBitBtn;
    CB_BK: TCheckBox;

    procedure BB_ReDrawClick(Sender: TObject);
    procedure Draw_Data(Sender: TObject);

    procedure Find_MinMax;

    procedure Load_Data(FN:string;Sender: Tobject);
    procedure Load_SglData(FN:string;Sender: Tobject);
    procedure Load_ImgData(FN:string;Sender: Tobject);
    procedure Load_WORDData(FN:string;Sender: Tobject);
    procedure Load_DWORDData(FN:string;Sender: Tobject);
    procedure Load_ByteData(FN:string;Header:byte;Sender: Tobject);
    procedure Load_TIFFData(FN:string;Sender: Tobject);
    procedure Load_STIFFData(FN:string;Sender: Tobject);
    procedure Load_Byte_TIFFData(FN: string; Sender: Tobject);
    procedure Save_Data(FN:string;Sender: Tobject);
    procedure Save_IntData(FN:string;Sender: Tobject);

    procedure Get_PMinMax;

    procedure Bin_Img(var Img:TData);
    procedure Normalize_Img(var Img:TData);

    procedure Add_Img(var Img1,Img2:TData);
    procedure Subst_Img(var Img1,Img2:TData);
    procedure Div_Img(var Img1,Img2:TData);
    procedure Ln_Img(var Img1:TData);
    procedure DivS_Img(var Img1:TData;f:double);

    procedure Gauss_Smooth_Img(var Img:TData);
    procedure Lap_Edge_Img(var Img:TData);
    procedure Th_img(var Img:TData;Th:double);
    procedure Median_Img(var Img:TData);
    procedure Median_Img2(var Img:TData);
    procedure Median_Hol_Img(var Img:TData);

    procedure SSMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure BB_ImgCopyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CB_MagChange(Sender: TObject);
    procedure BB_SaveClick(Sender: TObject);
    procedure Edit_LeftKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UD_TproClick(Sender: TObject; Button: TUDBtnType);
    procedure Edit_PMaxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_PMinKeyPress(Sender: TObject; var Key: Char);
    procedure Edit_PMaxKeyPress(Sender: TObject; var Key: Char);
    procedure SB_CopyClick(Sender: TObject);
    procedure BB_ST_BKClick(Sender: TObject);
  private
    { Private �錾 }
  public
    { Public �錾 }
    TmpData, PData, BKData : TData;
    //SData : array[0..5] of TData;
    IData : TIData;
    OW,OH,PW,PH, OFFX,OFFY,iimax,MaskV :longint;
    Mask : array[-5..5,-5..5] of longint;
    Drawing : boolean;

    LP1 : TForm_LP;
  end;

var
  Form_PW :TForm_PW;

implementation

{$R *.dfm}

uses main{, Unit_Imager};

procedure TForm_PW.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
  TmpKey : WORD;
  TmpShift: TShiftState;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
  try
    Top     := Ini.ReadInteger( 'Form_PW', 'Top', 100 );
    Left    := Ini.ReadInteger( 'Form_PW', 'Left', 100 );
    Width   := Ini.ReadInteger( 'Form_PW', 'Width', 750 );
    Height  := Ini.ReadInteger( 'Form_PW', 'Height', 500 );
    if Ini.ReadBool( 'Form_PW', 'InitMax', false ) then
      WindowState := wsMaximized
    else
      WindowState := wsNormal;

    Edit_PMin.Text := Ini.ReadString('Form_PW', 'PMin', '0' );
    Edit_PMax.Text := Ini.ReadString('Form_PW', 'PMax', '10000' );

    Edit_Left.Text := Ini.ReadString('Form_PW', 'ROI_Left', '100' );
    Edit_Top.Text := Ini.ReadString('Form_PW', 'ROI_Top', '100' );
    Edit_Right.Text := Ini.ReadString('Form_PW', 'ROI_Right', '300' );
    Edit_Bottom.Text := Ini.ReadString('Form_PW', 'ROI_Bottom', '300' );

    CB_Mag.ItemIndex := Ini.ReadInteger('Form_PW', 'Mag', 2 );

  finally
    Ini.Free;
  end;
  Edit_LeftKeyUp(Sender, TmpKey, TmpShift);
  LP1 := TForm_LP.Create(Self);
end;

procedure TForm_PW.FormDestroy(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
  try
    Ini.WriteInteger( 'Form_PW', 'Top', Top);
    Ini.WriteInteger( 'Form_PW', 'Left', Left);
    Ini.WriteInteger( 'Form_PW', 'Width', Width );
    Ini.WriteInteger( 'Form_PW', 'Height', Height );

    Ini.WriteBool( 'Form_PW', 'InitMax', WindowState = wsMaximized );

    Ini.WriteString('Form_PW', 'PMin', Edit_PMin.Text );
    Ini.WriteString('Form_PW', 'PMax', Edit_PMax.Text );

    Ini.WriteString('Form_PW', 'ROI_Left', Edit_Left.Text);
    Ini.WriteString('Form_PW', 'ROI_Top',  Edit_Top.Text );
    Ini.WriteString('Form_PW', 'ROI_Right', Edit_Right.Text);
    Ini.WriteString('Form_PW', 'ROI_Bottom',Edit_Bottom.Text);
    Ini.WriteInteger('Form_PW', 'Mag', CB_Mag.ItemIndex);
  finally
    Ini.Free;
  end;
end;

procedure TForm_PW.BB_ImgCopyClick(Sender: TObject);
var
  lMag :longint;
  bm: TBitmap;
begin
  if ((PW>0) and (PH>0)) then
  begin
    case CB_Mag.ItemIndex of
      0: lMag := 10;
      1: lMag := 25;
      2: lMag := 50;
      3: lMag := 100;
    end;

    bm := TBitmap.Create;
    try
      bm.SetSize((PW*lMag) div 100,(PH*lMag) div 100);
      BitBlt(bm.Canvas.Handle, 0, 0, (PW*lMag) div 100, (PH*lMag) div 100, Image1.Canvas.Handle, 0, 0, SRCCOPY);
      Clipboard.Assign(bm);
    finally
      bm.Free;
    end;
  end;
end;

procedure TForm_PW.BB_ReDrawClick(Sender: TObject);
begin
  Draw_Data(Sender);
end;

procedure TForm_PW.SB_CopyClick(Sender: TObject);
begin
  Clipboard.AsText := Edit_Left.Text+','+Edit_Top.Text+','+Edit_Right.Text+','+Edit_Bottom.Text;
//  Form_Imager.Edit_ROI_X1.Text := Edit_Left.Text;
//  Form_Imager.Edit_ROI_Y1.Text := Edit_Top.Text;
//  Form_Imager.Edit_ROI_X2.Text := Edit_Right.Text;
//  Form_Imager.Edit_ROI_Y2.Text := Edit_Bottom.Text;
end;

procedure TForm_PW.BB_SaveClick(Sender: TObject);
var
  lMag :longint;
  bm: TBitmap;
begin
  if ((PW>0) and (PH>0)) then
    if SaveDialog1.Execute then
    begin
      case SaveDialog1.FilterIndex of
        3:begin
          case CB_Mag.ItemIndex of
            0: lMag := 10;
            1: lMag := 25;
            2: lMag := 50;
            3: lMag := 100;
          end;

          bm := TBitmap.Create;
          try
            bm.SetSize((PW*lMag) div 100,(PH*lMag) div 100);
            BitBlt(bm.Canvas.Handle, 0, 0, (PW*lMag) div 100, (PH*lMag) div 100, Image1.Canvas.Handle, 0, 0, SRCCOPY);
            bm.SaveToFile(SaveDialog1.FileName+'.bmp');
          finally
            bm.Free;
          end;
        end;
        2: Save_Data(SaveDialog1.FileName,Sender);
        1: Save_IntData(SaveDialog1.FileName,Sender);
      end;
    end;
end;


procedure TForm_PW.CB_MagChange(Sender: TObject);
begin
  Draw_Data(Sender);
end;

procedure TForm_PW.UD_TproClick(Sender: TObject; Button: TUDBtnType);
var
  lComp : TComponent;
  lStr : string;
begin
  lComp := Form_Main.FindComponent('Edit_FN');
  if lComp <> nil  then
  begin
    lStr := TEdit(lComp).Text;
    Load_WORDData(lStr,Sender);
    Draw_Data(Sender);
  end;
end;

procedure TForm_PW.Get_PMinMax;
var
  i,j:longint;
  PMin, Pmax : double;
begin
  PMin := 1e10;
  PMax := -1e10;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
    begin
      if PMin>PData[j,i] then
        PMin := PData[j,i];
      if PMax<PData[j,i] then
        PMax := PData[j,i];
    end;
  Edit_PMin.Text := PMin.ToString;
  Edit_PMax.Text := PMax.ToString;
end;

procedure TForm_PW.Find_MinMax;
var
  i,j:longint;
  lMin,lMax : double;
begin
  lMin := +1e10;
  lMax := -1e10;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
    begin
      if lMin>PData[j,i] then
        lMin := PData[j,i];
      if lMax<PData[j,i] then
        lMax := PData[j,i];
    end;

  if (Round(lMin*100) mod 100=0) then
    Edit_PMin.Text := Format('%.0f',[lMin])
  else
    Edit_PMin.Text := Format('%8.2f',[lMin]);

  if (Round(lMax*100) mod 100=0) then
    Edit_PMax.Text := Format('%.0f',[lMax])
  else
    Edit_PMax.Text := Format('%8.2f',[lMax]);
end;


procedure TForm_PW.Draw_Data(Sender: TObject);
var
  i,j,TmpInt:longint;
  P:PByteArray;
  Bitmap : TBitMap;
  PMin, Pmax : double;
  lMag:longint;
begin
  BitMap := TBitMap.Create;
  BitMap.Height := Image1.Height;
  BitMap.Width := Image1.Width;
  BitMap.PixelFormat := pf24bit;
  BitMap.Canvas.Pen.Color := clWhite;

  if BC_Auto.Checked then
    Find_MinMax;

  PMin := StrToFloat(Edit_PMin.Text);
  PMax := StrToFloat(Edit_PMax.Text);
  case CB_Mag.ItemIndex of
    0: lMag := 10;
    1: lMag := 25;
    2: lMag := 50;
    3: lMag := 100;
  end;

  if CB_BK.Checked then
  begin
    for j:=0 to PH-1 do
      for i:=0 to PW-1 do
        if BKData[j,i] <>0  then
          TmpData[j,i] := PData[j,i]/BKData[j,i];
  end
  else
    TmpData := PData;

  for j:=0 to BitMap.Height-1 do
  begin
    P := BitMap.ScanLine[j];
    for i:=0 to BitMap.Width-1 do
    begin
      if (Round(i*100/lMag)<PW) and (Round(j*100/lMag)<PH) and ((PMax-PMin)<>0)then
        TmpInt := Round((TmpData[Round(j*100/lMag),Round(i*100/lMag)]-PMin)/(PMax-PMin)*255)
      else
        TmpInt := 50;
      if TmpInt>255 then TmpInt := 255;
      if TmpInt<0 then TmpInt := 0;
      p[i*3] := TmpInt;
      p[i*3+1] := TmpInt;
      p[i*3+2] := TmpInt;
    end;
  end;
  Image1.Picture.Graphic := BitMap;
  Image1.Refresh;
  BitMap.Free;
end;

procedure TForm_PW.Edit_LeftKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  lMag:longint;
begin
  lMag := 10;
  case CB_Mag.ItemIndex of
    0:lMag := 10;
    1:lMag := 4;
    2:lMag := 2;
    3:lMag := 1;
  end;

  SS.Left := StrToInt(Edit_Left.Text) div lMag;
  SS.Top := StrToInt(Edit_Top.Text) div lMag;
  SS.Width := (StrToInt(Edit_Right.Text) -StrToInt(Edit_Left.Text)) div lMag;
  SS.Height := (StrToInt(Edit_Bottom.Text) -StrToInt(Edit_Top.Text)) div lMag;
  Label_Size.Caption := IntToStr(SS.Width*lMag+1)+'*'+IntToStr(SS.Height*lMag+1);
end;

procedure TForm_PW.Edit_PMaxKeyPress(Sender: TObject; var Key: Char);
begin
  if (Pos(Key,'-0123456789.')=0) and (Ord(Key) <> VK_BACK) then
    Key := #0;
end;

procedure TForm_PW.Edit_PMaxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Edit_PMin.Text = '-' then Edit_PMin.Text := '-0';
  if Edit_PMax.Text = '-' then Edit_PMax.Text := '-0';
  Draw_Data(Sender);
end;

procedure TForm_PW.Edit_PMinKeyPress(Sender: TObject; var Key: Char);
begin
  if (Pos(Key,'-0123456789.')=0) and (Ord(Key) <> VK_BACK) then
    Key := #0;
end;

procedure TForm_PW.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  lMag : longint;
  i:longint;
begin
  lMag :=10;
  case CB_Mag.ItemIndex of
    0:lMag := 10;
    1:lMag := 4;
    2:lMag := 2;
    3:lMag := 1;
  end;

  if not( (ssCtrl in shift)  or (ssShift in Shift)) then
  begin
    if (X>=0) and (Y>=0) and (X*lMag<PW) and (Y*lMag<PH) then
    begin
      LP1.Series1.Clear;
      LP1.Show;

      if Button=mbLeft then
        for i:=0 to PW-1 do
          LP1.Series1.AddY(PData[Round(Y*lMag),i],'')
      else
        for i:=0 to PH-1 do
          LP1.Series1.AddY(PData[i,Round(X*lMag)],'');
    end;
  end;
end;

procedure TForm_PW.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  lMag : longint;
begin
  lMag :=1;
  case CB_Mag.ItemIndex of
    0:lMag := 10;
    1:lMag := 4;
    2:lMag := 2;
    3:lMag := 1;
  end;

  Label4.Caption := IntToStr(X*lMag);
  Label6.Caption := IntToStr(Y*lMag);
  if (X>0) and (Y>0) and (X*lMag<PX_Max) and (Y*lMag<PY_Max) then
    Label2.Caption := Format('%12.2f',[PData[Y*lMag,X*lMag]])
  else
    Label2.Caption := 'Out of Range';
end;

procedure TForm_PW.SSMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  lMag:longint;
begin
  lMag := 10;
  case CB_Mag.ItemIndex of
    0:lMag := 10;
    1:lMag := 4;
    2:lMag := 2;
    3:lMag := 1;
  end;
  Edit_Left.Text := IntToStr(SS.Left*lMag);
  Edit_Top.Text := IntToStr(SS.Top*lMag);
  Edit_Right.Text := IntToStr((SS.Left+SS.Width)*lMag);
  Edit_Bottom.Text := IntToStr((SS.Top+SS.Height)*lMag);
  Label_Size.Caption := IntToStr(SS.Width*lMag+1)+'*'+IntToStr(SS.Height*lMag+1);
end;





procedure TForm_PW.Add_Img(var Img1, Img2: TData);
var
  j,i:longint;
begin
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      Img1[j,i] := Img1[j,i]+Img2[j,i];
end;

procedure TForm_PW.Subst_Img(var Img1, Img2: TData);
var
  j,i:longint;
begin
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      Img1[j,i] := Img1[j,i]-Img2[j,i];
end;

procedure TForm_PW.Th_img(var Img: TData; Th: double);
var
  j,i:longint;
begin
  for j:=0 to PH div 2-1 do
    for i:=0 to PW div 2-1 do
      if Img[j,i]>th then
        Img[j,i] :=1
      else
        Img[j,i] :=0;
end;

procedure TForm_PW.DivS_Img(var Img1: TData;f:double);
var
  j,i:longint;
begin
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      Img1[j,i] := Img1[j,i]/f;
end;

procedure TForm_PW.Div_Img(var Img1, Img2: TData);
var
  j,i:longint;
begin
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      if Img2[j,i]<>0 then
        Img1[j,i] := Img1[j,i]/Img2[j,i]
      else
        Img1[j,i] := 0;
end;

procedure TForm_PW.Bin_Img(var Img: TData);
var
  j,i,jj,ii:longint;
  TmpDbl : double;
begin
  for j:=0 to PH div 2-1 do
    for i:=0 to PW div 2-1 do
    begin
      TmpDbl := 0;
      for jj:=0 to 1 do
        for ii:=0 to 1 do
          TmpDbl := TmpDbl+Img[j*2+jj,i*2+ii];
      TmpData[j,i] := TmpDbl/4;
    end;
  PW := PW div 2;
  PH := PH div 2;
  Img := TmpData;
end;

procedure TForm_PW.Gauss_Smooth_Img(var Img:TData);
var
  i,j,ii,jj:longint;
  TmpDbl : double;
begin
  iimax := 2;
  Mask[-2,-2] := 0;
  Mask[2,-2] := 0;
  Mask[-2,2] := 0;
  Mask[2,2] := 0;

  Mask[-2,-1] := -14;
  Mask[-2,1] := -14;
  Mask[-1,-2] := -14;
  Mask[-1,2] := -14;
  Mask[1,-2] := -14;
  Mask[1,2] := -14;
  Mask[2,-1] := -14;
  Mask[2,1] := -14;

  Mask[-2,0] := 3;
  Mask[0,-2] := 3;
  Mask[0,2] := 3;
  Mask[2,0] := 3;

  Mask[-1,-1] := 37;
  Mask[-1,1] := 37;
  Mask[1,-1] := 37;
  Mask[1,1] := 37;

  Mask[-1,0] := 54;
  Mask[0,-1] := 54;
  Mask[0,1] := 54;
  Mask[1,1] := 54;

  Mask[0,0] := 71;
  MaskV:=0;
  for jj:=-iimax to iimax do
    for ii:=-iimax to iimax do
      MaskV := MaskV+Mask[jj,ii];

  for j:=iimax to PH-iimax do
    for i:=iimax to PW-iimax do
    begin
      TmpDbl := 0;
      for jj:=-iimax to iimax do
        for ii:=-iimax to iimax do
          TmpDbl := TmpDbl + Mask[jj,ii]*Img[j+jj,i+ii];
      TmpData[j,i] := TmpDbl/MaskV;
    end;
  for j:=iimax to PH-iimax do
    for i:=iimax to PW-iimax do
      Img[j,i] := TmpData[j,i];
end;

procedure TForm_PW.Lap_Edge_Img(var Img: TData);
var
  i,j,ii,jj:longint;
  TmpDbl : double;
begin
  iimax := 1;


  Mask[-1,-1] := 0;
  Mask[-1,1] := 0;
  Mask[1,-1] := 0;
  Mask[1,1] := 0;

  Mask[-1,0] := 1;
  Mask[0,-1] := 1;
  Mask[0,1] := 1;
  Mask[1,0] := 1;

  Mask[0,0] := -4;

  {Mask[-2,-2] := 0;
  Mask[2,-2] := 0;
  Mask[-2,2] := 0;
  Mask[2,2] := 0;

  Mask[-2,-1] := 37;
  Mask[-2,1] := 37;
  Mask[-1,-2] := 37;
  Mask[-1,2] := 37;
  Mask[1,-2] := 37;
  Mask[1,2] := 37;
  Mask[2,-1] := 37;
  Mask[2,1] := 37;

  Mask[-2,0] := 16;
  Mask[0,-2] := 16;
  Mask[0,2] := 16;
  Mask[2,0] := 16;

  Mask[-1,-1] := -26;
  Mask[-1,1] := -26;
  Mask[1,-1] := -26;
  Mask[1,1] := -26;

  Mask[-1,0] := -47;
  Mask[0,-1] := -47;
  Mask[0,1] := -47;
  Mask[1,0] := -47;

  Mask[0,0] := -68;  }

  {Mask[-2,-2] := 4;
  Mask[2,-2] := 4;
  Mask[-2,2] := 4;
  Mask[2,2] := 4;

  Mask[-2,-1] := 1;
  Mask[-2,1] := 1;
  Mask[-1,-2] := 1;
  Mask[-1,2] := 1;
  Mask[1,-2] := 1;
  Mask[1,2] := 1;
  Mask[2,-1] := 1;
  Mask[2,1] := 1;

  Mask[-2,0] := 0;
  Mask[0,-2] := 0;
  Mask[0,2] := 0;
  Mask[2,0] := 0;

  Mask[-1,-1] := -2;
  Mask[-1,1] := -2;
  Mask[1,-1] := -2;
  Mask[1,1] := -2;

  Mask[-1,0] := -3;
  Mask[0,-1] := -3;
  Mask[0,1] := -3;
  Mask[1,1] := -3;

  Mask[0,0] := -4; }

  {MaskV:=0;
  for jj:=-iimax to iimax do
    for ii:=-iimax to iimax do
      MaskV := MaskV+Mask[jj,ii];}

  for j:=iimax to PH-1-iimax do
    for i:=iimax to PW-1-iimax do
    begin
      TmpDbl := 0;
      for jj:=-iimax to iimax do
        for ii:=-iimax to iimax do
          TmpDbl := TmpDbl + Mask[jj,ii]*Img[j+jj,i+ii];
      TmpData[j,i] := TmpDbl;//MaskV;
    end;
  Img := TmpData;
end;

procedure TForm_PW.Ln_Img(var Img1: TData);
var
  j,i:longint;
begin
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      if Img1[j,i]>0 then
        Img1[j,i] := -Ln(Img1[j,i])
      else
        Img1[j,i] := 0;
end;

procedure TForm_PW.Load_Data(FN:string;Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of double;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := OFFY*OW*8;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW*8);
    for i:=0 to PW-1 do
    begin
      PData[j,i] := lData[i+OFFX];
    end;
  end;
  FS.Free;
end;

procedure TForm_PW.Load_ImgData(FN: string; Sender: Tobject);
var
  i,j:longint;
  P:PByteArray;
begin
  Image1.Picture.LoadFromFile(FN);
  PW := Image1.Picture.Width;
  PH := Image1.Picture.Height;
  for j:=0 to PH-1 do
  begin
    P := Image1.Picture.Bitmap.ScanLine[j];
    for i:=0 to PW-1 do
      PData[j,i] := (p[i*3]+p[i*3+1]+p[i*3+2])/3;
  end;

  OW := PW;
  OH := PH;
  OffX := 0;
  OffY := 0;
end;

procedure TForm_PW.Load_SglData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of single;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position :=OFFY*OW*4;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW*4);
    for i:=0 to PW-1 do
    begin
      if (lData[i]<10000) and (lData[i]>-10000) then
        PData[j,i] := lData[i+OFFX]
      else
        PData[j,i] := 0;
      //PData[j,i] := lData[i+OFFX];
    end;
  end;
  FS.Free;

end;

procedure TForm_PW.Load_ByteData(FN:string;Header:byte;Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of byte;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := OFFY*OW+Header;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW);
    for i:=0 to PW-1 do
    begin
      PData[j,i] := lData[i+OFFX];
    end;
  end;
  FS.Free;
end;

procedure TForm_PW.Load_Byte_TIFFData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of Byte;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := 2048;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW);
    for i:=0 to PW-1 do
    begin
      if lData[i+OFFX]<100000 then
        IData[j,i] := lData[i+OFFX]
      else
        IData[j,i] :=0;
    end;
  end;
  FS.Free;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      PData[j,i] := IData[j,i];
end;

procedure TForm_PW.Load_STIFFData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of WORD;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := 4096;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW*2);
    for i:=0 to PW-1 do
    begin
      if lData[i+OFFX]<100000 then
        IData[j,i] := lData[i+OFFX]
      else
        IData[j,i] :=0;
    end;
  end;
  FS.Free;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      PData[j,i] := IData[j,i];
end;

procedure TForm_PW.Load_TIFFData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of LongWORD;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := 4096;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW*4);
    for i:=0 to PW-1 do
    begin
      if lData[i+OFFX]<1000000 then
        IData[j,i] := lData[i+OFFX]
      else
        IData[j,i] :=0;
    end;
  end;
  FS.Free;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      PData[j,i] := IData[j,i];
end;

procedure TForm_PW.Load_WORDData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of WORD;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := OFFY*OW*2+Int64(OW*OH*2)*UD_Tpro.Position;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW*2);
    for i:=0 to PW-1 do
    begin
      IData[j,i] := lData[i+OFFX];
    end;
  end;
  FS.Free;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      PData[j,i] := IData[j,i];
end;

procedure TForm_PW.Load_DWORDData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of DWORD;
begin
  FS := TfileStream.Create(FN,fmOpenRead);
  FS.Position := OFFY*OW*4;
  for j:=0 to PH-1 do
  begin
    FS.ReadBuffer(lData,OW*4);
    for i:=0 to PW-1 do
    begin
      IData[j,i] := lData[i+OFFX];
    end;
  end;
  FS.Free;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      PData[j,i] := IData[j,i];
end;


procedure TForm_PW.Median_Hol_Img(var Img: TData);
var
  i,j,ii,jj:longint;
  SData : array[0..10] of double;

procedure QuickSort(iLo, iHi: longint);
var
  Lo, Hi: longint;
  Mid, T:double;
begin
  Lo := iLo;
  Hi := iHi;
  Mid := SData[(Lo + Hi) div 2];
  repeat
    while SData[Lo] < Mid do Inc(Lo);
    while SData[Hi] > Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      T := SData[Lo];
      SData[Lo] := SData[Hi];
      SData[Hi] := T;

      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort(iLo, Hi);
  if Lo < iHi then QuickSort(Lo, iHi);
end;

begin
  for j:=1 to PH-2 do
    for i:=1 to PW-2 do
    begin
//      for jj:=-1 to 1 do
//        for ii:=-1 to 1 do
//          SData[jj*3+ii+4] := NData[jj+j,ii+i];
      for jj:=0 to 0 do
        for ii:=0 to 2 do
          SData[jj*3+ii] := Img[jj+j,ii+i];
      QuickSort(Low(SData),High(SData));
      TmpData[j,i] := SData[1];
    end;
  Img := TmpData;
end;

procedure TForm_PW.Median_Img(var Img: TData);
var
  i,j,ii,jj:longint;
  SData : array[0..10] of double;

procedure QuickSort(iLo, iHi: longint);
var
  Lo, Hi: longint;
  Mid, T:double;
begin
  Lo := iLo;
  Hi := iHi;
  Mid := SData[(Lo + Hi) div 2];
  repeat
    while SData[Lo] < Mid do Inc(Lo);
    while SData[Hi] > Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      T := SData[Lo];
      SData[Lo] := SData[Hi];
      SData[Hi] := T;

      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort(iLo, Hi);
  if Lo < iHi then QuickSort(Lo, iHi);
end;

begin
  for j:=1 to PH-2 do
    for i:=1 to PW-2 do
    begin
//      for jj:=-1 to 1 do
//        for ii:=-1 to 1 do
//          SData[jj*3+ii+4] := NData[jj+j,ii+i];
      for jj:=0 to 2 do
        for ii:=0 to 2 do
          SData[jj*3+ii] := Img[jj+j,ii+i];
      QuickSort(Low(SData),High(SData));
      TmpData[j,i] := SData[4];
    end;
  Img := TmpData;
end;

procedure TForm_PW.Median_Img2(var Img: TData);
var
  i,j,ii,jj:longint;
  SData : array[0..10] of double;

procedure QuickSort(iLo, iHi: longint);
var
  Lo, Hi: longint;
  Mid, T:double;
begin
  Lo := iLo;
  Hi := iHi;
  Mid := SData[(Lo + Hi) div 2];
  repeat
    while SData[Lo] < Mid do Inc(Lo);
    while SData[Hi] > Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      T := SData[Lo];
      SData[Lo] := SData[Hi];
      SData[Hi] := T;

      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then QuickSort(iLo, Hi);
  if Lo < iHi then QuickSort(Lo, iHi);
end;

var
  Av:double;
begin
  for j:=1 to PH-2 do
    for i:=1 to PW-2 do
    begin
      Av := 0;
      for jj:=-1 to 1 do
        for ii:=-1 to 1 do
        begin
          SData[(jj+1)*3+ii+1] := Img[jj+j,ii+i];
          Av := Av+Img[jj+j,ii+i];
        end;

      if (Av/9*1.2<Img[j,i]) or (Av/9*0.8>Img[j,i]) then
      begin
        QuickSort(Low(SData),High(SData));
        TmpData[j,i] := SData[4];
      end
      else
        TmpData[j,i] := Img[j,i];
    end;
  Img := TmpData;
end;

procedure TForm_PW.Normalize_Img(var Img: TData);
var
  i,j:longint;
  lMin,lMax,Av,s:double;
begin
  lMin := 1e10;
  lMax :=-1e10;
  Av := 0;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
    begin
      if lMin>PData[j,i] then
        lMin := PData[j,i];
      if lMax<PData[j,i] then
        lMax := PData[j,i];
      Av := Av+PData[j,i];
    end;
  Av := Av/PH/PW;
  s := 0;
  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      s := s+Sqr(PData[j,i]-Av);

  s := Sqrt(s/PW/PH);

  for j:=0 to PH-1 do
    for i:=0 to PW-1 do
      PData[j,i] := (PData[j,i]-Av)/s;
end;

procedure TForm_PW.Save_Data(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of double;
begin
  FS := TfileStream.Create(FN,fmCreate);
  for j:=0 to PH-1 do
  begin
    for i:=0 to PW-1 do
      lData[i] := PData[j,i];
    FS.WriteBuffer(lData,PW*8);
  end;
  FS.Free;
end;

procedure TForm_PW.Save_IntData(FN: string; Sender: Tobject);
var
  i,j : longint;
  FS : TFileStream;
  lData : array[0..4100] of WORD;
begin
  FS := TfileStream.Create(FN,fmCreate);
  for j:=0 to PH-1 do
  begin
    for i:=0 to PW-1 do
      lData[i] := Round(PData[j,i]);
    FS.WriteBuffer(lData,PW*2);
  end;
  FS.Free;
end;

procedure TForm_PW.BB_ST_BKClick(Sender: TObject);
begin
  BKData := PData;
end;



end.
