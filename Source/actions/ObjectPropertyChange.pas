unit ObjectPropertyChange;

interface

uses
  UndoRedoAction;

type

  TObjectPropertyChange = class(TUndoAction)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fOldValue: TObject;
    fNewValue: TObject;
    procedure setValue(aValue: TObject);
  public
    constructor Create(aChangeObject: TObject; aPropName: string); reintroduce; virtual;
    destructor Destroy(); override;

    procedure Undo; override;
    procedure Redo; override;

    procedure updateOldValue();
    procedure clearData(); override;

    property ChangedObject: TObject read fChangedObject;
    property PropertyName: string read fPropertyName;
    property OldValue: TObject read fOldValue write fOldValue;
    property NewValue: TObject read fNewValue write fNewValue;
  end;

implementation

uses
  SysUtils, Rtti;

procedure TObjectPropertyChange.clearData;
begin
  if not ownsData then
    exit;

  FreeAndNil(fNewValue);
end;

constructor TObjectPropertyChange.Create(aChangeObject: TObject; aPropName: string);
begin
  inherited Create;
  fChangedObject := aChangeObject;
  fPropertyName := aPropName;
end;

destructor TObjectPropertyChange.Destroy;
begin
  inherited;
end;

procedure TObjectPropertyChange.Undo;
begin
  setValue(fOldValue);
end;

procedure TObjectPropertyChange.Redo;
begin
  setValue(fNewValue);
end;

procedure TObjectPropertyChange.setValue(aValue: TObject);
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(fChangedObject.ClassType);
  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  fProperty.SetValue(fChangedObject, aValue);
  context.Free();
end;

// Takes the current value of the object property and set it as old value
procedure TObjectPropertyChange.updateOldValue;
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(fChangedObject.ClassType);

  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  fOldValue := fProperty.GetValue(fChangedObject).AsObject;
  context.Free();
end;

end.
