unit ListInsertChange;

interface

uses
  Dun.UndoChange, ObserverObjects, Classes;

type

  TListInsertChange = class(TUndoChange)
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

constructor TListInsertChange.Create();
begin
  inherited Create();
  fElement := nil;
end;

destructor TListInsertChange.Destroy;
begin
  inherited Destroy;
end;

procedure TListInsertChange.Undo;
begin
  List.remove(fElement);
end;

procedure TListInsertChange.Redo;
begin
  List.Insert(fIndex, fElement);
end;

end.
