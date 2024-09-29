unit PropertyObjectObjectChange;

interface

uses
  UndoRedoAction, PropertyObject;

type

  TPropertyObjectObjectChange = class(TUndoAction)
  private
    fPropertyName: string;
    fOldValue: TObject;
    fNewValue: TObject;
  protected
  public
    procedure Undo; override;
    procedure Redo; override;

    procedure beforeChange(); override;

    property PropertyName: string read fPropertyName write fPropertyName;
    property OldValue: TObject read fOldValue write fOldValue;
    property NewValue: TObject read fNewValue write fNewValue;
  end;

implementation

procedure TPropertyObjectObjectChange.Undo;
begin
  TPropertyObject(ChangedObject).setValue(fPropertyName, fOldValue);
end;

procedure TPropertyObjectObjectChange.Redo;
begin
  TPropertyObject(ChangedObject).setValue(fPropertyName, fNewValue);
end;

procedure TPropertyObjectObjectChange.beforeChange();
begin
  fOldValue := TPropertyObject(ChangedObject).getValue(fPropertyName);
end;

end.
