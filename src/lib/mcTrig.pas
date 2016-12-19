(* === mcTrig ===
 * Ver: 1.0.2
 *  By: Igor Nunes
 * Trigonometry routines for Mini Calc 4. *)

{$unitpath /wingraph}
{$mode objfpc}
unit mcTrig;

interface
uses crt, sysutils, math, wingraph,
     UNavigation, UWinBMP;

type TPoint = record
        x, y : word;
     end;
     TAngleUnit = (angleRad, angleDeg, angleGrad);
     TRecAngle = record
        Deg, Rad, Grad : float;
     end;
     TQuadrant = (quad1, quad2, quad3, quad4, between12, between23, between34, between14);
     
     TAngle = class(TObject)
     private
        const cQuad2StrLong : array [TQuadrant] of string =
                  ('first quadrant',
                   'second quadrant',
                   'third quadrant',
                   'fourth quadrant',
                   'between first and second quadrants',
                   'between second and third quadrants',
                   'between third and fourth quadrants',
                   'between first and fourth quadrants');
              cQuad2StrShort : array [TQuadrant] of string = ('Q1','Q2','Q3','Q4','L1/2','L2/3','L3/4','L1/4');
        var vValue   : TRecAngle;
            vMainArg : TRecAngle;
            vQuad    : TQuadrant;
        
        procedure SetNewValue(newvalue : float; angunit : TAngleUnit = angleRad);
        procedure SetDeg(newvalue : float);
        procedure SetRad(newvalue : float);
        procedure SetGrad(newvalue : float);
        procedure CalcMainArg;
        
     public
        constructor Create;
        constructor Create(initvalue : float; angunit : TAngleUnit = angleRad); overload;
        
        property Deg  : float read vValue.deg  write SetDeg;
        property Rad  : float read vValue.rad  write SetRad;
        property Grad : float read vValue.grad write SetGrad;
        property MainArgument : TRecAngle read vMainArg;
        property Quad : TQuadrant read vQuad;
        
        function Quadrant : string;
        function QuadrantShort : string;
        procedure DrawCircle(square_size : word; const SCALEUP_WIDTH : word = 50; const SCALEUP_HEIGHT : word = 50);
        
        function SaveWindow : boolean;
     end;

procedure ShowIdentity(square_size : word; const SCALEUP_WIDTH : word = 180; const SCALEUP_HEIGHT : word = 50);


implementation

procedure InitCircle(out width, height, radius : word; var center : TPoint; square_size : word; const SCALEUP_WIDTH, SCALEUP_HEIGHT : word);
var driver, mode : smallint;
begin
   // Drawing calculation
   width  := square_size + 2*SCALEUP_WIDTH;
   height := square_size + 2*SCALEUP_HEIGHT;
   radius := (square_size * 40) div 100;
   if (center.x = 0) and (center.y = 0) then begin
      center.x := width { SCALEUP_HEIGHT } div 2 { + square_size div 2 };
      center.y := height div 2 { center.x };
   end;
   
   // Initialization of graph window
   DetectGraph(driver, mode);
   mode := mCustom;
   SetWindowSize(width { + SCALEUP_WIDTH }, height { + SCALEUP_HEIGHT });
   InitGraph(driver, mode, 'Mini Calc - Unit Circle');
   
   // Lines
   SetColor(White);
   Line(center.x,
        center.y - square_size div 2 { SCALEUP_HEIGHT div 2 },
        center.x,
        center.y + square_size div 2 { SCALEUP_HEIGHT div 2 + square_size });  // vertical
   
   Line(center.x - square_size div 2 { SCALEUP_WIDTH div 2 },
        center.y,
        center.x + square_size div 2 { SCALEUP_WIDTH div 2 + square_size },
        center.y);  // horizontal
   
   // Circle
   Circle(center.x, center.y, radius);
end;


