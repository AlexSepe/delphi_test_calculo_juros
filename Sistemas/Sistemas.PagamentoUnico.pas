unit Sistemas.PagamentoUnico;

interface

uses
  Sistemas.Controller,
  Sistemas.Dados,
  System.Generics.Collections;


type
  TSistemaPgtoUnicoServiceClazz = class of TSistemaPgtoUnicoService;
  TSistemaPgtoUnicoService = class(TSistemaService)
  protected
    const C_NOME_SERVICO = 'Sistema de Pagamento único';
    class constructor Create();
  public
    function CalculaCotasFinanciamento(ACapital, ATaxa: Extended; AQtdeCotas: Word): TListaCotas; override;
    function CalculaCotaDeTotais(): TSistemaCota; override;
  public
    class function GetNomeSistema(): String; override;
    class function LazyLoadIt(): TSistemaService; override;
  end;

implementation

uses
  Math;

{ TSistemaPgtoUnicoService }
function TSistemaPgtoUnicoService.CalculaCotaDeTotais(): TSistemaCota;
begin
  Result:= TSistemaCota.Create(
     C_NUM_COTA_TOTAL,//Num Cota simbolico
     Self.JurosTotal, //Juros
     Self.Capital, //Amortizacao
     Self.Capital + Self.JurosTotal, //Pagto Total
     0
  );
end;

function TSistemaPgtoUnicoService.CalculaCotasFinanciamento(ACapital, ATaxa: Extended; AQtdeCotas: Word): TListaCotas;
var
  I: Word;
  thisCota, lastCota: TSistemaCota;
begin
  Self.Capital:= ACapital;
  Self.Taxa:= ATaxa;
  Self.QtdeCotas:= AQtdeCotas;
  Self.JurosTotal:= 0;

  //cache cotas
  Result:= TListaCotas.Create();
  thisCota:= nil;

  //primeira cota //todo encapsular no construtor/ou builder
  lastCota:= TSistemaCota.Create({default zerado});
  lastCota.SaldoDevedor:= ACapital;
  Result.Add(lastCota);

  for I := 1 to AQtdeCotas do
  begin
    //calculo simples, acrecenta a taxa de juros sobre o ultimo saldo
    thisCota:= TSistemaCota.Create();
    thisCota.NumCota:= I;
    thisCota.Amortizacao:= 0;
    thisCota.Pagamento:= 0;
    //arredonda em 2 digito
    thisCota.Juros:= Math.RoundTo( (lastCota.SaldoDevedor * (1 + (ATaxa / 100))) - (lastCota.SaldoDevedor), -2);
    thisCota.SaldoDevedor:= lastCota.SaldoDevedor + thisCota.Juros;

    Result.Add(thisCota);
    lastCota:= thisCota;

    //soma o juros total - info de servico
    Self.JurosTotal:= Self.JurosTotal + thisCota.Juros;
  end;

  //joga o saldo da ultima cota para ser quitado!
  lastCota.Pagamento:= lastCota.SaldoDevedor;
  lastCota.Amortizacao:= ACapital;
  thisCota.SaldoDevedor:= 0;
end;

class constructor TSistemaPgtoUnicoService.Create;
begin
  //class init = regitra o servico no locator
  TSistemaController.Instance.RegistraSistema( TSistemaPgtoUnicoService );
end;

class function TSistemaPgtoUnicoService.GetNomeSistema: String;
begin
  Result:= C_NOME_SERVICO;
end;

class function TSistemaPgtoUnicoService.LazyLoadIt: TSistemaService;
begin
  Result:= TSistemaPgtoUnicoService.Create();
end;

end.
