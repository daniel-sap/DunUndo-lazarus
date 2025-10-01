unit DoublePropertyChange2;

interface

uses
  Dun.UndoChange;

type

  TDoublePropertyChange2 = class(TUndoChange)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fValue: Double;
    fNewValue: Double;
  protected
  public
    constructor Create(aChangeObject: TObject; aPropName: string); reintroduce; virtual;

    procedure Undo; override;
    procedure Redo; override;

    property ChangedObject: TObject read fChangedObject;
    property PropertyName: string read fPropertyName;
    property Value: Double read fValue write fValue;
  end;

implementation

uses
  Rtti, SysUtils;

constructor TDoublePropertyChange2.Create(aChangeObject: TObject; aPropName: string);
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
begin
  inherited Create;
  fChangedObject := aChangeObject;
  fPropertyName := aPropName;

  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  fValue := fProperty.GetValue(fChangedObject).AsExtended;
  context.Free;
end;

procedure TDoublePropertyChange2.Undo;
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
  currentValue: Double;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  currentValue := fProperty.GetValue(ChangedObject).AsExtended;
  fProperty.SetValue(ChangedObject, fValue);
  fValue := currentValue;
  context.Free;
end;

procedure TDoublePropertyChange2.Redo;
begin
  Undo;
end;

end.
