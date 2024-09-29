unit LinkedListAddChange;

interface

uses
  UndoRedoAction, LinkedList;

type

  TLinkedListAddChange = class(TUndoAction)
  public
    List: TLinkedList<TObject>;
    Node: TObject;
    procedure Undo; override;
    procedure Redo; override;
  end;

implementation

procedure TLinkedListAddChange.Undo;
begin
  List.remove(Node);
end;

procedure TLinkedListAddChange.Redo;
begin
  List.add(Node);
end;

end.
