# Lazarus Undo/Redo Framework

A simple yet powerful non-visual component for implementing undo and redo functionality in Lazarus and Free Pascal (FPC) applications. This framework allows developers to easily track changes to object properties and list manipulations, providing a robust undo/redo history.

It is designed to be extensible, allowing you to create custom change trackers for any data type or complex operation.

---

## ✨ Features

* **Standard Undo/Redo:** Provides core `Undo()` and `Redo()` capabilities.
* **Action Grouping:** Group multiple small changes (e.g., changing an object's position and size) into a single undoable action using `StartAction` and `EndAction`.
* **Property Tracking:** Built-in support for tracking changes to common property types:
    * `Integer` / `Enum`
    * `Double` / `Currency`
    * `Boolean`
    * `TObject` references
* **List Manipulation:** Natively registers adding or removing items from `TList` and generic `TList<TObject>`.
* **Event-Driven:** Provides events like `AfterUndo`, `AfterRedo`, and `AfterEndAction` to easily update the UI state (e.g., enabling/disabling buttons).
* **Extensible:** Create custom change handlers by inheriting from the `TUndoChange` base class to support any kind of operation.
* **No Visual Components:** Purely code-based, giving you full control over the UI implementation.

---

## 🚀 Getting Started

Here is a basic guide to integrating the Undo/Redo framework into your application.

### 1. Installation

Simply add the `UndoRedo.pas` unit and its dependencies to your project's uses clause.

### 2. Basic Usage

#### Step 1: Create an instance of TUndo

In your form or data module, declare and create an instance of the `TUndo` class. This will be your undo manager.

```pascal
uses
  ..., UndoRedo;

type
  TMyForm = class(TForm)
    // ... components
  private
    FUndoManager: TUndo;
  public
    // ...
  end;

procedure TMyForm.FormCreate(Sender: TObject);
begin
  FUndoManager := TUndo.Create;
end;

procedure TMyForm.FormDestroy(Sender: TObject);
begin
  FUndoManager.Free;
end;
```

#### Step 2: Register a Change

To register a change, you must provide the object, the property name, and its old and new values. The framework will automatically create an undo action.

For example, to track a change in a `TShape`'s `Brush.Color` property:

```pascal
procedure TMyForm.ChangeColorButtonClick(Sender: TObject);
var
  OldColor, NewColor: TColor;
begin
  OldColor := Shape1.Brush.Color;
  NewColor := clRed; // The new color

  if OldColor <> NewColor then
  begin
    // Register the change with the undo manager
    FUndoManager.RegisterIntegerPropertyChange(Shape1.Brush, 'Color', OldColor, NewColor);
    
    // Apply the change
    Shape1.Brush.Color := NewColor;
  end;
end;
```
**Note:** By default, `AutoStartAction` is `True`, so each registration is a separate undoable action.

#### Step 3: Grouping Multiple Changes

If you perform an operation that involves several property changes, you should group them into a single action.

```pascal
procedure TMyForm.MoveAndResizeButtonClick(Sender: TObject);
var
  OldLeft, OldWidth: Integer;
begin
  FUndoManager.StartAction; // Start grouping
  try
    // --- First Change: Position ---
    OldLeft := Shape1.Left;
    FUndoManager.RegisterIntegerPropertyChange(Shape1, 'Left', OldLeft, Shape1.Left + 20);
    Shape1.Left := Shape1.Left + 20;

    // --- Second Change: Size ---
    OldWidth := Shape1.Width;
    FUndoManager.RegisterIntegerPropertyChange(Shape1, 'Width', OldWidth, Shape1.Width - 10);
    Shape1.Width := Shape1.Width - 10;
  finally
    FUndoManager.EndAction; // End grouping. All changes are now one action.
  end;
end;
```

#### Step 4: Connecting to the UI

Connect the `Undo` and `Redo` methods to your menu items or toolbar buttons. Use the `CanUndo` and `CanRedo` functions to enable or disable them. A `TActionList` is perfect for this.

```pascal
// In a TActionList.OnUpdate event or similar UI update handler
procedure TMyForm.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  UndoAction.Enabled := FUndoManager.CanUndo;
  RedoAction.Enabled := FUndoManager.CanRedo;
end;

// OnExecute event for the Undo action
procedure TMyForm.UndoActionExecute(Sender: TObject);
begin
  FUndoManager.Undo;
end;

// OnExecute event for the Redo action
procedure TMyForm.RedoActionExecute(Sender: TObject);
begin
  FUndoManager.Redo;
end;
```

---

## 📚 API Overview

### Core Classes

* `TUndo`: The main manager class. It holds the history of actions and provides the public API for starting/ending actions, registering changes, and performing undo/redo.
* `TUndoAction`: Represents a single undoable/redoable action. It contains a list of one or more `TUndoChange` objects.
* `TUndoChange`: The abstract base class for a specific change (e.g., a property change, a list insertion). You can inherit from this to create your own custom change types.

### Key Methods in `TUndo`

* `Undo()`: Reverts the last action.
* `Redo()`: Re-applies the last undone action.
* `CanUndo(): Boolean`: Returns `True` if there is an action to undo.
* `CanRedo(): Boolean`: Returns `True` if there is an action to redo.
* `StartAction()`: Begins a new group of changes. All subsequent registrations will be part of this single action.
* `EndAction()`: Finalizes the current action group.
* `Clear()`: Clears the entire undo/redo history.
* `Register...Change(...)`: A family of methods to register changes for different data types (`Integer`, `Double`, `Object`, `List`, etc.).

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or have an idea for a new feature, please open an issue or submit a pull request.

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.