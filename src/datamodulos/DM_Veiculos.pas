unit DM_Veiculos;

interface

uses
  System.Classes, System.SysUtils, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, uModeloVeiculo;

type
  TDMVeiculos = class(TDataModule)
    qryModelosVeiculo: TFDQuery;
    qryModeloVeiculo: TFDQuery;
    qryMarcas: TFDQuery;
    dsModelosVeiculo: TDataSource;
  public
    procedure AbrirModelos;
    procedure InserirModeloVeiculo;
    procedure AlterarModeloVeiculo;
    procedure SalvarModeloVeiculo;
    procedure ExcluirModeloVeiculo;
    procedure CancelarEdicao;
    procedure CarregarMarcas(ALista: TStrings);
    procedure CarregarModelosDaMarca(const AMarca: string; ALista: TStrings);
    function ObterModeloVeiculo(AId: Integer): TModeloVeiculo;
  end;

var
  DMVeiculos: TDMVeiculos;

implementation

uses
  DM_BancoDados;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDMVeiculos.AbrirModelos;
begin
  qryModelosVeiculo.Close;
  qryModelosVeiculo.Open;
end;

procedure TDMVeiculos.InserirModeloVeiculo;
begin
  if not qryModelosVeiculo.Active then
    AbrirModelos;
  qryModelosVeiculo.Append;
  qryModelosVeiculo.FieldByName('ativo').AsInteger := 1;
end;

procedure TDMVeiculos.AlterarModeloVeiculo;
begin
  if not qryModelosVeiculo.IsEmpty and not (qryModelosVeiculo.State in dsEditModes) then
    qryModelosVeiculo.Edit;
end;

procedure TDMVeiculos.SalvarModeloVeiculo;
begin
  if qryModelosVeiculo.State in dsEditModes then
    qryModelosVeiculo.Post;
end;

procedure TDMVeiculos.CancelarEdicao;
begin
  if qryModelosVeiculo.State in dsEditModes then
    qryModelosVeiculo.Cancel;
end;

procedure TDMVeiculos.ExcluirModeloVeiculo;
begin
  if qryModelosVeiculo.IsEmpty then
    Exit;
  qryModelosVeiculo.Edit;
  qryModelosVeiculo.FieldByName('ativo').AsInteger := 0;
  qryModelosVeiculo.Post;
  qryModelosVeiculo.Refresh;
end;

procedure TDMVeiculos.CarregarMarcas(ALista: TStrings);
begin
  ALista.BeginUpdate;
  try
    ALista.Clear;
    qryMarcas.Close;
    qryMarcas.SQL.Text :=
      'select distinct marca from modelo_veiculo where ativo = 1 order by marca';
    qryMarcas.Open;
    while not qryMarcas.Eof do
    begin
      ALista.Add(qryMarcas.Fields[0].AsString);
      qryMarcas.Next;
    end;
  finally
    qryMarcas.Close;
    ALista.EndUpdate;
  end;
end;

procedure TDMVeiculos.CarregarModelosDaMarca(const AMarca: string;
  ALista: TStrings);
begin
  ALista.BeginUpdate;
  try
    ALista.Clear;
    qryMarcas.Close;
    qryMarcas.SQL.Text :=
      'select id, modelo, ano_inicial, ano_final, ' +
      'coalesce(codigo_motor, familia_motor, '''') motor ' +
      'from modelo_veiculo where ativo = 1 and marca = :marca ' +
      'order by modelo, ano_inicial';
    qryMarcas.ParamByName('marca').AsString := AMarca;
    qryMarcas.Open;
    while not qryMarcas.Eof do
    begin
      ALista.AddObject(Format('%s | %d-%d | %s', [
        qryMarcas.FieldByName('modelo').AsString,
        qryMarcas.FieldByName('ano_inicial').AsInteger,
        qryMarcas.FieldByName('ano_final').AsInteger,
        qryMarcas.FieldByName('motor').AsString]),
        TObject(NativeInt(qryMarcas.FieldByName('id').AsInteger)));
      qryMarcas.Next;
    end;
  finally
    qryMarcas.Close;
    ALista.EndUpdate;
  end;
end;

function TDMVeiculos.ObterModeloVeiculo(AId: Integer): TModeloVeiculo;
begin
  Result := nil;
  qryModeloVeiculo.Close;
  qryModeloVeiculo.ParamByName('id').AsInteger := AId;
  qryModeloVeiculo.Open;
  if qryModeloVeiculo.IsEmpty then
    Exit;

  Result := TModeloVeiculo.Create;
  Result.Id := qryModeloVeiculo.FieldByName('id').AsInteger;
  Result.Marca := qryModeloVeiculo.FieldByName('marca').AsString;
  Result.Modelo := qryModeloVeiculo.FieldByName('modelo').AsString;
  Result.AnoInicial := qryModeloVeiculo.FieldByName('ano_inicial').AsInteger;
  Result.AnoFinal := qryModeloVeiculo.FieldByName('ano_final').AsInteger;
  Result.CodigoMotor := qryModeloVeiculo.FieldByName('codigo_motor').AsString;
  Result.FamiliaMotor := qryModeloVeiculo.FieldByName('familia_motor').AsString;
  Result.CilindradaCC := qryModeloVeiculo.FieldByName('cilindrada_cc').AsInteger;
  Result.Cilindros := qryModeloVeiculo.FieldByName('cilindros').AsInteger;
  Result.Combustivel := qryModeloVeiculo.FieldByName('combustivel').AsString;
  Result.Aspiracao := qryModeloVeiculo.FieldByName('aspiracao').AsString;
  Result.Valvulas := qryModeloVeiculo.FieldByName('valvulas').AsInteger;
  Result.TipoInjecao := qryModeloVeiculo.FieldByName('tipo_injecao').AsString;
end;

end.
