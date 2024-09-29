unit UndoRedo;

interface

uses
  Generics.Collections, UndoRedoAction, UndoRedoOperation, Classes, Contnrs,
  DLinkedList;

type

  TUndoStep = class
  private
    fPrev: TUndoStep;
    fNext: TUndoStep;
    fTag: Integer;
    fActions: TList<TUndoAction>;
  public
    GroupId: Integer;
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure undo();
    procedure redo();
    procedure clearData();

    property Actions: TList<TUndoAction> read fActions;
    property Tag: Integer read fTag write fTag;
  published
    property Prev: TUndoStep read fPrev write fPrev;
    property Next: TUndoStep read fNext write fNext;
  end;


  TUndo = class
  private
    fActive: TUndoStep;
    fStep: Boolean;
    fInOperation: Boolean;

    fNewStep: TUndoStep;

    fOperations: TObjectList;
    fCurrentOperation: TUndoRedoOperation;

    fSteps: TDLinkedList<TUndoStep>;
    fAfterUndo: TNotifyEvent;
    fBeforeUndo: TNotifyEvent;
    fAfterRedo: TNotifyEvent;
    fBeforeRedo: TNotifyEvent;
    fOnEndStep: TNotifyEvent;
    fAfterStartStep: TNotifyEvent;
  protected
    function getCount: Integer; virtual;
    procedure RemoveAfterActive;
  public
    constructor Create(); virtual;
    destructor Destroy; override;
    procedure append(aAction: TUndoAction);
    procedure undo();
    procedure redo();
    function canUndo: Boolean;
    function canRedo: Boolean;
    procedure Clear;
    procedure startStep; overload;
    procedure startStep(aGroup: Integer); overload;
    procedure endStep();

    procedure registerActions(aActions: TList<TUndoAction>);
    procedure registerObjectPropertyChange(aObject: TObject; aPropertyName: string; aOldValue: TObject; aNewValue: TObject; ownsData: Boolean = false);
    procedure registerIntegerPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Integer);
    procedure registerEnumPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Integer);
    procedure registerDoublePropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Double); overload;
    procedure registerDoublePropertyChange(aObject: TObject; aPropName: String); overload;
    procedure registerCurrencyPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Double);
    procedure registerCurrencyPropertyChange2(aObject: TObject; aPropName: String);
    procedure registerBooleanPropertyChange(aObject: TObject; PropName: String; OldValue, NewValue: Boolean);
    procedure registerListAppendUndo(aElement: TObject; aList: TList);
    procedure registerListDeleteUndo(aElement: TObject; aList: TList);
    procedure registerListGAppendUndo(aElement: TObject; aList: TList<TObject>);
    procedure registerListGDeleteUndo(aElement: TObject; aList: TList<TObject>);

    property Active: TUndoStep read fActive;
    property Count: Integer read getCount;
    property InOperation: Boolean read fInOperation;
    property inStep: Boolean read fStep;
    property Steps: TDLinkedList<TUndoStep> read fSteps;
  public
    procedure startOperation;
    procedure endOperation;

    property NewStep: TUndoStep read fNewStep;
    property BeforeUndo: TNotifyEvent read fBeforeUndo write fBeforeUndo;
    property AfterUndo: TNotifyEvent read fAfterUndo write fAfterUndo;
    property BeforeRedo: TNotifyEvent read fBeforeRedo write fBeforeRedo;
    property AfterRedo: TNotifyEvent read fAfterRedo write fAfterRedo;
    property AfterStartStep: TNotifyEvent read fAfterStartStep write fAfterStartStep;
    property OnEndStep: TNotifyEvent read fOnEndStep write fOnEndStep;
  end;

implementation

uses
  SysUtils, ObjectPropertyChange, DoublePropertyChange, DoublePropertyChange2, IntegerPropertyChange,
  CurrencyPropertyChange, CurrencyPropertyChange2, BooleanPropertyChange,
  ListInsertChange, ListRemoveChange, ListGInsertChange, ListGRemoveChange;

constructor TUndo.Create();
begin
  inherited Create;
  fOperations := TObjectList.Create();
  fSteps := TDLinkedList<TUndoStep>.Create();

  fActive := nil;
  fNewStep := nil;
  fStep := False;
  fInOperation := False;
