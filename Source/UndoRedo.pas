unit UndoRedo;

interface

uses
  Generics.Collections, Dun.UndoChange, UndoRedoOperation, Classes, Contnrs,
  DLinkedList;

type

  /// Represents a single, logical user operation that can be undone or redone.
  /// It holds list of changes which are the actual changes to a model
  TUndoAction = class
  private
    fPrev: TUndoAction;
    fNext: TUndoAction;
    fTag: Integer;
    fChanges: TList<TUndoChange>;
  public
    GroupId: Integer;
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure Undo();
    procedure Redo();
    procedure ClearData();
  public
    property Changes: TList<TUndoChange> read fChanges;
    property Tag: Integer read fTag write fTag;
  published
    property Prev: TUndoAction read fPrev write fPrev;
    property Next: TUndoAction read fNext write fNext;
  end;

  /// Main engine for managing the undo/redo.
  TUndo = class
  private
    fActive: TUndoAction;
    fAutoStartAction: Boolean;
    fInAction: Boolean;
    fInOperation: Boolean;

    fNewAction: TUndoAction;

    fOperations: TObjectList;
    fCurrentOperation: TUndoRedoOperation;

    fActions: TDLinkedList<TUndoAction>;
    fAfterUndo: TNotifyEvent;
    fBeforeUndo: TNotifyEvent;
    fAfterRedo: TNotifyEvent;
    fBeforeRedo: TNotifyEvent;
    fAfterEndAction: TNotifyEvent;
    fAfterStartAction: TNotifyEvent;
  protected
    function GetCount: Integer; virtual;
    procedure RemoveAfterActive();
    procedure DoBeforeUndo(); virtual;
    procedure DoAfterUndo(); virtual;
    procedure DoBeforeRedo(); virtual;
    procedure DoAfterRedo(); virtual;
    procedure DoAfterStartAction(); virtual;
    procedure DoAfterEndAction(); virtual;
  public
    constructor Create(); virtual;
    destructor Destroy; override;
    procedure Append(aChange: TUndoChange);
    procedure Undo();
    procedure Redo();
    function CanUndo(): Boolean;
    function CanRedo(): Boolean;
    procedure Clear();
    procedure StartAction(); overload;
    procedure StartAction(aGroup: Integer); overload;
    procedure EndAction();
  public
    procedure RegisterChanges(aChanges: TList<TUndoChange>);
    procedure RegisterObjectPropertyChange(aObject: TObject; aPropertyName: string; aOldValue: TObject; aNewValue: TObject; ownsData: Boolean = False);
    procedure RegisterIntegerPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Integer);
    procedure RegisterEnumPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Integer);
    procedure RegisterDoublePropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Double); overload;
    procedure RegisterDoublePropertyChange(aObject: TObject; aPropName: String); overload;
    procedure RegisterCurrencyPropertyChange(aObject: TObject; aPropName: String; aOld, aNew: Double);
    procedure RegisterCurrencyPropertyChange2(aObject: TObject; aPropName: String);
    procedure RegisterBooleanPropertyChange(aObject: TObject; PropName: String; OldValue, NewValue: Boolean);
    procedure RegisterListAppendUndo(aElement: TObject; aList: TList);
    procedure RegisterListDeleteUndo(aElement: TObject; aList: TList);
    procedure RegisterListGAppendUndo(aElement: TObject; aList: TList<TObject>);
    procedure RegisterListGDeleteUndo(aElement: TObject; aList: TList<TObject>);
  public
    property Active: TUndoAction read fActive;
    property Count: Integer read getCount;
    property InOperation: Boolean read fInOperation;
    property InAction: Boolean read fInAction;
    property Actions: TDLinkedList<TUndoAction> read fActions;
  public
    procedure StartOperation;
    procedure EndOperation;
  public
    property NewAction: TUndoAction read fNewAction;
    property AutoStartAction: Boolean read fAutoStartAction write fAutoStartAction;
    property BeforeUndo: TNotifyEvent read fBeforeUndo write fBeforeUndo;
    property AfterUndo: TNotifyEvent read fAfterUndo write fAfterUndo;
    property BeforeRedo: TNotifyEvent read fBeforeRedo write fBeforeRedo;
    property AfterRedo: TNotifyEvent read fAfterRedo write fAfterRedo;
    property AfterStartAction: TNotifyEvent read fAfterStartAction write fAfterStartAction;
    property AfterEndAction: TNotifyEvent read fAfterEndAction write fAfterEndAction;
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
  fActions := TDLinkedList<TUndoAction>.Create();

  fActive := nil;
  fAutoStartAction := True;
  fNewAction := nil;
  fInAction := False;
  fInOperation := False;
