unit ListGInsertChange;

interface

uses
  Dun.UndoChange, ObserverObjects, Generics.Collections;

type
  TListGInsertChange = class(TUndoChange)
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

constructor TListGInsertChange.Create();
begin
  inherited Create();
  fElement := nil;
end;

destructor TListGInsertChange.Destroy;
begin
  inherited Destroy;
end;

procedure TListGInsertChange.Undo;
begin
  List.remove(fElement);
end;

procedure TListGInsertChange.Redo;
begin
  List.Insert(fIndex, fElement);
end;

end.