procedure PutAngleText(center : TPoint; radius : word; angle : TAngle);
const DIFF_Y = 8;
var ANGLE_TEXT : string;  // It is constant!
begin
   ANGLE_TEXT := FloatToStrF(angle.Deg, ffGeneral, 3, 1) + ' deg (' + 
                 FloatToStrF(angle.Rad / system.pi, ffGeneral, 3, 1) + ' * pi rad)';
   
   SetColor(Yellow);
   case angle.Quad of
      quad1,
      quad4,
      between14 : OutTextXY(center.x + Trunc(radius * 1.1 * Cos(angle.Rad)),
                            center.y - Trunc(radius * 1.1 * Sin(angle.Rad)) - DIFF_Y,
                            ANGLE_TEXT);
      
      quad2,
      quad3,
      between23 : OutTextXY(center.x + Trunc(radius * 1.1 * Cos(angle.Rad)) - TextWidth(ANGLE_TEXT),
                            center.y - Trunc(radius * 1.1 * Sin(angle.Rad)) - DIFF_Y,
                            ANGLE_TEXT);
      
      between12,
      between34 : OutTextXY(center.x + Trunc(radius * 1.1 * Cos(angle.Rad)) - TextWidth(ANGLE_TEXT) div 2,
                            center.y - Trunc(radius * 1.1 * Sin(angle.Rad)) - DIFF_Y,
                            ANGLE_TEXT);
   end;
end;


procedure PutAngle(center : TPoint; radius : word; angle : TAngle; const PUTTEXT : boolean = false);
begin
   // Angle
   SetColor(OrangeRed);
   SetLineStyle(SolidLn, 0, DoubleWidth);
   Line(center.x,
        center.y,
        center.x + Trunc(radius * Cos(angle.Rad)),
        center.y - Trunc(radius * Sin(angle.Rad)));
   
   if PUTTEXT then
      PutAngleText(center, radius, angle);
end;


procedure PutFunctions(center : TPoint; radius : word; angle : TAngle);
begin
   // Functions
   SetColor(BrightGreen);
   SetLineStyle(DottedLn, 0, NormWidth);
   // Sin
   Line(center.x + Trunc(radius * Cos(angle.Rad)),
        center.y - Trunc(radius * Sin(angle.Rad)),
        center.x,
        center.y - Trunc(radius * Sin(angle.Rad)));
   // Cos
   Line(center.x + Trunc(radius * Cos(angle.Rad)),
        center.y - Trunc(radius * Sin(angle.Rad)),
        center.x + Trunc(radius * Cos(angle.Rad)),
        center.y);
end;


constructor TAngle.Create;
begin
   self.SetNewValue(0.0, angleDeg);
end;

constructor TAngle.Create(initvalue : float; angunit : TAngleUnit = angleRad); overload;
begin
   self.SetNewValue(initvalue, angunit);
end;


procedure TAngle.CalcMainArg;
begin
   self.vMainArg.Deg := self.vValue.Deg - 360 * RoundTo(self.vValue.Deg / 360, 0);
   self.vMainArg.Rad := DegToRad(self.vMainArg.Deg);
   self.vMainArg.Grad := DegToGrad(self.vMainArg.Deg);
   
   with self, self.vMainArg do begin
      if Deg = 0 then
         vQuad := between14
      else if Deg = 90 then
         vQuad := between12
      else if Abs(Deg) = 180 then
         vQuad := between23
      else if Deg = -90 then
         vQuad := between34
      else if (Deg > 0) and (Deg < 90) then
         vQuad := quad1
      else if (Deg > 90) and (Deg < 180) then
         vQuad := quad2
      else if (Deg > -180) and (Deg < -90) then
         vQuad := quad3
      else if (Deg > -90) and (Deg < 0) then
         vQuad := quad4;
   end;
end;


procedure TAngle.SetDeg(newvalue : float);
begin
   self.SetNewValue(newvalue, angleDeg);
end;

procedure TAngle.SetRad(newvalue : float);
begin
   self.SetNewValue(newvalue, angleRad);