end;

destructor TUndo.Destroy;
begin
  FreeAndNil(fOperations);
  FreeAndNil(fActions);
  inherited Destroy;
end;

function TUndo.CanUndo: Boolean;
begin
  Result := Active <> nil;
end;

function TUndo.CanRedo: Boolean;
begin
  if Active = nil then
    Result := not fActions.isEmpty
  else
    Result := Active.Next <> nil;
end;

procedure TUndo.Undo;
begin
  if not CanUndo then
    Exit;

  DoBeforeUndo();

  fInOperation := True;
  try
    fActive.Undo();
    fActive := fActive.Prev;
  finally
    fInOperation := False;
  end;

  DoAfterUndo();
end;

procedure TUndo.Redo;
begin
  if not CanRedo then
    Exit;

  DoBeforeRedo();

  fInOperation := True;
  try
    if (fActive = nil) then
      fActive := fActions.First
    else
      fActive := Active.Next;

    fActive.Redo;
  finally
    fInOperation := False;
  end;

  DoAfterRedo();
end;

procedure TUndo.RegisterChanges(aChanges: TList<TUndoChange>);
var
  Change: TUndoChange;
begin
  for Change in aChanges do begin
    Append(Change);
  end;
end;

procedure TUndo.Append(aChange: TUndoChange);
begin
  if not InAction then begin
    if AutoStartAction then
      StartAction()
    else
      raise Exception.Create('No active Undo Action');
  end;

  fNewAction.Changes.Add(aChange);
end;

function TUndo.GetCount: Integer;
begin
  Result := fActions.Size;
end;

procedure TUndo.StartAction;
begin
  EndAction();
  fInAction := True;
  fNewAction := TUndoAction.Create();
  DoAfterStartAction();
end;

procedure TUndo.StartAction(aGroup: Integer);
begin
  EndAction();
  fInAction := True;
  fNewAction := TUndoAction.Create();
  fNewAction.GroupId := aGroup;
  DoAfterStartAction();
end;

procedure TUndo.EndAction;
begin
  if not fInAction then
    Exit;

  if fNewAction.Changes.Count = 0 then begin
    fInAction := False;
    FreeAndNil(fNewAction);
    Exit;
  end;

  RemoveAfterActive();
  fActions.addAfter(fNewAction, fActive);
  fActive := fNewAction;
  fNewAction := nil;
  fInAction := False;
  DoAfterEndAction();
end;

procedure TUndo.RemoveAfterActive;
var
  Node, NextNode: TUndoAction;
begin
  if Active = nil then
    fActions.Clear
  else begin
    Node := Active.Next;
    Active.Next := nil;
    while Node <> nil do begin
      NextNode := Node.Next;
      Node.ClearData();
      Node.Free;
      Node := NextNode;
    end;
  end;
end;

procedure TUndo.DoBeforeUndo();
begin
  if Assigned(fBeforeUndo) then
    fBeforeUndo(Self);
end;

procedure TUndo.DoAfterUndo();
begin
  if Assigned(fAfterUndo) then
    fAfterUndo(Self);
end;

procedure TUndo.DoBeforeRedo();
begin
  if Assigned(fBeforeRedo) then
    fBeforeRedo(Self);
end;

procedure TUndo.DoAfterRedo();
begin
  if Assigned(fAfterRedo) then
    fAfterRedo(Self);
end;

procedure TUndo.DoAfterStartAction();
begin
  if Assigned(fAfterStartAction) then
    fAfterStartAction(Self);
end;

procedure TUndo.DoAfterEndAction();
begin
  if Assigned(fAfterEndAction) then
    fAfterEndAction(Self);
end;

procedure TUndo.Clear;
begin
  fActive := nil;
  fActions.Clear();
end;

procedure TUndo.StartOperation;
begin
  if (fCurrentOperation <> nil) then
    raise Exception.Create('Undo operation has not finished');
  fCurrentOperation := TUndoRedoOperation.Create();
end;

procedure TUndo.EndOperation;
begin
  fOperations.Add(fCurrentOperation);
end;

procedure TUndo.RegisterObjectPropertyChange(aObject: TObject; aPropertyName: string; aOldValue: TObject; aNewValue: TObject; ownsData: Boolean);
var
  Change: TObjectPropertyChange;
begin
  Change := TObjectPropertyChange.Create(aObject, aPropertyName);
  Change.OldValue := aOldValue;
  Change.NewValue := aNewValue;
  Change.OwnsData := ownsData;
  Append(Change);
