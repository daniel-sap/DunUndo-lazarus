unit UndoRedoTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, TestFramework, UndoRedo;

type

  { TUndoRedoTest }

  TUndoRedoTest= class(TTestCase)
  private
    fUndo: TUndo;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    // canUndo
    procedure test_canUndo_afterCreate();
    procedure test_canUndo_afterAddingStep();
    procedure test_canUndo_afterLastUndo();
    // canRedo
    procedure test_canRedo_afterCreate();
    procedure test_canRedo_afterAddingStep();
  end;

implementation

uses
  SysUtils, UndoRedoAction, ListInsertChange;

procedure TUndoRedoTest.test_canUndo_afterCreate;
var
  resultValue: Boolean;
begin
  resultValue := fUndo.canUndo();

  CheckFalse(resultValue, 'Cannot return True after the Undo is created');
end;

procedure TUndoRedoTest.test_canUndo_afterAddingStep();
var
  action: TUndoAction;
  resultValue: Boolean;
begin
  action := TUndoAction.Create();

  fUndo.startStep(1);
  fUndo.append(action);
  fUndo.endStep();

  resultValue := fUndo.canUndo();

  CheckTrue(resultValue, 'Cannot return False after a step is appended');

end;

procedure TUndoRedoTest.test_canUndo_afterLastUndo();
var
  resultValue: Boolean;
  element: TObject;
  list: TList;
begin
  element := TObject.Create();
  list := TList.Create;
  list.Add(element);

  fUndo.startStep(1);
  fUndo.registerListAppendUndo(element, list);
  fUndo.endStep();
  fUndo.undo();

  resultValue := fUndo.canUndo();

  CheckFalse(resultValue, 'After last undo canRedo must return false');

end;

procedure TUndoRedoTest.test_canRedo_afterCreate();
var
  resultValue: Boolean;
begin
  resultValue := fUndo.canRedo();

  CheckFalse(resultValue, 'Cannot return True after the Undo is created');
end;

procedure TUndoRedoTest.test_canRedo_afterAddingStep();
var
  action: TUndoAction;
  resultValue: Boolean;
begin
  action := TUndoAction.Create();

  fUndo.startStep(1);
  fUndo.append(action);
  fUndo.endStep();

  resultValue := fUndo.canRedo();

  CheckFalse(resultValue, 'Cannot return True after a step is appended');

end;

procedure TUndoRedoTest.SetUp;
begin
  fUndo := TUndo.Create();
end;

procedure TUndoRedoTest.TearDown;
begin
  freeAndNil(fUndo);
end;

initialization
  RegisterTest(TUndoRedoTest.Suite);
end.

