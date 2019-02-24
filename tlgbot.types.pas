unit TlgBot.Types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ITlgBot = interface
    ['{17E42FFD-6D27-4B90-81DD-C245B625002F}']
  procedure SetToken (const Value: string);
  procedure CleanProps;
  function CheckBot:Boolean;
  end;

implementation

end.

