program DSUndoTest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GUITestRunner, UndoRedoTest;

{$R *.res}

begin
  Application.Initialize;
  RunRegisteredTests;
end.