end;

destructor TUndo.Destroy;
begin
  freeAndNil(fOperations);
  freeAndNil(fSteps);
  inherited Destroy;
end;

// ����� True, ������ ���� �� �� ������� �������� Undo.
// � ���� � ��������, ������ ��� ������� ������.
function TUndo.canUndo: Boolean;
begin
  Result := Active <> nil;
end;

// ����� True, ������ ���� �� �� ������� �������� Redo. � ���� � ��������,
// ������ �������� Action ��� Child, � ��� �������� Action e nil ������ Action
// � ������� �� ������� Redo ����������.
function TUndo.canRedo: Boolean;
begin
  if Active = nil then
    Result := not fSteps.isEmpty
  else
    Result := Active.Next <> nil;
end;

procedure TUndo.undo;
begin
  if not canUndo then
    exit;

  if Assigned(BeforeUndo) then
    fBeforeUndo(Self);

  fInOperation := True;
  try
    fActive.undo();
    fActive := fActive.Prev;
  finally
    fInOperation := False;
  end;

  if Assigned(AfterUndo) then
    fAfterUndo(Self);
end;

procedure TUndo.redo;
begin
  if not canRedo then
    exit;

  if Assigned(BeforeRedo) then
    fBeforeRedo(Self);

  fInOperation := True;
  try
    if (fActive = nil) then
      fActive := fSteps.First
    else
      fActive := Active.Next;

    fActive.Redo;
  finally
    fInOperation := False;
  end;

  if Assigned(AfterRedo) then
    fAfterRedo(Self);
end;

procedure TUndo.registerActions(aActions: TList<TUndoAction>);
var
  action: TUndoAction;
begin
  for action in aActions do begin
    append(action);
  end;
end;

procedure TUndo.append(aAction: TUndoAction);
begin
  if not fStep then begin
    startStep();
    // TODO - log if there is problem. Check software not to append without step
  end;

  fNewStep.Actions.Add(aAction);
end;

function TUndo.getCount: Integer;
begin
  Result := fSteps.Size;
end;

procedure TUndo.startStep;
begin
  endStep;
  fStep := True;
  fNewStep := TUndoStep.Create();
  if Assigned(fAfterStartStep) then
    fAfterStartStep(Self);
end;

procedure TUndo.startStep(aGroup: Integer);
begin
  endStep;
  fStep := True;
  fNewStep := TUndoStep.Create();
  fNewStep.GroupId := aGroup;
  if Assigned(fAfterStartStep) then
    fAfterStartStep(Self);
end;

procedure TUndo.endStep;
begin
  if not fStep then
    exit;

  if fNewStep.Actions.Count = 0 then begin
    fStep := False;
    freeAndNil(fNewStep);
    exit;
  end;

  removeAfterActive();
  fSteps.addAfter(fNewStep, fActive);
  fActive := fNewStep;
  fNewStep := nil;
  fStep := False;
  if assigned(OnEndStep) then
    fOnEndStep(Self);
end;

procedure TUndo.RemoveAfterActive;
var
  node, nextNode: TUndoStep;
begin
  if Active = nil then
    fSteps.clear
  else begin
    node := Active.Next;
    Active.Next := nil;
    while node <> nil do begin
      nextNode := node.Next;
      node.clearData();
      node.Free;
      node := nextNode;
    end;
  end;
end;

procedure TUndo.Clear;
begin
  fActive := nil;
  fSteps.clear();
end;

procedure TUndo.startOperation;
begin
  if (fCurrentOperation <> nil) then
    raise Exception.Create('Undo operation has not finished');
  fCurrentOperation := TUndoRedoOperation.Create();
end;

procedure TUndo.endOperation;
begin
  fOperations.Add(fCurrentOperation);
end;

procedure TUndo.registerObjectPropertyChange(aObject: TObject; aPropertyName: string; aOldValue: TObject; aNewValue: TObject; ownsData: Boolean);
var
  objectPropertyChange: TObjectPropertyChange;
begin
  objectPropertyChange := TObjectPropertyChange.Create(aObject, aPropertyName);
  objectPropertyChange.OldValue := aOldValue;
  objectPropertyChange.NewValue := aNewValue;
  objectPropertyChange.OwnsData := ownsData;
  Append(objectPropertyChange);
