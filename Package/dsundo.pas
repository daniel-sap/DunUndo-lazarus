{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit DSUndo;

{$warn 5023 off : no warning about unused units}
interface

uses
  CurrencyPropertyChange, CurrencyPropertyChange2, DoublePropertyChange, 
  DoublePropertyChange2, IntegerPropertyChange, LinkedListAddChange, 
  LinkedListRemoveChange, ListGInsertChange, ListGRemoveChange, 
  ListInsertChange, ListRemoveChange, MoveUndo, ObjectPropertyChange, 
  PropertyObjectDoubleChange, PropertyObjectObjectChange, UndoRedo, 
  UndoRedoAction, UndoRedoOperation, BooleanPropertyChange, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('DSUndo', @Register);
end.
