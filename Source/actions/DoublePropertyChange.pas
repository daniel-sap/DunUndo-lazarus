unit DoublePropertyChange;

interface

uses
  UndoRedoAction;

type

  TDoublePropertyChange = class(TUndoAction)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fOldValue: Double;
    fNewValue: Double;
    procedure setValue(aValue: Double);
  protected
  public
    constructor Create(aChangeObject: TObject; aPropName: string; aOldValue: Double; aNewValue: Double); reintroduce; virtual;

    procedure Undo; override;
    procedure Redo; override;

    procedure updateOldValue();

    property ChangedObject: TObject read fChangedObject;
    property PropertyName: string read fPropertyName;
    property OldValue: Double read fOldValue write fOldValue;
    property NewValue: Double read fNewValue write fNewValue;
  end;

implementation

uses
  Rtti, SysUtils;

constructor TDoublePropertyChange.Create(aChangeObject: TObject; aPropName: string; aOldValue, aNewValue: Double);
begin
  inherited Create;
  fChangedObject := aChangeObject;
  fPropertyName := aPropName;

  OldValue := aOldValue;
  NewValue := aNewValue;
end;

procedure TDoublePropertyChange.Undo;
begin
  setValue(fOldValue);
end;

procedure TDoublePropertyChange.Redo;
begin
  setValue(fNewValue);
end;

procedure TDoublePropertyChange.setValue(aValue: Double);
var
  context: TRTTIContext;
  rttiType: TRttiType;
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
procedure TDoublePropertyChange.updateOldValue;
var
  context: TRTTIContext;
  rttiType: TRttiType;
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
  fOldValue := fProperty.GetValue(fChangedObject).AsExtended;
  context.Free;
end;

end.
