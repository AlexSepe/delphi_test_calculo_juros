unit UFormGenericoPgto;

interface

uses
  Sistemas.Controller,
  Sistemas.Dados,
  Sistemas.PagamentoUnico,//pgto unico
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls;

type
  TFPgtoGenericoClazz = class of TFPgtoGenerico;
  TFPgtoGenerico = class(TForm)
    PTop: TPanel;
    lvDetalles: TListView;
    edCapital: TLabeledEdit;
    edPeriodos: TLabeledEdit;
    edTaxaJuros: TLabeledEdit;
    btnSimular: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSimularClick(Sender: TObject);
  private
    class constructor Create();
  protected
    FSistemaClazz: TSistemaServiceClazz;
    FSistema: TSistemaService;

    procedure DoInicializaForm();
    procedure DoInitViewControls();
    procedure DoExibeDadosCotas(ACotas: TListaCotas);

    procedure simularFinanciamento();

    destructor Destroy(); override;
  public
    class function CriaFormFor(AMainForm: TForm; ASistemaClazz: TSistemaServiceClazz): TFPgtoGenerico;
  end;

  //todo criar View Controler Generico <T: class>

  TSistemaCotaHelper = class helper for TSistemaCota
  public
    function ToString(): String;
    //conversores de moeda -> string
    function JurosToString(): String;
    function AmortizacaoToString(): String;
    function PagamentoToString(): String;
    function SaldoDevedorToString(): String;
  end;

var
  FPgtoGenerico: TFPgtoGenerico;

implementation

{$R *.dfm}


class constructor TFPgtoGenerico.Create;
var
  clazz: TSistemaServiceClazz;
begin
  //todo Registrar outros serviços
  //podemos ter um form especializado para cada tipo de serviço
  // para simplificar iremos utilizar somente 1 View para todos os tipos?

  TSistemaController.Instance.RegistraFormFor( TSistemaPgtoUnicoService, TFPgtoGenerico);
end;

class function TFPgtoGenerico.CriaFormFor(AMainForm: TForm;
  ASistemaClazz: TSistemaServiceClazz): TFPgtoGenerico;
begin
  Result:= TFPgtoGenerico.Create(AMainForm);
  with Result do
  begin
    FSistemaClazz:= ASistemaClazz;
    DoInicializaForm();
  end;
end;

destructor TFPgtoGenerico.Destroy;
begin
  FSistema.Free();
  inherited Destroy();
end;

procedure TFPgtoGenerico.DoInicializaForm();
begin
  Caption:= FSistemaClazz.GetNomeSistema();
  FSistema:= FSistemaClazz.LazyLoadIt();

  //todo chamar metodo abstrado? caso precisar especalizar o generico
  //criar controlado generico etc

  DoInitViewControls();

  Show();
end;

procedure TFPgtoGenerico.DoInitViewControls;
begin
  //iniciar e limpar outros campos
  //bindar info do tipo de financiamento
  lvDetalles.Clear();
end;

procedure TFPgtoGenerico.DoExibeDadosCotas(ACotas: TListaCotas);

  procedure AddItemLista(ACaption: String; AitemConta: TSistemaCota);
  begin
    //add item
    with lvDetalles.Items.Add() do
    begin
      Caption := ACaption;
      SubItems.Add( AitemConta.JurosToString() );
      SubItems.Add( AitemConta.AmortizacaoToString() );
      SubItems.Add( AitemConta.PagamentoToString() );
      SubItems.Add( AitemConta.SaldoDevedorToString() );
      Data := nil;//nao guarda ref. pois nao necessita e é liberado depois

      case AitemConta.NumCota of
        0: GroupID:= 0;
        TSistemaService.C_NUM_COTA_TOTAL: GroupID:= 2;
        else GroupID:= 1;
      end;
    end;
  end;
var
  cota: TSistemaCota;
  cotaTotal: TSistemaCota;
begin
  lvDetalles.Clear();

  for cota in ACotas do
  begin
    AddItemLista(IntToStr(cota.NumCota), cota);
  end;
  //add total financiamento - com base na ultima cota e no servico
  cotaTotal:= FSistema.CalculaCotaDeTotais();
  AddItemLista('Totais', cotaTotal);
  cotaTotal.Free();
end;

procedure TFPgtoGenerico.simularFinanciamento();
var
  aDados: TListaCotas;
  ACapital, ATaxa: Extended;
  ACotas: Word;
begin
  //get dados
  ACapital:= StrToFloatDef(edCapital.Text, 0.0);
  ATaxa:= StrToFloatDef(edTaxaJuros.Text, 0.0);
  ACotas:= StrToIntDef(edPeriodos.Text, 0);

  //valida dados
  //todo encampular valiação no Servico
  Assert(ACapital > 0, 'Captital deve ter valor superior a Zero!' );
  Assert(ATaxa > 0, 'Taxa deve ter valor superior a Zero!' );
  Assert(ACotas > 0, 'Periodos deve ter valor superior a Zero!' );



  //calcula
  aDados:= FSistema.CalculaCotasFinanciamento(ACapital, ATaxa, ACotas);

  //binda lista
  DoExibeDadosCotas(aDados);

  //dispose - memory leak
  aDados.Free();
end;

procedure TFPgtoGenerico.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TFPgtoGenerico.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //todo validações
end;

procedure TFPgtoGenerico.btnSimularClick(Sender: TObject);
begin
  simularFinanciamento();
end;

{ TSistemaCotaHelper }
function TSistemaCotaHelper.AmortizacaoToString: String;
begin
  Result:= FormatCurr(',0.00', Self.Amortizacao);
end;

function TSistemaCotaHelper.JurosToString: String;
begin
  Result:= FormatCurr(',0.00', Self.Juros);
end;

function TSistemaCotaHelper.PagamentoToString: String;
begin
  Result:= FormatCurr(',0.00', Self.Pagamento);
end;

function TSistemaCotaHelper.SaldoDevedorToString: String;
begin
  Result:= FormatCurr(',0.00', Self.SaldoDevedor);
end;

function TSistemaCotaHelper.ToString: String;
begin
  Result:= Format('#%d, J:%s, A:%s, P:%s, S:%s', [
              Self.NumCota,
              Self.JurosToString,
              Self.AmortizacaoToString,
              Self.PagamentoToString,
              Self.SaldoDevedorToString
             ]);
end;

end.