end;

procedure TAngle.SetGrad(newvalue : float);
begin
   self.SetNewValue(newvalue, angleGrad);
end;


procedure TAngle.SetNewValue(newvalue : float; angunit : TAngleUnit = angleRad);
begin
   case angunit of
      angleRad  : begin
                     self.vValue.Rad := newvalue;
                     self.vValue.Deg := RadToDeg(newvalue);
                     self.vValue.Grad := RadToGrad(newvalue);
                  end;
      angleDeg  : begin
                     self.vValue.Deg := newvalue;
                     self.vValue.Rad := DegToRad(newvalue);
                     self.vValue.Grad := DegToGrad(newvalue);
                  end;
      angleGrad : begin
                     self.vValue.Grad := newvalue;
                     self.vValue.Deg := GradToDeg(newvalue);
                     self.vValue.Rad := GradToRad(newvalue);
                  end;
   end;
   self.CalcMainArg;
end;


function TAngle.Quadrant : string;
begin
   Quadrant := self.cQuad2StrLong[vQuad];
end;


function TAngle.QuadrantShort : string;
begin
   QuadrantShort := self.cQuad2StrShort[vQuad];
end;


procedure TAngle.DrawCircle(square_size : word; const SCALEUP_WIDTH : word = 50; const SCALEUP_HEIGHT : word = 50);
// const SCALEUP_HEIGHT = 50;
//       SCALEUP_WIDTH = { 150 + } SCALEUP_HEIGHT;
      
var radius : word;
    width, height : word;
    center : TPoint = (x:0; y:0);
    key : char;

begin
   try
      InitCircle(width, height, radius, center, square_size, SCALEUP_WIDTH, SCALEUP_HEIGHT);
      
      PutAngle(center, radius, self);
      PutFunctions(center, radius, self);
      
      Pause('- Press Enter to close;' + #13+#10 +
            '- Press "S" to save image and close.', [#13, 'S'], key);
      if key = 'S' then
         if not self.SaveWindow then begin
            TextColor(12);
            Pause(#13+#10 + 'Error while saving image.');
            TextColor(7);
         end;
   finally
      CloseGraph;
   end;
end;


function TAngle.SaveWindow : boolean;
var FNAME : AnsiString;
begin
   DateTimeToString(FNAME, 'ddmmyyhhnnsszzz', Now);
   FNAME := 'mcTrig_' + FNAME;
   SaveWindow := SaveBMP(FNAME);
end;


procedure ShowIdentity(square_size : word; const SCALEUP_WIDTH : word = 180; const SCALEUP_HEIGHT : word = 50);
var radius : word;
    width, height : word;
    center : TPoint = (x:320; y:200);
    angle : TAngle;
    key : char;

begin
   try
      InitCircle(width, height, radius, center, square_size, SCALEUP_WIDTH, SCALEUP_HEIGHT);
      
      angle := TAngle.Create(0, angleDeg);
      PutAngleText(center, radius, angle);
      
      angle.Deg := 30;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 45;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 60;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 90;
      PutAngleText(center, radius, angle);
      
      angle.Deg := 120;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 135;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 150;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 180;
      PutAngleText(center, radius, angle);
      
      angle.Deg := 210;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 225;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 240;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 270;
      PutAngleText(center, radius, angle);
      
      angle.Deg := 300;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 315;
      PutAngle(center, radius, angle, true);
      
      angle.Deg := 330;
      PutAngle(center, radius, angle, true);
      
      angle.Free;
      
      Pause('- Press Enter to close;' + #13+#10 +
            '- Press "S" to save image and close.', [#13, 'S'], key);
      if key = 'S' then
         if not SaveBMP(AnsiString('mcTrig_identity')) then begin
            TextColor(12);
            Pause(#13+#10 + 'Error while saving image.');
            TextColor(7);
         end;
   finally
      CloseGraph;
   end;
end;


end.