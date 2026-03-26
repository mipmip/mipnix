{
inputs,
...
}:
{
  flake.modules.homeManager.pim-thunderbird = {
    programs.thunderbird.profiles."default" = {
      isDefault = true;
      userChrome = ''
       #tabbar-toolbar[currentset="calendar-tab-button,task-tab-button"] {
         display: none;
       }

       #calendar-show-todaypane-panel[id="calendar-show-todaypane-panel"] {
         display: none;
       }
        '';
    };
  };
}
