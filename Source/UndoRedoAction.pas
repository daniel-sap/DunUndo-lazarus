unit UndoRedoAction;

interface

uses
  DoubleLinkedListItem, SingleLinkedListNodeIntf, InterfaceObject;

type

  TUndoAction = class abstract
  private
    fChangedObject: TObject;
    fOwnsData: Boolean;
    procedure setChangedObject(const Value: TObject);
  public
    constructor Create(); virtual;
    destructor Destroy; override;
    procedure undo(); virtual; abstract;
    procedure redo(); virtual; abstract;
    procedure clearData(); virtual;
    procedure beforeChange(); virtual;

    property ChangedObject: TObject read fChangedObject write setChangedObject;
    property OwnsData: Boolean read fOwnsData write fOwnsData;
  end;

implementation

constructor TUndoAction.Create();
begin
  inherited Create;
  fOwnsData := False;
end;

destructor TUndoAction.Destroy;
begin
  inherited Destroy;
end;

procedure TUndoAction.setChangedObject(const Value: TObject);
begin
  fChangedObject := Value;
  beforeChange();
end;

procedure TUndoAction.beforeChange;
begin

end;

procedure TUndoAction.clearData;
begin

end;

end.
