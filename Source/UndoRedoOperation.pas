unit UndoRedoOperation;

interface

uses
  Classes, UndoRedoAction;

type

  TUndoRedoOperation = class
  private
    fActions: TList;
    function getCount: Integer;
    function getAction(Index: Integer): TUndoAction;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure addAction(aAction: TUndoAction);
    property Count: Integer read getCount;
    property Actions[Index: Integer]: TUndoAction read getAction; default;
  end;

implementation

uses
  SysUtils;

constructor TUndoRedoOperation.Create;
begin
  fActions := TList.Create();
end;

destructor TUndoRedoOperation.Destroy;
begin
  FreeAndNil(fActions);
  inherited;
end;

procedure TUndoRedoOperation.addAction(aAction: TUndoAction);
begin
  fActions.Add(aAction);
end;

function TUndoRedoOperation.getAction(Index: Integer): TUndoAction;
begin
  Result := TUndoAction(fActions[Index]);
end;

function TUndoRedoOperation.getCount: Integer;
begin
  Result := fActions.Count;
end;

end.
