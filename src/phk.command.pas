unit phk.command;
(*
   Defines types and classes for handling commands

   a command defines the action(s) that should be executed
   when a hotkey is triggert

   There are 3 Commandtypes, that can be used by
   the developer, to handle a hotkey:

   - Event: CommandEvent is set to true;onCommand is set to a proper eventhandler
   - Action: CommandAction is set to true;Action is set to a proper Action (TBasicAction)
   - Message: CommandMessage is set to true; Targethandle is set to a proper Windowhandle

   Customdata can be forwarded only on Event and Message.

   For each hotkey there is a list of Commands, that can be defined and triggert
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
  TCommandType = (ctEvent,ctAction,ctMessage);
  //As multiple types can be triggert on Hotkey
  TCommandTypes = Set of TCommandType;
  //Eventtype
  TCommandEvent = Procedure (Sender : TObject;CustomData:TCustomData) of object;

  //Basic command class, that deals with a single command
  TCommand = Class(TPersistent)
  private
      findex : integer;
      fTypes : TCommandTypes;
      fOnCmd : TCommandEvent;
      fAction : TBasicAction;
      fTarget : HWND;
      fcdSize : DWord;
      fCustomData : TCustomData;
  protected
      function GetCommandType(index:TCommandType):boolean;
      Procedure SetCommandType(index:TCommandType;value:boolean);
  public
     Constructor Create;
     Destructor Destroy;override;
     Procedure Assign(source:TPersistent);
     Procedure Execute(Data:TCustomData=NIL;Size:DWord=0);
     Procedure SetCustomData(data:pointer;Size:Dword);

     Property CustomData : TCustomData read fCustomData;
  published
     Property ListIndex : integer read findex;
     Property CommandEvent : boolean index ctEvent read GetCommandType write SetCommandType;
     Property CommandAction : boolean index ctAction read GetCommandType write SetCommandType;
     Property CommandMessage: boolean index ctMessage read GetCommandType write SetCommandType;

     Property OnCommand : TCommandEvent read fonCmd write fonCmd;
     Property Action : TBasicAction read fAction write fAction;
     Property TargetHandle : HWND read ftarget write ftarget;
  End;

  //List of commands, that should be executed on a hotkey
  TCommands = Class
  private
    fcmd : TObjectList<TCommand>;
  protected
    function GetItem(index:integer):TCommand;
  public
    constructor Create;
    Destructor Destroy;override;
    //function for dealing with the list
    function Add:integer;
    Procedure Delete(index:integer);
    function Count:integer;
    //execute a single command within the list
    Procedure Execute(Index:integer;CustomData:TCustomData=NIL;DataSize:DWord=0);
    //Execute all commands within the list
    Procedure ExecuteAll(CustomData:TCustomData=NIL;datasize:DWord=0);

    function GetEnumerator:TEnumerator<TCommand>;

    Property cmd[index:integer]:TCommand read GetItem;
  End;

implementation

{ TPhkCommand }

procedure TCommand.Assign(source: TPersistent);
begin
  if (source is TCommand) then
  begin
    self.findex := TCommand(source).findex;
    self.fTypes := TCommand(source).fTypes;
    self.fOnCmd := TCommand(source).fOnCmd;
    self.fAction := TCommand(source).fAction;
    self.fTarget := TCommand(Source).fTarget;
    self.fCustomData := TCommand(source).fCustomData;
  end;
end;

constructor TCommand.Create;
begin
  inherited;
  findex := -1;
  ftypes := [];
  foncmd := NIL;
  faction := NIL;
  fCustomdata := NIL;
end;

destructor TCommand.Destroy;
begin
  inherited;
end;

procedure TCommand.Execute(Data:TCustomData=NIL;Size:DWord=0);
begin
  if Data <> NIL then
    SetCustomData(data,size);
  if (ctEvent in ftypes) and (Assigned(fonCmd)) then
    fonCmd(self,fcustomdata);
  if (ctAction in Ftypes) and (assigned(faction)) then
    faction.Execute;
  if (ctMessage in ftypes) and (ftarget <> 0) then
    SendMessage(ftarget,WM_PHKHOTKEY,fcdSize,Cardinal(fcustomdata));
end;

function TCommand.GetCommandType(index: TCommandType): boolean;
begin
  result := (index in ftypes);
end;

procedure TCommand.SetCommandType(index: TCommandType; value: boolean);
begin
  if (value) then
    include(ftypes,index)
  else
    exclude(ftypes,index);
end;

procedure TCommand.SetCustomData(data:pointer; Size: Dword);
begin
  fCustomData := data;
  fcdSize := size;
end;

{ TPHKCommands }

function TCommands.Add: integer;
begin
  result := fcmd.Add(TCommand.create);
  fcmd[result].findex := result;
end;

function TCommands.Count: integer;
begin
  result := fcmd.count;
end;

constructor TCommands.Create;
begin
  inherited;
  fcmd := TObjectlist<TCommand>.create(true);
end;

procedure TCommands.Delete(index: integer);
begin
  fcmd.Delete(index);
end;

destructor TCommands.Destroy;
begin
  fcmd.free;
  inherited;
end;

procedure TCommands.Execute(Index:integer;CustomData:TCustomData=NIL;DataSize:DWord=0);
begin
  if (Index >= 0) and (index < fcmd.count) then
    fcmd[index].Execute(CustomData,datasize);
end;

procedure TCommands.ExecuteAll(CustomData:TCustomData=NIL;datasize:DWord=0);
var
  i : integer;
begin
  for I := 0 to fcmd.count-1 do
    fcmd[i].Execute(CustomData,datasize);
end;

function TCommands.GetEnumerator: TEnumerator<TCommand>;
begin
  result := fcmd.GetEnumerator;
end;

function TCommands.GetItem(index: integer): TCommand;
begin
  result := NIL;
  if (index >= 0) and (index < fcmd.count) then
    result := fcmd[index];
end;

end.