end;

procedure TUndo.registerIntegerPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Integer);
var
  undoAction: TIntegerPropertyChange;
begin
  undoAction := TIntegerPropertyChange.Create(aObject, aPropName);
  undoAction.OldValue := aOld;
  undoAction.NewValue := aNew;
  Append(undoAction);
end;

procedure TUndo.registerEnumPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Integer);
var
  action: TEnumPropertyChange;
begin
  action := TEnumPropertyChange.Create(aObject, aPropName);
  action.OldValue := aOld;
  action.NewValue := aNew;
  Append(action);
end;

procedure TUndo.registerDoublePropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Double);
var
  undoAction: TDoublePropertyChange;
begin
  undoAction := TDoublePropertyChange.Create(aObject, aPropName, aOld, aNew);
  Append(undoAction);
end;

procedure TUndo.registerDoublePropertyChange(aObject: TObject; aPropName: String);
var
  undoAction: TDoublePropertyChange2;
begin
  undoAction := TDoublePropertyChange2.Create(aObject, aPropName);
  Append(undoAction);
end;

procedure TUndo.registerCurrencyPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Double);
var
  undoAction: TCurrencyPropertyChange;
begin
  undoAction := TCurrencyPropertyChange.Create(aObject, aPropName, aOld, aNew);
  Append(undoAction);
end;

procedure TUndo.registerCurrencyPropertyChange2(aObject: TObject; aPropName: String);
var
  undoAction: TCurrencyPropertyChange2;
begin
  undoAction := TCurrencyPropertyChange2.Create(aObject, aPropName);
  Append(undoAction);
end;

procedure TUndo.registerBooleanPropertyChange(aObject: TObject;
  PropName: String; OldValue, NewValue: Boolean);
var
  undoAction: TBooleanPropertyChange;
begin
  undoAction := TBooleanPropertyChange.Create(aObject, PropName, OldValue, NewValue);
  Append(undoAction);
end;

procedure TUndo.registerListAppendUndo(aElement: TObject; aList: TList);
var
  vUndo: TListInsertChange;
begin
  vUndo := TListInsertChange.Create();
  vUndo.Element := aElement;
  vUndo.List := aList;
  vUndo.fIndex := aList.IndexOf(aElement);
  append(vUndo);
end;

procedure TUndo.registerListDeleteUndo(aElement: TObject; aList: TList);
var
  vUndo: TListRemoveChange;
begin
  vUndo := TListRemoveChange.Create();
  vUndo.Element := aElement;
  vUndo.List := aList;
  vUndo.fIndex := aList.IndexOf(aElement);
  append(vUndo);
end;

procedure TUndo.registerListGAppendUndo(aElement: TObject; aList: TList<TObject>);
var
  vUndo: TListGInsertChange;
begin
  vUndo := TListGInsertChange.Create();
  vUndo.Element := aElement;
  vUndo.List := aList;
  vUndo.fIndex := aList.IndexOf(aElement);
  append(vUndo);
end;

procedure TUndo.registerListGDeleteUndo(aElement: TObject; aList: TList<TObject>);
var
  vUndo: TListGRemoveChange;
begin
  vUndo := TListGRemoveChange.Create();
  vUndo.Element := aElement;
  vUndo.List := aList;
  vUndo.fIndex := aList.IndexOf(aElement);
  append(vUndo);
end;

{ TUndoStep }

constructor TUndoStep.Create;
begin
  fPrev := nil;
  fNext := nil;
  fActions := TList<TUndoAction>.Create;
  GroupId := -1;
end;

destructor TUndoStep.Destroy;
var
  action: TUndoAction;
begin
  while fActions.Count > 0 do begin
    action := fActions[0];
    fActions.Delete(0);
    action.Free;
  end;

  freeAndNil(fActions);
  inherited;
end;

procedure TUndoStep.clearData;
var
  action: TUndoAction;
begin
  for action in fActions do begin
    action.clearData();
  end;
end;

procedure TUndoStep.undo;
var
  i: Integer;
begin
  for i := fActions.Count - 1 downto 0 do begin
    fActions[i].undo();
  end;
end;

procedure TUndoStep.redo;
var
  action: TUndoAction;
begin
  for action in fActions do begin
    action.redo();
  end;
end;

end.


