(* === UClock ===
 * Ver: 1.0.2
 *  By: Igor Nunes
 * Date and time tools - stopwatch. *)

{$mode objfpc}
unit UClock;

interface
uses crt, dos, sysutils, strutils, math, dateutils, classes;

type
   TPoint = record
      x, y : byte;
   end;
   
   TStopWatch = class(TObject)
      private
         type
            TTiming = array of TDateTime;
         var
            pause   : boolean;
            timings : TTiming;
            clock   : TDateTime;

      protected
         function GetTimeCount : word;

      public
         var
            ClockPosition : TPoint;
            TimeCountPosition : TPoint;
            LastMarkPosition : TPoint;
            Running : boolean;

         constructor Create;
         procedure SaveToFile(fname : string; const HEADER : string = ''; const FOOTER : string = '');
         procedure Execute(const FROMZERO : boolean = true);
         procedure MarkTime;
         procedure ShowClock;
         procedure ShowMark;
         procedure ResetClock(const SHOW : boolean = false);
         procedure TableTimings(const X, Y : word; const HEIGHT : word = 10);
         property Paused : boolean read pause write pause;
         property TimeCount : word read GetTimeCount;
   end;

var
   sw : TStopWatch;


implementation

constructor TStopWatch.Create;
begin
   self.pause := false;
   self.running := false;
   SetLength(self.timings, 0);
   self.ClockPosition.x := 1;
   self.ClockPosition.y := 1;
   inherited Create;
end;


function TStopWatch.GetTimeCount : word;
begin
   GetTimeCount := Length(self.timings);
end;


procedure TStopWatch.SaveToFile(fname : string; const HEADER : string = ''; const FOOTER : string = '');
var f : Text;
    i : word;
    s : AnsiString;
begin
   Assign(f, fname);
   Rewrite(f);
   
   writeln(f, HEADER);
   for i := Low(self.timings) to High(self.timings) do begin
      DateTimeToString(s, 'hh:nn:ss:zzz', self.timings[i]);
      writeln(f, PadLeft(IntToStr(i+1), 5), ': ', s);
   end;
   writeln(f, FOOTER);
   
   Close(f);
end;


procedure TStopWatch.ResetClock(const SHOW : boolean = false);
begin
   self.clock := EncodeTime(0, 0, 0, 0);
   SetLength(self.timings, 0);
   if SHOW then begin
      self.ShowClock;
      self.ShowMark;
   end;
end;


procedure TStopWatch.Execute(const FROMZERO : boolean = true);
const
   SHOWTIME = 5;
var
   key : char;
   ind : byte = SHOWTIME - 1;
   init, start : TDateTime;
   h, m, s, ms : Word;

begin
   self.Paused := false;
   self.running := true;
   
   if FROMZERO then
      self.ResetClock
   else
      start := self.clock;
   DecodeTime(Now, h, m, s, ms);
   init := EncodeTime(h, m, s, ms);
   // attribute Now to init will create some kind of alias
   
   repeat
      while not keypressed do begin
         Sleep(1);
         Inc(ind);
         self.clock := start + Now - init;
         
         if (ind >= SHOWTIME) and (not self.Paused) then begin
            self.ShowClock;
            ind := 0;
         end;
      end;
      
      key := UpCase(ReadKey);
      case key of
         #13 : 
            begin
               self.MarkTime;
               self.ShowMark;
            end;
         'P' :
            begin
               self.Paused := not self.Paused;
               self.ShowClock;
            end;
      end;
   until key = 'C';
   
   self.Paused := true;
   self.running := false;
   self.ShowClock;
end;


procedure TStopWatch.ShowClock;
var s : AnsiString;
begin
   if self.running then begin
      if self.paused then
         TextColor(14)
      else
         TextColor(10);
   end else
      TextColor(12);
   
   GotoXY(self.ClockPosition.x, self.ClockPosition.y);
   DateTimeToString(s, 'hh:nn:ss:zzz', self.clock);
   writeln(PadRight(s, 12));
   
   TextColor(7);
end;


procedure TStopWatch.ShowMark;
var s : AnsiString;
begin
   TextColor(10);
   GotoXY(self.TimeCountPosition.x, self.TimeCountPosition.y);
   write(PadRight(IntToStr(self.TimeCount), 5));
   GotoXY(self.LastMarkPosition.x, self.LastMarkPosition.y);
   if self.TimeCount > 0 then
      DateTimeToString(s, 'hh:nn:ss:zzz', self.timings[High(self.timings)])
   else
      s := 'None';
   write(PadRight(s, 12));
   TextColor(7);
end;


procedure TStopWatch.MarkTime;
begin
   SetLength(self.timings, Succ(Length(self.timings)));
   self.timings[High(self.timings)] := self.clock;
end;


procedure TStopWatch.TableTimings(const X, Y : word; const HEIGHT : word = 10);
const
   KEY_UP      = #72;
   KEY_DOWN    = #80;
   KEY_ESC     = #27;
   NAVKEYS = [KEY_UP, KEY_DOWN, KEY_ESC];

var
   i    : word;
   init : SmallInt = 0;
   opt  : char;
   s    : AnsiString;

begin
   if self.TimeCount = 0 then begin
      GotoXY(X, Y);
      write('None');
      repeat until ReadKey = #13;
      GotoXY(X, Y);
      clreol;
   end else begin
      
      GotoXY(X, Y+1);
      TextColor(15);
      write(IntToStr(self.TimeCount), ' total registries');
      TextColor(7);
      
      repeat
         for i := Low(self.timings) to Min(HEIGHT, High(self.timings)) do begin
            GotoXY(X, Y+i);
            DateTimeToString(s, 'hh:nn:ss:zzz', self.timings[init + i]);
            write(PadLeft(IntToStr(i+init+1), 5), ': ', s);
         end;
         
         repeat
            opt := UpCase(ReadKey);
         until opt in NAVKEYS;
         
         case opt of
            KEY_DOWN :
               begin
                  Inc(init);
                  if init >= self.TimeCount - HEIGHT then
                     init := 0;
               end;
            
            KEY_UP :
               begin
                  Dec(init);
                  if init < 0 then
                     init := self.TimeCount - HEIGHT - 1;
               end;
         end;
         
      until opt = #27;
      
      for i := Low(self.timings) to Min(HEIGHT, self.TimeCount) do begin
         GotoXY(X, Y+i);
         clreol;
      end;
   end;
end;



initialization
   sw := TStopWatch.Create;


finalization
   sw.Free;

end.