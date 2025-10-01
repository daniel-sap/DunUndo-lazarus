unit ListRemoveChange;

interface

uses
  Dun.UndoChange, ObserverObjects, Classes;

type
  TListRemoveChange = class(TUndoChange)
  private
    fElement: TObject;
    fList: TList;
  public
    fIndex: Integer;
    constructor Create(); override;
    destructor Destroy; override;

    procedure Undo; override;
    procedure Redo; override;

    property Element: TObject read fElement write fElement;
    property List: TList read fList write fList;
  end;

implementation

uses
  SysUtils;

constructor TListRemoveChange.Create();
begin
  inherited Create();
  fElement := nil;
end;

destructor TListRemoveChange.Destroy;
begin
  inherited Destroy;
end;

procedure TListRemoveChange.Undo;
begin
  List.Insert(fIndex, fElement);
end;

procedure TListRemoveChange.Redo;
begin
  List.remove(fElement);
end;

end.
