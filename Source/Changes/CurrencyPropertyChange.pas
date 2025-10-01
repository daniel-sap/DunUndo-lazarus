unit CurrencyPropertyChange;

interface

uses
  Dun.UndoChange;

type

  TCurrencyPropertyChange = class(TUndoChange)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fOldValue: Currency;
    fNewValue: Currency;
    procedure setValue(aValue: Currency);
  public
    constructor Create(aChangeObject: TObject; aPropName: string; aOldValue: Currency; aNewValue: Currency); reintroduce; virtual;

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

constructor TCurrencyPropertyChange.Create(aChangeObject: TObject; aPropName: string; aOldValue, aNewValue: Currency);
begin
  inherited Create;
  ChangedObject := aChangeObject;
  PropertyName := aPropName;

  OldValue := aOldValue;
  NewValue := aNewValue;
end;

procedure TCurrencyPropertyChange.Undo;
begin
  setValue(fOldValue);
end;

procedure TCurrencyPropertyChange.Redo;
begin
  setValue(fNewValue);
end;

procedure TCurrencyPropertyChange.setValue(aValue: Currency);
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
procedure TCurrencyPropertyChange.updateOldValue;
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
  fOldValue := fProperty.GetValue(fChangedObject).AsCurrency;
  context.Free;
end;

end.
