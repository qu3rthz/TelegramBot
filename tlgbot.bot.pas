unit TlgBot.Bot;

{Define el bot que vamos a usar y permite comprobar la conexión
Propiedades:
  Token: El token con el que nos vamos a conectar (rw)
Funciones:
  CheckBot: Intenta conectarse al bot y ejecutar el comango getMe
    IN:   ---
    OUT:  true si se ejecuta con éxito el getMe, false en caso contrario
          Si se ejecuta con éxito, entonces:
            BotChecked = true
            BotId = Id del bot
            BotName = Nombre del bot
            BotUserName = Nombre de usuario del bot
  }
{Para que funcionen las peticiones ssl hay que instalar libssl-dev en el sistema.
sudo apt install ssl-dev}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  HTTPSend, fpJSON, JSONParser,
  TlgBot.Types, TlgBot.Base, TlgBot.External;

type
  TOnConnect = procedure(BotUserName: string) of object;
  TOnChangeStatus = procedure(ActualStatus: boolean) of object;
  TBaseBot = class(TTlgBotBase, ITlgBot)
  private
    FToken: string;
    FBotChecked: Boolean;
    FBotId: string;
    FBotName: string;
    FBotUserName: string;
    FOnConnect: TOnConnect;
    FOnChangeStatus: TOnChangeStatus;
    FVersion: string;

    procedure SetToken (const Value: string);
    procedure CleanProps;

  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CheckBot:Boolean;

  published
    //El token del bot al que ens connectarem
    property Token: string read FToken write SetToken;
    //Estat del bot l'ultim cop que es va executar la funció CheckBot (Només lectura)
    property BotChecked: Boolean read FBotChecked;
    //Identificador del bot (Només lectura)
    property BotId: string read FBotId;
    //Nom del bot (Només lectura)
    property BotName: string read FBotName;
    //Nom d'usuari del bot (Només lectura)
    property BotUserName: string read FBotUserName;
    //Event disparat al connectarse amb èxit al bot
    property OnConnect: TOnConnect read FOnConnect write FOnConnect;
    //Event disparat si ha canviat l'estat després d'executar la funció CheckBot
    property OnChangeStatus: TOnChangeStatus read FOnChangeStatus write FOnChangeStatus;
    property version: string read FVersion;

  end;

procedure Register;

implementation

constructor TBaseBot.Create (AOwner: TComponent);
begin
  inherited Create(AOwner);
  FToken := '';
  FBotChecked := false;
  FBotId := '';
  FBotName := '';
  FBotUserName := '';
  FVersion := GetProductVersion;
end;

destructor TBaseBot.Destroy;
begin
  inherited Destroy;
end;

procedure TBaseBot.SetToken (const Value: string);
begin
  if Value <> FToken then begin
    FToken := Value;
  end;
end;

function TBaseBot.CheckBot:Boolean;
var
  MemStream: TMemoryStream;
  JSONParser: TJSONParser;
  JSONDoc: TJSONObject;
  oldStatus: boolean;
begin
  result := false;
  oldStatus := FBotChecked;
  if Trim(FToken) <> '' then begin
//Existeix un token
    MemStream := TMemoryStream.Create;
    if HTTPGetBinary(API_BASE_URL + FToken + API_GETME, MemStream) then begin
//Hi ha connexió amb el bot
      FBotChecked := true;
      MemStream.Position := 0;
      JSONParser := TJSONParser.Create(MemStream);
      JSONDoc := TJSONObject(JSONParser.Parse);
      if (JSONDoc.FindPath('ok').AsBoolean) and (JSONDoc.FindPath('result.is_bot').AsBoolean) then begin
//La resposta determina que és un bot i està actiu
        FBotChecked := true;
        FBotId := JSONDoc.FindPath('result.id').AsString;
        FBotName := JSONDoc.FindPath('result.first_name').AsString;
        FBotUserName := '@' + JSONDoc.FindPath('result.username').AsString;
        result := true;
        if Assigned(FOnConnect) then begin
          OnConnect(FBotUserName);
        end;
      end else begin
//hi ha resposta però no és un bot o no està actiu
        CleanProps;
      end;
    end else begin
//No hi ha connexió amb el bot
      CleanProps;
    end;
    if FBotChecked <> oldStatus then begin
      if Assigned(FOnChangeStatus) then begin
        OnChangeStatus(FBotChecked);
      end;
    end;
  end else begin
//No s'ha introduït un token
    CleanProps;
    raise Exception.Create(rsBotTokenNotFound);
  end;
end;

procedure TBaseBot.CleanProps;
begin
  FBotchecked := false;
  FBotId := '';
  FBotName := '';
  FBotUserName := '';
end;

procedure Register;
begin
  {$I basebot_icon.lrs}
  RegisterComponents('TelegramBot',[TBaseBot]);
end;

end.
