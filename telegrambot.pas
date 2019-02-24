{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TelegramBot;

{$warn 5023 off : no warning about unused units}
interface

uses
  TlgBot.Base, TlgBot.External, TlgBot.Bot, TlgBot.Types, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('TlgBot.Bot', @TlgBot.Bot.Register);
end;

initialization
  RegisterPackage('TelegramBot', @Register);
end.
