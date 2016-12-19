(* Function for visual manager. *)

   procedure GetEquation(out name : string);
   begin
      TextBackground(8);
      GotoXY(2, LIST_MSGPOS);
      clreol;
      GotoXY(2, LIST_MSGPOS);
      TextColor(15);
      write('New eq? ');
      TextColor(7);
      readln(name);
      case LowerCase(name) of
         'regeq'  : name := GetVarStr('regeq');
         'quadeq' : name := GetVarStr('quadeq');
      end;
      GotoXY(2, LIST_MSGPOS);
      clreol;
   end;

(* ----------------------------- *)

procedure eq_editer;
begin
   eq_environment;
end;


{ procedure eq_graph;
begin
   eq_environment(false);
   // Turn true when interactive mode implemented.
end; }


procedure eq_environment(START_WITH_GRAPH : boolean = false);
const Bool2YN : array [boolean] of string = ('Off', 'On ');

   procedure ShowInstructions(const X, Y : word);
   begin
      WriteXY(X, Y  , 'Up/Down = navigation', 8);
      WriteXY(X, Y+1, 'Enter = edit   |  <- = Clear', 8);
      WriteXY(X, Y+2, '    T = table  |   G = graphic', 8);
      WriteXY(X, Y+3, '    S = save image of graphic', 8);
      WriteXY(X, Y+4, '    Z = edit graphic settings', 8);
      WriteXY(X, Y+6, 'Esc = back to main menu', 8);
   end;

   procedure EditPlotterDef(const X : word);
   
      procedure WriteZoom(const X, Y : word);
      begin
         WriteXY(X, Y  , Real2Str(plotter.Zoom.xMin));
         WriteXY(X, Y+1, Real2Str(plotter.Zoom.xMax));
         WriteXY(X, Y+2, Real2Str(plotter.Zoom.xScl));
         WriteXY(X, Y+3, Real2Str(plotter.Zoom.yMin));
         WriteXY(X, Y+4, Real2Str(plotter.Zoom.yMax));
         WriteXY(X, Y+5, Real2Str(plotter.Zoom.yScl));
         WriteXY(X, Y+7, Bool2YN[plotter.Grid]);
         WriteXY(X, Y+8, Bool2YN[plotter.Axes]);
      end;
   
   const
      INIT_Y = 2;
      DIST_X = 14+5;
   
   var key : char = #0;
       Y : word;
       newval : float;
       z : mcGraph.TZoom;
       item : integer = 0;
   begin
      repeat
         z := plotter.Zoom;
         Y := INIT_Y;
         WriteZoom(X + DIST_X, Y);
         key := plotter_zoommenu.GetChoice(X, Y, item);
         
         if key in ['1'..'6'] then begin
            Y := StrToInt(string(key)) + INIT_Y - 1;
            
            repeat
               GotoXY(X + DIST_X, Y);
               clreol;
               GotoXY(X + DIST_X, Y);
            until SecureRead.TFloat('', newval);
            
            case key of
               '1' : z.xMin := newval;
               '2' : z.xMax := newval;
               '3' : z.xScl := newval;
               '4' : z.yMin := newval;
               '5' : z.yMax := newval;
               '6' : z.yScl := newval;
            end;
            
            plotter.Zoom := z;
            plotter.RefreshWindow;
            
         end else
         if key in ['A'..'B', 'Z'] then begin
            case key of
               'A' : plotter.Grid := not plotter.Grid;
               'B' : plotter.Axes := not plotter.Axes;
               'Z' :
                  begin
                     z := DEFAULT_PLOTTER_ZOOM;
                     plotter.Zoom := z;
                  end;
            end;
            
            plotter.RefreshWindow;
         end;
         
         for Y := INIT_Y to INIT_Y+9 do begin
            GotoXY(X, Y);
            clreol;
         end;
      until key = OPTION_EXIT;
   end;


const
   KEY_EXTRA_PLOTTER_EDIT = 'Z';
   KEY_EXTRA_PLOTTER_SAVE = 'S';

var opt  : char = #0;
    opt2 : char = #0;
    fn_idx : LongInt = 0;

begin
   clrscr;
   DrawSeparator(41, 1, SCREENHEIGHT-3);
   ShowInstructions(2, 14);
      // Space available for instructions is bigger, LIST_KEYTXT not used.
   
   repeat
      opt := mcFunctions.NavigateThroughFunctions(2, 2, fn_idx, TFnGetName(@GetEquation), START_WITH_GRAPH, [KEY_EXTRA_PLOTTER_EDIT, KEY_EXTRA_PLOTTER_SAVE], plotter, mcParser);
      
      case opt of
         KEY_FN_SELECT :
            if (mcFunctions[fn_idx] <> '') then begin
               opt2 := mcFunctions.Table(43, 2, fn_idx, mcParser);
               textbackground(8);
               textcolor(7);
               if opt2 = KEY_FN_EXIT then
                  mcFunctions.ClearTable(43, 2);
            end;
         
         KEY_FN_GRAPH :
            if START_WITH_GRAPH then begin
               plotter.ShowWindow;
               plotter.RefreshWindow;
               Pause([KEY_FN_EXIT], opt);
               plotter.HideWindow;
            end else begin
               if plotter.WindowVisible then
                  plotter.HideWindow
               else begin
                  plotter.ShowWindow;
                  plotter.RefreshWindow;
               end;
            end;
         
         KEY_EXTRA_PLOTTER_EDIT :
            EditPlotterDef(43);
         
         KEY_EXTRA_PLOTTER_SAVE :
            begin
               if plotter.WindowVisible then
                  if not plotter.SaveWindow then begin
                     WriteXY(2, 24, 'Error while saving image.', 12);
                     Pause;
                     GotoXY(2, 24); clreol;
                  end;
            end;
      end;
      
   until opt = KEY_FN_EXIT;
   
   if plotter.WindowVisible then
      plotter.HideWindow;
end;