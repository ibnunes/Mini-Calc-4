(* === Mini Calc ===
 * Ver: 4.2.0
 * month day, 2015
 *  By: Igor Nunes
 * The Minimalist Calculator for Windows. *)

{$mode objfpc}
{$unitpath /lib}
{$unitpath /lib/wingraph}
{$unitpath /plugin/lib}

program minicalc;
{$R res/mc4.res}

uses
   // RTL Free Pascal
   crt, sysutils, strutils, classes, windows, math, dynlibs,
   // FCL Free Pascal
   fpexprpars, { fileinfo, }
   // Freeware, open-source units
   wingraph,
   // Own generic units
   UMenu, UNavigation, UMath, UWinBMP, UAlpha, UExcept,
   // Mini Calc specific units
   mcGUI, mcIO, mcCalc, mcGraph, mcEq, mcTrig, mcRand, mcVLM, mcStat, mcMem,
   // Extensions
   mcIntf;

const
   OPTION_EXIT  = #27;  // Esc
   SCREENWIDTH  = 80;
   SCREENHEIGHT = 25;
   LIST_MSGPOS  = 23;
   LIST_KEYTXT  = 18;
   // CRLF = #13+#10;
   
   MEM_PAR = 'par.mc4p';
   MEM_FN  = 'fn.mc4f';
   MEM_VLM = 'vlm.mc4l';
   MEM_PLOTTER_DEF = 'plt.mc4gd';
   MEM_PLOTTER_EQ  = 'plt.mc4ge';
   
   DEFCOLOR_SELECTED_TEXT = 15;
   DEFCOLOR_SELECTED_BACK = 4;
   DEFCOLOR_REGULAR_TEXT = 7;
   DEFCOLOR_REGULAR_BACK = 0;

var
   _EXITING : boolean = false;     // Internal flag - order to exit

(* <INCLUDE> *)
   (* Generic features *)
   {$i inc/preamble.inc}   // Lists all public procedures and functions present in the *.inc files.
   {$i inc/app.inc}        // Application information (name, version, author...).
   {$i inc/gui.inc}        // Everything related with GUI (navigation, not presentation of information).
   {$i inc/io.inc}         // Specific methods for I/O handling.

   (* Specific features and systems *)
   {$i inc/calc.inc}       // Calculator
   {$i inc/eq.inc}         // Equations
   {$i inc/form.inc}       // Formulas (e.g., quadratic)
   {$i inc/list.inc}       // Lists (VLM)
   {$i inc/stat.inc}       // Statistics
   {$i inc/trig.inc}       // Trigonometry
   {$i inc/random.inc}     // Random
   {$i inc/mem.inc}        // Memory Manager
   {$i inc/help.inc}       // Help
   
   (* Extensions/plugins *)
   {$i inc/IntfHost.inc}   // Implementation of host side of interface
(* </INCLUDE> *)

(* Main block *)
var option : char;
    previous_item : integer = 0;
    _PLUGSTAT : byte;

begin
   // Plugin initialization - it is the first thing
   writeln('Plugin Initialization:');
   pluginmenu := TMenu.Create;
   try
      _PLUGSTAT := PluginInitialization;
   except
      on ex : Exception do begin
         _PLUGSTAT := PLUGIN_FATAL;
         pluginmenu.Add('Back', '<-', #8, TProc(nil));
         writeln('   [ERR] ', ex.classname, ', ', ex.message);
         writeln;
         writeln('Unloading all plugins...');
         try
            PluginFinalization;
         except
            on ex2 : Exception do
               writeln('  [ERR] ', ex2.classname, ', ', ex2.message);
         end;
         Pause('Press enter to continue...');
      end;
   end;
   
   
   try
      plotter.Parser := mcParser;
      plotter.LoadFromFile(MEM_PLOTTER_DEF, MEM_PLOTTER_EQ);
      plotter.AutoSave.Status := true;
      plotter.AutoSave.FileName.Definitions := MEM_PLOTTER_DEF;
      plotter.AutoSave.FileName.Equations := MEM_PLOTTER_EQ;
      
      memory.LoadFromFile(MEM_PAR, mcParser);
      memory.LoadFromFile(MEM_FN, mcFunctions);
      
      listmgr.LoadFromFile(MEM_VLM);
      // AutoSave ONLY AFTER LOAD!! Otherwise, it'll generate EInOutError (access denied)
      listmgr.AutoSave.Status := true;
      listmgr.AutoSave.FileName := MEM_VLM;
      
      LoadUI;     // Loads every GUI element of the program
      
      try
         clrscr;
         repeat   // Main menu
            WriteAppMainInfo(2, 2);
            BuildMainScreen;
            option := mainmenu.GetChoice(MAINMENU_POS_X, MAINMENU_POS_Y, previous_item);
         until (option = OPTION_EXIT) or _EXITING;
      except
         on ex : Exception do begin    // Handles unexpected exceptions
            write('[ERR] ', ex.classname, ', ', ex.message);
            Pause;
            (* After final build, use 'FatalInfo' from unit 'UExcept' *)
         end;
      end;
      
   finally
      FreeUI;  // Destroys every GUI element
      
      memory.SaveToFile(MEM_PAR, mcParser);
      memory.SaveToFile(MEM_FN, mcFunctions);
      listmgr.SaveToFile(MEM_VLM);
      plotter.SaveToFile(MEM_PLOTTER_DEF, MEM_PLOTTER_EQ);
   end;
   
   // Plugin finalization
   clrscr;
   writeln('Plugin Finalization:');
   if _PLUGSTAT <> PLUGIN_FATAL then
      try
         PluginFinalization;
      except
         on ex2 : Exception do begin
            writeln('  [ERR] ', ex2.classname, ', ', ex2.message);
            Pause('Press enter to continue...');
         end;
      end;
end.