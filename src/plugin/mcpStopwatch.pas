(* === Mini Calc 4 Official Plugin: Stopwatch ===
 * Ver: 1.1.0
 * February 5th, 2015
 *  By: Igor Nunes *)

{$mode objfpc}
{$unitpath /lib}
{$unitpath /pluglibs}

library mcpStopwatch;
uses
   crt, sysutils, mcIntf, UNavigation, UClock;

const
   MYNAME = 'Stopwatch';

type
   TPlugSW = class(TInterfacedObject, IPlugin)
      private
         function GetMyName : WideString;
      
      public
         property PluginName : WideString read GetMyName;
         procedure Execute;
   end;

var
   thehost : IPluginHost = nil;


procedure tools_stopwatch; forward;


function TPlugSW.GetMyName : WideString;
begin
   GetMyName := MYNAME;
end;


procedure TPlugSW.Execute;
begin
   tools_stopwatch;
end;


function PluginInit(host : IPluginHost) : IPlugin; stdcall;
begin
   thehost := host;
   PluginInit := TPlugSW.Create as IPlugin;
end;


procedure tools_stopwatch;

   procedure LoadInterface;
   begin
      WriteXY(2,  2, ' STOPWATCH ', 16, 7);
      WriteXY(4,  4, '               Timer:', 15);
      WriteXY(4,  5, 'Number of registries:', 15);
      WriteXY(4,  6, '       Last registry:', 15);
      
      WriteXY(50, 2, ' REGISTRY OF TIMINGS ', 16, 7);
      
      WriteXY(2, 18, ' INSTRUCTIONS ', 16, 7);
      WriteXY(4, 19, '      P = start/pause  |  C = stop          |  R = reset timer', 8);
      WriteXY(4, 20, '  Enter = mark time    |  V = view timings  |  S = save timings', 8);
      WriteXY(4, 21, '    Esc = go back to main menu', 8);
      WriteXY(4, 22, 'Before going to main menu, the timer must be stopped.', 8);
   end;

   procedure SaveTimings;
   var fname : string;
   begin
      WriteXY(4, 15, '"cancel" to cancel operation.', 16);
      WriteXY(2, 16, 'File name (without extension)? ', 15);
      readln(fname);
      GotoXY(1, 15); clreol;
      GotoXY(1, 16); clreol;
      
      if LowerCase(fname) = 'cancel' then
         Exit;
      sw.SaveToFile(fname + '.txt', 'Mini Calc 4 Official Plugin - Stopwatch' + CRLF + IntToStr(sw.TimeCount) + ' registries:');
   end;

var
   opt : char = #0;

begin
   clrscr;
   LoadInterface;
   
   sw.ClockPosition.x := 26;
   sw.ClockPosition.y := 4;
   sw.TimeCountPosition.x := 26;
   sw.TimeCountPosition.y := 5;
   sw.LastMarkPosition.x := 26;
   sw.LastMarkPosition.y := 6;
   sw.ShowClock;
   sw.ShowMark;
   
   repeat
      opt := UpCase(ReadKey);
      
      case opt of
         'P' : if not sw.running then
                  sw.Execute(false)
               else
                  sw.Paused := not sw.Paused;
         'R' : sw.ResetClock(true);
         'S' : SaveTimings;
         'V' : sw.TableTimings(50, 4);
      end;
   until opt = #27;
end;


exports
   PluginInit;

begin
   // void
end.