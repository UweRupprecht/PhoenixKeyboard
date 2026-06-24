unit phk.command;
(*
    Types/Classes used on execution of a hotkey
*)
interface
uses
  winapi.Windows,
  winapi.Messages,
  System.Classes,
  System.Generics.Collections,
  phk.general;

Type
  //Kind of Command to use on a hotkey
  TPhkCommandType = (ctEvent,ctAction,ctMessage);
  //As multiple types can be triggert on Hotkey
  TPhkCommandTypes = Set of TPhkCommandType;
  //Eventtype
  TPhkCommandEvent = Procedure (Sender : TObject) of object;
  TPHKCustomData = Pointer;
  //Just a command that should be execute
  TPhkCommand = Class(TPersistent)
  private
      findex : integer;
      fTypes : TPHKCommandTypes;
      fOnCmd : TPhkCommandEvent;
      fAction : TBasicAction;
      fTarget : HWND;
      fcdSize : DWord;
      fCustomData : TPHKCustomData;
  protected
      function GetCommandType(index:TPHKCommandType):boolean;
      Procedure SetCommandType(index:TPHKCommandType;value:boolean);

  public
     Constructor Create;
     Destructor Destroy;override;
     Procedure Assign(source:TPersistent);
     Procedure Execute;
     Procedure SetCustomData(data:pointer;Size:Dword);

     Property CustomData : TPHKCustomData read fCustomData;
  published
     Property ListIndex : integer read findex;
     Property CommandEvent : boolean index ctEvent read GetCommandType write SetCommandType;
     Property CommandAction : boolean index ctAction read GetCommandType write SetCommandType;
     Property CommandMessage: boolean index ctMessage read GetCommandType write SetCommandType;

     Property OnCommand : TPHKCommandEvent read fonCmd write fonCmd;
     Property Action : TBasicAction read fAction write fAction;
     Property TargetHandle : HWND read ftarget write ftarget;
  End;

  //Used for further developement;
  TPHKCommands = Class
  private
    fitems : TObjectList<TPHKCommand>;
  protected
    function GetItem(index:integer):TPHKCommand;
  public
    constructor Create;
    Destructor Destroy;override;

    function Add:integer;
    Procedure Delete(index:integer);
    function Count:integer;
    Procedure Execute(Index:integer);
    Procedure ExecuteAll;

    function GetEnumerator:TEnumerator<TPHKCommand>;

    Property Items[index:integer]:TPHKCommand read GetItem;
  End;

implementation

{ TPhkCommand }

procedure TPhkCommand.Assign(source: TPersistent);
begin
  if (source is TPhkCommand) then
  begin
    self.findex := TPhkCommand(source).findex;
    self.fTypes := TPhkCommand(source).fTypes;
    self.fOnCmd := TPhkCommand(source).fOnCmd;
    self.fAction := TPhkCommand(source).fAction;
    self.fTarget := TPhkCommand(Source).fTarget;
    self.fCustomData := TPhkCommand(source).fCustomData;
  end;
end;

constructor TPhkCommand.Create;
begin
  inherited;
  findex := -1;
  ftypes := [];
  foncmd := NIL;
  faction := NIL;
end;

destructor TPhkCommand.Destroy;
begin
  inherited;
end;

procedure TPhkCommand.Execute;
begin
  if (ctEvent in ftypes) and (Assigned(fonCmd)) then
    fonCmd(self);
  if (ctAction in Ftypes) and (assigned(faction)) then
    faction.Execute;
  if (ctMessage in ftypes) and (ftarget <> 0) then
    SendMessage(ftarget,WM_PHKHOTKEY,fcdSize,Cardinal(fcustomdata));
end;

function TPhkCommand.GetCommandType(index: TPHKCommandType): boolean;
begin
  result := (index in ftypes);
end;

procedure TPhkCommand.SetCommandType(index: TPHKCommandType; value: boolean);
begin
  if (value) then
    include(ftypes,index)
  else
    exclude(ftypes,index);
end;

procedure TPhkCommand.SetCustomData(data:pointer; Size: Dword);
begin
  fCustomData := data;
  fcdSize := size;
end;

{ TPHKCommands }

function TPHKCommands.Add: integer;
begin
  result := fitems.Add(TPHKCommand.create);
  fitems[result].findex := result;
end;

function TPHKCommands.Count: integer;
begin
  result := fitems.count;
end;

constructor TPHKCommands.Create;
begin
  inherited;
  fitems := TObjectlist<TPHKCommand>.create(true);
end;

procedure TPHKCommands.Delete(index: integer);
begin
  fitems.Delete(index);
end;

destructor TPHKCommands.Destroy;
begin
  fitems.clear;
  fitems.free;
  inherited;
end;

procedure TPHKCommands.Execute(Index: integer);
begin
  if (Index >= 0) and (index < fitems.count) then
    fitems[index].Execute;
end;

procedure TPHKCommands.ExecuteAll;
var
  i : integer;
begin
  for I := 0 to fitems.count-1 do
    fitems[i].Execute;
end;

function TPHKCommands.GetEnumerator: TEnumerator<TPHKCommand>;
begin
  result := fitems.GetEnumerator;
end;

function TPHKCommands.GetItem(index: integer): TPHKCommand;
begin
  result := NIL;
  if (index >= 0) and (index < fitems.count) then
    result := fitems[index];
end;

end.
