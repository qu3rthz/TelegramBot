unit TlgBot.Base;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TTlgBotBase }

  TTlgBotBase = class(TComponent)
  private
    FVersion: string;
    FAutor: string;
    FUrl: string;
    FCompileDate: string;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Autor: string read FAutor;
    property Version: string read FVersion;
    property Url: string read FUrl;
    property CompileDate: string read FCompileDate;
  end;

const
  API_BASE_URL =  'https://api.telegram.org/bot';
  API_GETME =     '/getMe';

resourcestring
  rsBotTokenNotFound = 'No hi ha un token vàlid';

implementation

{ TTlgBotBase }

constructor TTlgBotBase.Create(AOwner: TComponent);
begin
  inherited;
  FAutor := 'qw3rthz';
  FVersion := '0.0.1';
  FUrl := 'https://github.com/qw3rthz/TelegramBot';
  FCompileDate := {$I %DATE%} + ' - ' + {$I %TIME%};
end;

end.

