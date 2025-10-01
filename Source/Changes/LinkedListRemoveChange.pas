unit LinkedListRemoveChange;

interface

uses
  Dun.UndoChange, LinkedList;

type

  TLinkedListRemoveChange = class(TUndoChange)
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
