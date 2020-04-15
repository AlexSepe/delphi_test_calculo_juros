unit UMain;

interface

uses
  Sistemas.Controller,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus;

type
  TFMain = class(TForm)
    MainMenuPrincipal: TMainMenu;
    MenuItemSimulacoes: TMenuItem;
    procedure FormCreate(Sender: TObject);
  private
    procedure BindaListaSistemas();
    procedure DoCriaNovoSistema(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

uses
  UFormGenericoPgto;

procedure TFMain.BindaListaSistemas();
var
  clazz: TSistemaServiceClazz;
  newItem: TMenuItem;
begin
  for clazz in TSistemaController.Instance.GetSistemas() do
  begin
    newItem:= MainMenuPrincipal.CreateMenuItem();
    with newItem do
    begin

      Caption:= clazz.GetNomeSistema();
      Tag:= Cardinal(clazz);
      OnClick:= DoCriaNovoSistema;
    end;
    MenuItemSimulacoes.Add(newItem);
  end;
end;

procedure TFMain.DoCriaNovoSistema(Sender: TObject);
var
  clazz: TSistemaServiceClazz;
begin
  clazz:= TSistemaServiceClazz(Cardinal(TMenuItem(Sender).Tag));
  TFPgtoGenerico.CriaFormFor(Self, clazz);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  BindaListaSistemas();
end;

end.
