unit Sistemas.Controller;

interface

uses
  Sistemas.Dados,
  System.Generics.Collections,
  Forms;

type
  TSistemaServiceClazz = class of TSistemaService;
  TSistemaService = class(TObject)
  private
    FCapital: Extended;
    FTaxa: Extended;
    FQtdeCotas: Word;
    FJurosTotal: Extended;
  public
    property Capital: Extended read FCapital write FCapital;
    property Taxa: Extended read FTaxa write FTaxa;
    property QtdeCotas: Word read FQtdeCotas write FQtdeCotas;
    property JurosTotal: Extended read FJurosTotal write FJurosTotal;
    //todo: deixar a lista de cotas calculadas no servico?
  public
    const C_NUM_COTA_TOTAL = MaxInt;
    function CalculaCotasFinanciamento(ACapital, ATaxa: Extended; ACotas: Word): TListaCotas; virtual; abstract;
    function CalculaCotaDeTotais(): TSistemaCota; virtual; abstract;
  public
    class function GetNomeSistema(): String; virtual; abstract;
    class function LazyLoadIt(): TSistemaService; virtual; abstract;
  end;

  //Singleton Service Locator para os algoritimos de Calculos
  TSistemaController = class
  private
    class var FInstance: TSistemaController;
    class constructor Create();
  protected
    FListaClassesSistemas: TDictionary< TSistemaServiceClazz, TFormClass >;
    constructor Create(); reintroduce; virtual;
  public
    procedure RegistraSistema(AClazz: TSistemaServiceClazz); virtual; final;
    procedure RegistraFormFor(AClazz: TSistemaServiceClazz; AFormClazz: TFormClass); virtual; final;

    function GetSistemas(): TArray<TSistemaServiceClazz>;
    function GetFormFor(AClazz: TSistemaServiceClazz): TFormClass;
  public
    class property Instance: TSistemaController read FInstance;
  end;

implementation

{ TSistemaController }

class constructor TSistemaController.Create();
begin
  FInstance:= TSistemaController.Create();  //init singleton
end;

constructor TSistemaController.Create();
begin
  inherited Create();
  FListaClassesSistemas:= TDictionary< TSistemaServiceClazz, TFormClass >.Create();
end;

function TSistemaController.GetFormFor(AClazz: TSistemaServiceClazz): TFormClass;
begin
  Result:= nil;
  FListaClassesSistemas.TryGetValue(AClazz, Result);
end;

function TSistemaController.GetSistemas(): TArray<TSistemaServiceClazz>;
begin
  Result:= FListaClassesSistemas.Keys.ToArray();
end;

procedure TSistemaController.RegistraFormFor(AClazz: TSistemaServiceClazz;
  AFormClazz: TFormClass);
begin
  FListaClassesSistemas.AddOrSetValue(AClazz, AFormClazz);
end;

procedure TSistemaController.RegistraSistema(AClazz: TSistemaServiceClazz);
begin
  FListaClassesSistemas.Add( AClazz, nil );
end;


end.
