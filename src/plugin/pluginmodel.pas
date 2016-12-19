{$mode objfpc}
// {$unitpath /foldername}
      // Uncomment the previous line if you own units
      // are on a folder near your plugin code.

library pluginmodel;
(* Plugin will have the name "mcp*.dll"                           *
 *    E.g.: "mcpStopwatch.dll"                                    *
 *                                                                *
 * It must export only one function:                              *
 *    function PluginInit(host : IPluginHost) : IPlugin; stdcall; *
 * Without this function, the plugin is NOT recognised.           *)

uses
   mcIntf;

const
   MYNAME = 'Plugin name';  // The name of your plugin - shown in the main menu.
                            // No bigger than 15 characters, please.

type
   // The class which implements the plugin interface
   TYourClass = class(TInterfacedObject, IPlugin)
      private
         function GetMyName : WideString;
      
      public
         property PluginName : WideString read GetMyName;
         procedure Execute;
   end;

var
   thehost : IPluginHost = nil;  // Reference to the host (which is Mini Calc)


function TYourClass.GetMyName : WideString;
(* Do NOT change. *)
begin
   GetMyName := MYNAME;
end;


procedure TYourClass.Execute;
(* Method called by Mini Calc to execute the plugin. *)
begin
   // Your plugin code here.
   // You may use whatever you want outside this procedure:
   //    consider this method as your main block of a program.
end;


function PluginInit(host : IPluginHost) : IPlugin; stdcall;
(* Do NOT change. *)
begin
   thehost := host;
   PluginInit := TYourClass.Create as IPlugin;
end;


(* Mini Calc Plugin Initializer recognizes this and loads the plugin. *)
exports
   PluginInit;

begin
   // This must be empty in order to be valid.
end;