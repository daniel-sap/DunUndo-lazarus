unit PropertyObjectDoubleChange;

interface

uses
  UndoRedoAction, PropertyObject;

type

  TPropertyObjectDoubleChange = class(TUndoAction)
  private
    fPropertyName: string;
    fOldValue: Double;
    fNewValue: Double;
  protected
  public
    procedure Undo; override;
    procedure Redo; override;

    procedure beforeChange(); override;

    property PropertyName: string read fPropertyName write fPropertyName;
    property OldValue: Double read fOldValue write fOldValue;
    property NewValue: Double read fNewValue write fNewValue;
  end;

implementation

procedure TPropertyObjectDoubleChange.Undo;
begin
  TPropertyObject(ChangedObject).setValue(fPropertyName, fOldValue);
end;

procedure TPropertyObjectDoubleChange.Redo;
begin
  TPropertyObject(ChangedObject).setValue(fPropertyName, fNewValue);
end;

procedure TPropertyObjectDoubleChange.beforeChange();
begin
  fOldValue := TPropertyObject(ChangedObject).asDouble(fPropertyName);
end;

end.
