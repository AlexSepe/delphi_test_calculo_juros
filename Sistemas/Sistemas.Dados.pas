unit Sistemas.Dados;

interface

uses
  System.Generics.Collections;

type
  TSistemaCota = class(TObject)
  protected
    //Num Cota
    FNumCota: Cardinal;
    //Juros
    FJuros: Extended;
    //Amortização Saldo devedor
    FAmortizacao: Extended;
    //Pagamento
    FPagamento: Extended;
    //Saldo devedor
    FSaldoDevedor: Extended;
  public
    //Num Cota
    property NumCota: Cardinal read FNumCota write FNumCota;
    //Juros
    property Juros: Extended read FJuros write FJuros;
    //Amortização Saldo devedor
    property Amortizacao: Extended read FAmortizacao write FAmortizacao;
    //Pagamento
    property Pagamento: Extended read FPagamento write FPagamento;
    //Saldo devedor
    property SaldoDevedor: Extended read FSaldoDevedor write FSaldoDevedor;
  public
    constructor Create(ANumCota: Cardinal; AJuros, AAmortizacao, APagamento, ASaldoDevedor: Extended); reintroduce; overload; virtual;
    constructor Create(); reintroduce; overload; virtual;
  end;

  TListaCotas = class(TList<TSistemaCota>)
  private
    destructor Destroy; override;
  end;

implementation

{ TSistemaCota }

constructor TSistemaCota.Create(ANumCota: Cardinal; AJuros, AAmortizacao,
  APagamento, ASaldoDevedor: Extended);
begin
  inherited Create();
  //Num Cota
  FNumCota:= ANumCota;
  //Juros
  FJuros:= AJuros;
  //Amortização Saldo devedor
  FAmortizacao:= AAmortizacao;
  //Pagamento
  FPagamento:= APagamento;
  //Saldo devedor
  FSaldoDevedor:= ASaldoDevedor;
end;

constructor TSistemaCota.Create();
begin
  Create(0, 0, 0, 0, 0);
end;


{ TListaDados }

destructor TListaCotas.Destroy();
var
  I: Integer;
begin
  //destroy objetos de dados
  for I := 0 to Count-1 do
    Items[I].Free();
  inherited Destroy();
end;

end.
