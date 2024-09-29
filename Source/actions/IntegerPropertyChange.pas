unit IntegerPropertyChange;

interface

uses
  UndoRedoAction, Rtti;

type

  TIntegerPropertyChange = class(TUndoAction)
  private
    fChangedObject: TObject;
    fPropertyName: string;
    fOldValue: Integer;
    fNewValue: Integer;
  protected
  public
    constructor Create(aChangeObject: TObject; aPropName: string); reintroduce; virtual;
    destructor Destroy; override;

    procedure Undo; override;
    procedure Redo; override;

    procedure updateOldValue();

    property ChangedObject: TObject read fChangedObject;
    property PropertyName: string read fPropertyName;
    property OldValue: Integer read fOldValue write fOldValue;
    property NewValue: Integer read fNewValue write fNewValue;
  end;

  TEnumPropertyChange = class(TUndoAction)
  private
    fPropertyName: string;
    fNewValue: Integer;
    fOldValue: Integer;
    fChangedObject: TObject;
  public
    constructor Create(aChangeObject: TObject; aPropName: string); reintroduce; virtual;
    destructor Destroy; override;

    procedure Undo; override;
    procedure Redo; override;

    function getPropertyForEnum(rttiType: TRttiType; PropName: String): TRttiProperty;

    property ChangedObject: TObject read fChangedObject;
    property PropertyName: string read fPropertyName;
    property OldValue: Integer read fOldValue write fOldValue;
    property NewValue: Integer read fNewValue write fNewValue;
  end;

implementation

uses
  SysUtils, TypInfo;

constructor TIntegerPropertyChange.Create(aChangeObject: TObject; aPropName: string);
begin
  inherited Create;
  fChangedObject := aChangeObject;
  fPropertyName := aPropName;
end;

destructor TIntegerPropertyChange.Destroy;
begin
  inherited;
end;

procedure TIntegerPropertyChange.Undo;
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
  v: TValue;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := rttiType.GetProperty(fPropertyName);
  if not assigned(fProperty) then begin
    raise Exception.Create('Property ' + fPropertyName +
                           ' in class ' + ChangedObject.ClassName +
                           ' not found. Probably needs to be published');
  end;
  fProperty.SetValue(fChangedObject, fOldValue);
  context.Free;
end;

procedure TIntegerPropertyChange.Redo;
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
  fProperty.SetValue(fChangedObject, fNewValue);
  context.Free;
end;

procedure TIntegerPropertyChange.updateOldValue;
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
  fOldValue := fProperty.GetValue(fChangedObject).AsInteger;
  context.Free;
end;

{ TEnumPropertyChange }

constructor TEnumPropertyChange.Create(aChangeObject: TObject; aPropName: string);
begin
  inherited Create;
  fChangedObject := aChangeObject;
  fPropertyName := aPropName;
end;

destructor TEnumPropertyChange.Destroy;
begin
  inherited;
end;

function TEnumPropertyChange.getPropertyForEnum(rttiType: TRttiType;
  PropName: String): TRttiProperty;
var
  prop: TRttiProperty;
begin
  for prop in rttiType.GetProperties do begin
    if prop.PropertyType.TypeKind <> tkEnumeration then
      Continue;

    if prop.Name = PropName then begin
      Result := prop;
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TEnumPropertyChange.Redo;
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
  val: TValue;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := getPropertyForEnum(rttiType, fPropertyName);
  val.FromOrdinal(fProperty.PropertyType.Handle, fNewValue);
  fProperty.SetValue(fChangedObject, val);
  context.Free;
end;

procedure TEnumPropertyChange.Undo;
var
  context: TRTTIContext;
  rttiType: TRttiType;
  fProperty: TRttiProperty;
  val: TValue;
begin
  context := TRTTIContext.Create;
  rttiType := context.GetType(ChangedObject.ClassType);
  fProperty := getPropertyForEnum(rttiType, fPropertyName);
  val.FromOrdinal(fProperty.PropertyType.Handle, fOldValue);
  fProperty.SetValue(fChangedObject, val);
  context.Free;
end;

end.
