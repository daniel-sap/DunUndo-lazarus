unit UndoRedoOperation;

interface

uses
  Classes, Dun.UndoChange;

type

  /// This class allows adding and keeping changes which can be added at once
  /// at the end. No need to start Action in the TUndoRedo.
  TUndoRedoOperation = class
  private
    fChanges: TList;
    function getCount: Integer;
    function getChange(Index: Integer): TUndoChange;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure addChange(aChange: TUndoChange);
    property Count: Integer read getCount;
    property Changes[Index: Integer]: TUndoChange read getChange; default;
  end;

implementation

uses
  SysUtils;

constructor TUndoRedoOperation.Create;
begin
  fChanges := TList.Create();
end;

destructor TUndoRedoOperation.Destroy;
begin
  FreeAndNil(fChanges);
  inherited;
end;

procedure TUndoRedoOperation.addChange(aChange: TUndoChange);
begin
  fChanges.Add(aChange);
end;

function TUndoRedoOperation.getChange(Index: Integer): TUndoChange;
begin
  Result := TUndoChange(fChanges[Index]);
end;

function TUndoRedoOperation.getCount: Integer;
begin
  Result := fChanges.Count;
end;

end.
