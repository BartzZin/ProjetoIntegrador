unit DM_Defeitos;

interface

uses
  System.Classes, Data.DB, FireDAC.Comp.Client;

type
  TDMDefeitos = class(TDataModule)
    qryDefeitos: TFDQuery;
    dsDefeitos: TDataSource;
  public
    procedure AbrirDefeitos;
    procedure Novo;
    procedure Editar;
    procedure Salvar;
    procedure Cancelar;
    procedure Excluir;
  end;

var
  DMDefeitos: TDMDefeitos;

implementation

uses
  DM_BancoDados;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDMDefeitos.AbrirDefeitos;
begin
  qryDefeitos.Close;
  qryDefeitos.Open;
end;

procedure TDMDefeitos.Novo;
begin
  qryDefeitos.Append;
  qryDefeitos.FieldByName('ativo').AsInteger := 1;
end;

procedure TDMDefeitos.Editar;
begin
  if not qryDefeitos.IsEmpty and not (qryDefeitos.State in dsEditModes) then
    qryDefeitos.Edit;
end;

procedure TDMDefeitos.Salvar;
begin
  if qryDefeitos.State in dsEditModes then
    qryDefeitos.Post;
end;

procedure TDMDefeitos.Cancelar;
begin
  if qryDefeitos.State in dsEditModes then
    qryDefeitos.Cancel;
end;

procedure TDMDefeitos.Excluir;
begin
  if qryDefeitos.IsEmpty then
    Exit;
  qryDefeitos.Edit;
  qryDefeitos.FieldByName('ativo').AsInteger := 0;
  qryDefeitos.Post;
  qryDefeitos.Refresh;
end;

end.
