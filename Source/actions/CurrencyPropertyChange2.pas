unit CurrencyPropertyChange2;

interface

uses
  UndoRedoAction;

type

  TCurrencyPropertyChange2 = class(TUndoAction)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fOldValue: Currency;
    fNewValue: Currency;
    function getValue(): Currency;
    procedure setValue(aValue: Currency);
  public
    constructor Create(aChangeObject: TObject; aPropName: string); reintroduce; virtual;

    procedure Undo; override;
    procedure Redo; override;

    procedure updateOldValue();

    property ChangedObject: TObject read fChangedObject write fChangedObject;
    property PropertyName: string read fPropertyName write fPropertyName;
    property OldValue: Currency read fOldValue write fOldValue;
    property NewValue: Currency read fNewValue write fNewValue;
  end;

implementation

uses
  SysUtils, Rtti;

constructor TCurrencyPropertyChange2.Create(aChangeObject: TObject; aPropName: string);
begin
  inherited Create;
  ChangedObject := aChangeObject;
  PropertyName := aPropName;
  OldValue := GetValue();
end;

procedure TCurrencyPropertyChange2.Undo;
begin
  fNewValue := getValue();
  setValue(fOldValue);
end;

procedure TCurrencyPropertyChange2.Redo;
begin
  setValue(fNewValue);
end;

function TCurrencyPropertyChange2.getValue: Currency;
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
  Result := fProperty.GetValue(fChangedObject).AsCurrency;
  context.Free;
end;

procedure TCurrencyPropertyChange2.setValue(aValue: Currency);
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
procedure TCurrencyPropertyChange2.updateOldValue;
begin
  fOldValue := getValue();
end;

end.
