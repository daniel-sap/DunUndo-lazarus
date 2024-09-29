unit MoveUndo;

interface

uses
  UndoRedoAction, ObserverObjects, ModelObjectList;

type

  TUnReDoElementMove = class(TUndoAction)
  private
    fList: TModelObjectList<TSubjectObject>;
    fOldIndex: Integer;
    fNewIndex: Integer;
  public
    procedure Undo; override;
    procedure Redo; override;
    procedure Hold(aList: TModelObjectList<TSubjectObject>; aOldIndex, aNewIndex: Integer);
  end;

implementation

procedure TUnReDoElementMove.Hold(aList: TModelObjectList<TSubjectObject>;
  aOldIndex, aNewIndex: Integer);
begin
  fList := aList;
  fNewIndex := aNewIndex;
  fOldIndex := aOldIndex;
end;

procedure TUnReDoElementMove.Undo;
begin
  fList.Move(fNewIndex, fOldIndex);
end;

procedure TUnReDoElementMove.Redo;
begin
  fList.Move(fOldIndex, fNewIndex);
end;

end.
