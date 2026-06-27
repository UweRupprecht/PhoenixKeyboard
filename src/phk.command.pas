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
  TNotifyCommand = Procedure (Sender : TObject) of object;

  //Baseclass for commands
  TBasicCommand = Class(TPersistent)
  private
     fCid : Integer; //Id for identification within a list
  public
     Constructor Create(AId:Integer);
     Destructor Destroy;override;
     Procedure Assign(source:TPersistent);override;
     Procedure Execute;virtual;abstract;
     function TypeOf:TCommandType;virtual;abstract;
  published
     Property CID   : integer read fcid;
  End;

  TEventCommand = Class(TBasicCommand)
  private
      fonExecute : TNotifyCommand;
  public
      Procedure Assign(Source:TPersistent);override;
      Procedure Execute;override;
      Destructor Destroy;override;
      function TypeOf:TCommandType;override;
  published
     Property onExecute : TNotifyCommand read fonExecute Write fonExecute;
  End;

  TActionCommand = Class(TBasicCommand)
  private
    faction : TBasicAction;
  public
    Procedure Assign(source:TPersistent);override;
    Procedure Execute;override;
    function TypeOf:TCommandType;override;
    destructor Destroy;override;
  published
    Property Action : TBasicAction read faction write faction;
  End;

  TMessageCommand = Class(TBasicCommand)
  private
      fTarget : HWND;
  public
    Procedure Assign(source:TPersistent);override;
    Procedure Execute;override;
    function Typeof:TCommandType;override;
    destructor Destroy;override;
  published
    Property TargetWindow:HWND read fTarget write fTarget;
  End;

  //List of Commands
  TCommands = Class
  private
     fcmds : TObjectlist<TBasicCommand>;
  protected
     function GetCommand(Index:integer):TBasicCommand;
  public
    constructor Create;
    Destructor Destroy;override;

    //Listhandling
    function AddEventCommand(proc:TNotifyCommand):integer;
    function AddActionCommand(Act:TBasicAction):integer;
    function AddMessageCommand(Window:HWND):integer;
    Procedure DeleteCommand(Index:integer);
    function Count:integer;
    Procedure Execute(index:integer);
    Procedure ExecuteAll;
    //Enumerator
    function GetEnumerator:TEnumerator<TBasicCommand>;

    Property Commands[index:integer] : TBasicCommand read GetCommand;default;
  End;


implementation

{ TBasicCommand }

procedure TBasicCommand.Assign(source: TPersistent);
begin
  if source is TBasicCommand then
    fcid := TBasicCommand(source).fCid;
end;

constructor TBasicCommand.Create(AId: Integer);
begin
  inherited Create;
  fcid := AId;
end;

destructor TBasicCommand.Destroy;
begin
  inherited;
end;

{ TEventCommand }

procedure TEventCommand.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TEventCommand then
    fonExecute := TEventCommand(Source).fonExecute;
end;

destructor TEventCommand.Destroy;
begin
  fonExecute := NIL;
  inherited;
end;

procedure TEventCommand.Execute;
begin
  if assigned(fonExecute) then
    fonExecute(self);
end;

function TEventCommand.TypeOf: TCommandType;
begin
  result := ctEvent;
end;

{ TActionCommand }

procedure TActionCommand.Assign(source: TPersistent);
begin
  inherited;
  if (source is TActionCommand) then
    faction := TActionCommand(source).faction;
end;

destructor TActionCommand.Destroy;
begin
  faction := NIL;
  inherited;
end;

procedure TActionCommand.Execute;
begin
  if assigned(faction) then
    faction.Execute;
end;

function TActionCommand.TypeOf: TCommandType;
begin
  result := ctAction;
end;

{ TMessageCommand }

procedure TMessageCommand.Assign(source: TPersistent);
begin
  inherited;
  if (source is TMessageCommand) then
    fTarget := TMessageCommand(source).fTarget;
end;

destructor TMessageCommand.Destroy;
begin
  ftarget := 0;
  inherited;
end;

procedure TMessageCommand.Execute;
begin
  if (ftarget <> 0) then
     SendMessage(ftarget,WM_PHKHOTKEY,0,0);
end;

function TMessageCommand.Typeof: TCommandType;
begin
  result := ctMessage;
end;

{ TCommands }

function TCommands.AddActionCommand(Act: TBasicAction): integer;
begin
  result := fcmds.Add(nil);
  fcmds[result] := TActionCommand.create(result);
  TActioncommand(fcmds[result]).faction := Act;
end;

function TCommands.AddEventCommand(proc: TNotifyCommand): integer;
begin
  result := fcmds.Add(nil);
  fcmds[result] := TEventCommand.create(result);
  TEventCommand(fcmds[result]).fonExecute := proc;
end;

function TCommands.AddMessageCommand(Window: HWND): integer;
begin
  result := fcmds.Add(nil);
  fcmds[result] := TMessageCommand.create(result);
  TMessageCommand(fcmds[result]).fTarget := Window;
end;

function TCommands.Count: integer;
begin
  result := fcmds.count;
end;

constructor TCommands.Create;
begin
  inherited;
  fcmds := TObjectList<TBasicCommand>.create(true);
end;

procedure TCommands.DeleteCommand(Index: integer);
begin
  if (Index >= 0) and (index < fcmds.count) then
    fcmds.Delete(index);
end;

destructor TCommands.Destroy;
begin
  fcmds.free;
  inherited;
end;

procedure TCommands.Execute(index: integer);
begin
  if (index >= 0) and (index < fcmds.count) then
    fcmds[index].Execute;
end;

procedure TCommands.ExecuteAll;
var
  i : integer;
begin
  for I := 0 to fcmds.count-1 do
    fcmds[i].Execute;
end;

function TCommands.GetCommand(Index: integer): TBasicCommand;
begin
  result := NIL;
  if (index >= 0) and (index < fcmds.count) then
    result := fcmds[index];
end;

function TCommands.GetEnumerator: TEnumerator<TBasicCommand>;
begin
  result := fcmds.GetEnumerator;
end;

end.
