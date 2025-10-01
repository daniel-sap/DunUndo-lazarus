unit Dun.UndoChange;

interface

uses
  DoubleLinkedListItem, SingleLinkedListNodeIntf, InterfaceObject;

type

  TUndoChange = class abstract
  private
    fChangedObject: TObject;
    fOwnsData: Boolean;
    procedure setChangedObject(const Value: TObject);
  public
    constructor Create(); virtual;
    destructor Destroy; override;
    procedure Undo(); virtual; abstract;
    procedure Redo(); virtual; abstract;
    procedure ClearData(); virtual;
    procedure BeforeChange(); virtual;
  public
    property ChangedObject: TObject read fChangedObject write setChangedObject;
    property OwnsData: Boolean read fOwnsData write fOwnsData;
  end;

implementation

constructor TUndoChange.Create();
begin
  inherited Create;
  fOwnsData := False;
end;

destructor TUndoChange.Destroy;
begin
  inherited Destroy;
end;

procedure TUndoChange.SetChangedObject(const Value: TObject);
begin
  fChangedObject := Value;
  BeforeChange();
end;

procedure TUndoChange.BeforeChange;
begin

end;

procedure TUndoChange.ClearData;
begin

end;

end.
