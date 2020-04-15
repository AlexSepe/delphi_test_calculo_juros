program SimulaFinanc;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FMain},
  UFormGenericoPgto in 'UFormGenericoPgto.pas' {FPgtoGenerico},
  Sistemas.Controller in 'Sistemas\Sistemas.Controller.pas',
  Sistemas.PagamentoUnico in 'Sistemas\Sistemas.PagamentoUnico.pas',
  Sistemas.Dados in 'Sistemas\Sistemas.Dados.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
