{
This file is part of the FastPlaz package.
(c) Luri Darmawan <luri@fastplaz.com>

For the full copyright and license information, please view the LICENSE
file that was distributed with this source code.
}
{
  get from KBBI KemDikBud
  http://kbbi.kemdikbud.go.id/

  // USAGE:

  kamus := TKamusIntegration.Create;
  Result := kamus.Find('kemerdekaan');
  kamus.Free;

}
unit kamuskemdikbud_integration;

{$mode objfpc}{$H+}

interface

uses
  {$IFNDEF Windows}
  cthreads,
  {$ENDIF}
  common, http_lib,
  RegExpr, fpjson, Classes, SysUtils;

type

  { TKamusIntegration }

  TKamusIntegration = class(TInterfacedObject)
  private
  public
    constructor Create; virtual;
    destructor Destroy; virtual;
    function Find(Text: string): string;
  end;



implementation

const
  _KAMUS_URL = 'https://kbbi.kemdikbud.go.id/entri/';
  __TAG_START = '\<([\.\$A-Za-z0-9=_ :;\-"]+)\>';
  __TAG_END = '\</([\.\$A-Za-z0-9=_ :;\-"]+)\>';


var
  Response: IHTTPResponse;

{ TKamusIntegration }

constructor TKamusIntegration.Create;
begin
end;

destructor TKamusIntegration.Destroy;
begin

end;

function TKamusIntegration.Find(Text: string): string;
var
  s, return, urlTarget: string;
  httpClient: THTTPLib;
begin
  Result := '';
  Text := trim(LowerCase(Text));
  if Text = '' then
    Exit;

  urlTarget := _KAMUS_URL + UrlEncode(Text);
  httpClient := THTTPLib.Create;
  httpClient.URL := urlTarget;
  Response := httpClient.Get;
  httpClient.Free;

  if Response.ResultCode <> 200 then
    Exit;

  return := StringCut( '<h2>', '</h2>', Response.ResultText);
  return := StripHTML( return);
  return := Trim( return);
  s := StringCut( '</h2>', '<hr />', Response.ResultText);
  s := StripHTML( s);
  s := Trim( s);
  s := ReplaceAll(s, ['   ', '  '], '', True);
  s := ReplaceAll(s, [#13, #10], '\n', True);
  s := ReplaceAll(s, ['\n\n'], '\n', True);
  s := ReplaceAll(s, ['\n\n'], '\n', True);
  return := return + '\n' + s;

  {
  return := copy(Response.ResultText, pos('<hr />', Response.ResultText) + 6);
  return := copy(return, 1, pos('<hr />', return) - 1);

  return := StringReplace(return, '<li>', '<li>\n- ', [rfReplaceAll]);
  return := preg_replace(
    '\<span title="([\.\$A-Za-z0-9=_ :;\-"]+)">([\.\$A-Za-z0-9=_ :;\-"]+)</span>',
    '', return, True);
  return := preg_replace('\<.*?>', '', return, True);
  }

  if Pos( 'Entri tidak ditemukan', return) = 0 then
    Result := return;
end;

end.
