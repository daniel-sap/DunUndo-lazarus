unit BooleanPropertyChange;

interface

uses
  Dun.UndoChange;

type

  TBooleanPropertyChange = class(TUndoChange)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fOldValue: Boolean;
    fNewValue: Boolean;
    procedure setValue(aValue: Boolean);
  public
    constructor Create(aChangeObject: TObject; aPropName: string; OldValue: Boolean; NewValue: Boolean); reintroduce; virtual;

    procedure Undo; override;
    procedure Redo; override;

    procedure updateOldValue();

    property ChangedObject: TObject read fChangedObject;
    property PropertyName: string read fPropertyName;
    property OldValue: Boolean read fOldValue write fOldValue;
    property NewValue: Boolean read fNewValue write fNewValue;
  end;

implementation

uses
  Rtti, SysUtils;

constructor TBooleanPropertyChange.Create(aChangeObject: TObject; aPropName: string; OldValue, NewValue: Boolean);
begin
  inherited Create;
  fChangedObject := aChangeObject;
  fPropertyName := aPropName;

  OldValue := OldValue;
  NewValue := NewValue;
end;

procedure TBooleanPropertyChange.Undo;
begin
  setValue(fOldValue);
end;

procedure TBooleanPropertyChange.Redo;
begin
  setValue(fNewValue);
end;

procedure TBooleanPropertyChange.setValue(aValue: Boolean);
var
  rttiType: TRttiType;
  context: TRTTIContext;
  fProperty: TRttiProperty;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  fProperty.SetValue(ChangedObject, aValue);
  context.Free;
end;

// Takes the current value of the object property and set it as old value
procedure TBooleanPropertyChange.updateOldValue;
var
  rttiType: TRttiType;
  context: TRTTIContext;
  fProperty: TRttiProperty;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  fOldValue := fProperty.GetValue(fChangedObject).AsBoolean;
  context.Free;
end;

end.
