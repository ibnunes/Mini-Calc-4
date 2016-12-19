procedure help_about;
begin
   clrscr;
   BuildMainScreen(2);
   GotoXY(2, 10);
   TextColor(15);
   write(APP_NAME + ' ');
   TextColor(12);
   write(APP_SERIES + 'th series');
   
   WriteXY(2, 11, 'Version: ' + APP_VER);
   WriteXY(2, 12, '  Build: ' { + APP_BUILD + ', at ' } + APP_BUILDTIME);
   WriteXY(2, 14, '     By: ' + APP_AUTHOR);
   WriteXY(2, 15, '         All rights reserved.');
   WriteXY(2, 18, 'This program is FREEWARE. You should NOT pay for it!', 15);
   WriteXY(2, 20, 'Please, report any bug with its proper description.');
   
   GotoXY(2, 24);
   TextColor(8);
   Pause('Press Enter to go back...');
   TextColor(7);
end;


procedure help_contents;
type
   THelpProc = procedure; stdcall;

var
   helprec : record
      exists : boolean;
      proc   : THelpProc;
      dll    : TLibHandle;
   end;

   function HelpInitialization : boolean;
   const
      DIR = 'help.dll';
   begin
      HelpInitialization := true;
      
      try
         helprec.dll := LoadLibrary(PChar(DIR));
         
         if helprec.dll <> NilHandle then begin
            helprec.proc := THelpProc(GetProcedureAddress(helprec.dll, 'Execute'));
            if not Assigned(helprec.proc) then
               HelpInitialization := false;
         end else
            HelpInitialization := false;
      except
         HelpInitialization := false;
      end;
   end;

   procedure HelpFinalization;
   begin
      if helprec.exists and (helprec.dll <> NilHandle) then begin
         if UnloadLibrary(helprec.dll) then
            helprec.dll := NilHandle;
      end;
   end;


begin
   helprec.exists := HelpInitialization;
   
   if helprec.exists then begin
      helprec.proc;
   end else begin
      // HELPPOSCOLLAB in 'gui.inc'
      GotoXY(HELPPOSCOLLAB.x, HELPPOSCOLLAB.y1+2); clreol;
      GotoXY(HELPPOSCOLLAB.x, HELPPOSCOLLAB.y1+3); clreol;
      WriteXY(HELPPOSCOLLAB.x, HELPPOSCOLLAB.y1+2, 'Help not available in the app:', 8);
      WriteXY(HELPPOSCOLLAB.x, HELPPOSCOLLAB.y1+3, '  - refer to "help.chm".', 8);
      Pause;
   end;
   
   HelpFinalization;
end;