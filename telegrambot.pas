{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TelegramBot;

{$warn 5023 off : no warning about unused units}
interface

uses
  BaseBot, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('BaseBot', @BaseBot.Register);
end;

initialization
  RegisterPackage('TelegramBot', @Register);
end.
