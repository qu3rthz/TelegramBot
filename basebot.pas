unit BaseBot;
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
  ssl_openssl, HTTPSend, fpJSON, JSONParser, LCLTranslator;

type
  TBaseBot = class(TComponent)
  private
    FToken: string;
    FBotChecked: Boolean;
    FBotId: string;
    FBotName: string;
    FBotUserName: string;

    procedure SetToken (const Value: string);

  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CheckBot:Boolean;

  published
    property Token: string read FToken write SetToken;
    property BotChecked: Boolean read FBotChecked;
    property BotId: string read FBotId;
    property BotName: string read FBotName;
    property BotUserName: string read FBotUserName;

  end;
const
  BOT_BASE_URL =  'https://api.telegram.org/bot';
  BOT_GETME =     '/getMe';

resourcestring
  rsBotFailConnection = 'No es pot connectar amb el bot';

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
end;

destructor TBaseBot.Destroy;
begin
  inherited Destroy;
end;

//Token
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
begin
  MemStream := TMemoryStream.Create;
  result := false;
  if Trim(FToken) <> '' then begin
    if HTTPGetBinary(BOT_BASE_URL + FToken + BOT_GETME, MemStream) then begin
      FBotChecked := true;
      MemStream.Position := 0;
      JSONParser := TJSONParser.Create(MemStream);
      JSONDoc := TJSONObject(JSONParser.Parse);
      if (JSONDoc.FindPath('ok').AsBoolean) and (JSONDoc.FindPath('result.is_bot').AsBoolean) then begin
        FBotChecked := true;
        FBotId := JSONDoc.FindPath('result.id').AsString;
        FBotName := JSONDoc.FindPath('result.first_name').AsString;
        FBotUserName := '@' + JSONDoc.FindPath('result.username').AsString;
        result := true;
      end;
    end else begin
      raise Exception.Create(rsBotFailConnection);
    end;
  end;
end;

procedure Register;
begin
  {$I basebot_icon.lrs}
  RegisterComponents('TelegramBot',[TBaseBot]);
end;

end.
