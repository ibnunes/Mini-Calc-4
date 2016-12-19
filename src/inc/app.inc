const
   APP_AUTHOR = 'Igor Nunes';
   APP_NAME = 'Mini Calc';
   APP_SERIES = '4';
   APP_VER = APP_SERIES + '.1.2';
   // APP_BUILD = '1768';
   APP_BUILDTIME = 'May 01 2015 - 00:28:00 AM';
   CONSOLE_TITLE = APP_NAME + ' ' + APP_SERIES;

procedure WriteAppMainInfo(x, y : word);
begin
   GotoXY(x, y);
   write(APP_NAME, ' ', APP_VER, ', by ', APP_AUTHOR);
end;


procedure BuildMainScreen(const Y : word = 16);
const X : word = 7;
begin
   TextColor(DEFCOLOR_SELECTED_TEXT);
   WriteBig('MINI CALC ', X, Y);
   TextColor(DEFCOLOR_SELECTED_BACK);
   WriteBig('4', X+60, Y);
   WriteXY(1, Y+6, PadCenter('The minimalist calculator', SCREENWIDTH), 15);
   TextColor(7);
end;