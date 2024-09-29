unit LinkedListRemoveChange;

interface

uses
  UndoRedoAction, LinkedList;

type

  TLinkedListRemoveChange = class(TUndoAction)
  public
    List: TLinkedList<TObject>;
    Node: TObject;
    procedure Undo; override;
    procedure Redo; override;
  end;

implementation

procedure TLinkedListRemoveChange.Undo;
begin
  List.add(Node);
end;

procedure TLinkedListRemoveChange.Redo;
begin
  List.remove(Node);
end;

end.
