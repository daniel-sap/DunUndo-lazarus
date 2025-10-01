unit ListGRemoveChange;

interface

uses
  Dun.UndoChange, ObserverObjects, Generics.Collections;

type
  TListGRemoveChange = class(TUndoChange)
  private
    fElement: TObject;
    fList: TList<TObject>;
  public
    fIndex: Integer;
    constructor Create(); override;
    destructor Destroy; override;

    procedure Undo; override;
    procedure Redo; override;

    property Element: TObject read fElement write fElement;
    property List: TList<TObject> read fList write fList;
  end;

implementation

uses
  SysUtils;

constructor TListGRemoveChange.Create();
begin
  inherited Create();
  fElement := nil;
end;

destructor TListGRemoveChange.Destroy;
begin
  inherited Destroy;
end;

procedure TListGRemoveChange.Undo;
begin
  List.Insert(fIndex, fElement);
end;

procedure TListGRemoveChange.Redo;
begin
  List.remove(fElement);
end;

end.