end;

procedure TUndo.RegisterIntegerPropertyChange(aObject: TObject;
  aPropName: String; aOld, aNew: Integer);
var
  Change: TIntegerPropertyChange;
begin
  Change := TIntegerPropertyChange.Create(aObject, aPropName);
  Change.OldValue := aOld;
  Change.NewValue := aNew;
  Append(Change);
end;

procedure TUndo.RegisterEnumPropertyChange(aObject: TObject; aPropName: String;
  aOld, aNew: Integer);
var
  Change: TEnumPropertyChange;
begin
  Change := TEnumPropertyChange.Create(aObject, aPropName);
  Change.OldValue := aOld;
  Change.NewValue := aNew;
  Append(Change);
end;

procedure TUndo.RegisterDoublePropertyChange(aObject: TObject;
  aPropName: String; aOld, aNew: Double);
var
  Change: TDoublePropertyChange;
begin
  Change := TDoublePropertyChange.Create(aObject, aPropName, aOld, aNew);
  Append(Change);
end;

procedure TUndo.RegisterDoublePropertyChange(aObject: TObject; aPropName: String);
var
  Change: TDoublePropertyChange2;
begin
  Change := TDoublePropertyChange2.Create(aObject, aPropName);
  Append(Change);
end;

procedure TUndo.RegisterCurrencyPropertyChange(aObject: TObject;
  aPropName: String; aOld, aNew: Double);
var
  Change: TCurrencyPropertyChange;
begin
  Change := TCurrencyPropertyChange.Create(aObject, aPropName, aOld, aNew);
  Append(Change);
end;

procedure TUndo.RegisterCurrencyPropertyChange2(aObject: TObject;
  aPropName: String);
var
  Change: TCurrencyPropertyChange2;
begin
  Change := TCurrencyPropertyChange2.Create(aObject, aPropName);
  Append(Change);
end;

procedure TUndo.RegisterBooleanPropertyChange(aObject: TObject;
  PropName: String; OldValue, NewValue: Boolean);
var
  Change: TBooleanPropertyChange;
begin
  Change := TBooleanPropertyChange.Create(aObject, PropName, OldValue, NewValue);
  Append(Change);
end;

procedure TUndo.RegisterListAppendUndo(aElement: TObject; aList: TList);
var
  Change: TListInsertChange;
begin
  Change := TListInsertChange.Create();
  Change.Element := aElement;
  Change.List := aList;
  Change.fIndex := aList.IndexOf(aElement);
  Append(Change);
end;

procedure TUndo.RegisterListDeleteUndo(aElement: TObject; aList: TList);
var
  Change: TListRemoveChange;
begin
  Change := TListRemoveChange.Create();
  Change.Element := aElement;
  Change.List := aList;
  Change.fIndex := aList.IndexOf(aElement);
  Append(Change);
end;

procedure TUndo.RegisterListGAppendUndo(aElement: TObject; aList: TList<TObject>);
var
  Change: TListGInsertChange;
begin
  Change := TListGInsertChange.Create();
  Change.Element := aElement;
  Change.List := aList;
  Change.fIndex := aList.IndexOf(aElement);
  Append(Change);
end;

procedure TUndo.RegisterListGDeleteUndo(aElement: TObject; aList: TList<TObject>);
var
  Change: TListGRemoveChange;
begin
  Change := TListGRemoveChange.Create();
  Change.Element := aElement;
  Change.List := aList;
  Change.fIndex := aList.IndexOf(aElement);
  Append(Change);
end;

{ TUndoAction }

constructor TUndoAction.Create;
begin
  fPrev := nil;
  fNext := nil;
  fChanges := TList<TUndoChange>.Create;
  GroupId := -1;
end;

destructor TUndoAction.Destroy;
var
  Change: TUndoChange;
begin
  while fChanges.Count > 0 do begin
    Change := fChanges[0];
    fChanges.Delete(0);
    Change.Free;
  end;

  FreeAndNil(fChanges);
  inherited;
end;

procedure TUndoAction.clearData;
var
  Change: TUndoChange;
begin
  for Change in fChanges do begin
    Change.clearData();
  end;
end;

procedure TUndoAction.Undo;
var
  i: Integer;
begin
  for i := fChanges.Count - 1 downto 0 do begin
    fChanges[i].Undo();
  end;
end;

procedure TUndoAction.Redo;
var
  Change: TUndoChange;
begin
  for Change in fChanges do begin
    Change.Redo();
  end;
end;

end.


