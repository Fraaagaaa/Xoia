#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#define DEBUG 0

init()
{
    level thread init_menu_system();
    level thread init_info_dvars();
    register_menu_handler( "character", ::on_character_menu );
    register_menu_handler( "game_monitor", ::on_game_monitor_menu);
}

init_info_dvars()
{
    self thread timeDvars();

    flag_wait("initial_blackscreen_passed");
    if(level.players.size == 1)
        level.players[0] thread downDvars();
}

downDvars()
{
    level endon("end_game");
    self endon("disconnect");
    setDvar("xoia_info_down1", "N/A");
    setDvar("xoia_info_down2", "N/A");
    setDvar("xoia_info_down3", "N/A");

    self waittill("player_downed");
    setDvar("xoia_info_down1", "" + level.round_number);
    self waittill("player_downed");
    setDvar("xoia_info_down2", "" + level.round_number);
    self waittill("player_downed");
    setDvar("xoia_info_down3", "" + level.round_number);
}

timeDvars()
{
    level endon ("end_game");

    while(true)
    {
        level waittill("start_of_round");
        if(isdefined(level.round_total_time[29]))
            setDvar("timeto30", int_to_time(level.round_total_time[29]));
        if(isdefined(level.round_total_time[49]))
            setDvar("timeto50", int_to_time(level.round_total_time[49]));
        if(isdefined(level.round_total_time[69]))
            setDvar("timeto70", int_to_time(level.round_total_time[69]));
        if(isdefined(level.round_total_time[99]))
            setDvar("timeto100", int_to_time(level.round_total_time[99]));
        if(isdefined(level.round_total_time[149]))
            setDvar("timeto150", int_to_time(level.round_total_time[149]));
        if(isdefined(level.round_total_time[199]))
            setDvar("timeto200", int_to_time(level.round_total_time[199]));
        if(isdefined(level.round_total_time[254]))
            setDvar("timeto255", int_to_time(level.round_total_time[254]));
    }
}

init_menu_system()
{
    level endon ("end_game");
    flag_wait("initial_blackscreen_passed");

    foreach ( player in getplayers() )
        player thread menu_dispatcher();

    while (true)
    {
        level waittill( "connected", player );
        player thread menu_dispatcher();
    }
}

menu_dispatcher()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    // Evitar duplicados
    self notify( "xoia_menu_dispatcher" );
    self endon( "xoia_menu_dispatcher" );

    if(!isdefined(self.xoia_menu_settings))
        self.xoia_menu_settings = [];

    while ( true )
    {
        self waittill( "menuresponse", menu, response );

        if(DEBUG) println("new response");

        if (!isdefined(menu) || !isdefined(response) || menu != "restartgamepopup")
        {
            if(DEBUG) PrintLn("Not right menu");
            continue;
        }

        if (!issubstr(response, "xoia+"))
        {
            if(DEBUG) PrintLn("No right module");
            continue;
        }

        self handle_menu_response(response);
    }
}

handle_menu_response(response)
{
    notification = strtok( response, "+" );

    if (!isdefined(notification) || notification.size < 3 || notification[0] != "xoia")
        return;

    module = notification[1];
    action = notification[2];

    args = [];
    for (i = 3; i < notification.size; i++)
        args[args.size] = notification[i];

    // decidimos el modulo
    if (!isdefined(level.xoia_menu_handlers[module]))
        return;

    if(DEBUG)
    {
        println("^2handle_menu_response()");
        if(isdefined(module))
            println("module: " + module);
        if(isdefined(action))
            println("action: " + action);
    
        for(i = 0; i < args.size; i++)
            println("arg " + i + ": " + args[i]);
    }

    self thread [[level.xoia_menu_handlers[module]]](action, args);
}

menu_set(arg)
{
	entry = strtok( arg, ":" );
	if (!isdefined(entry) || entry.size < 2)
		return;

    self.xoia_menu_settings[entry[0]] = entry[1];
}

on_character_menu( action, args )
{
    if ( args.size == 0 )
        return;

    if ( action != "set" && action != "sync" )
        return;

    self thread scripts\zm\Xoia::change_player_model( int( args[0] ) );
}

on_game_monitor_menu(action, args)
{
    if(DEBUG)
    {
        println("action = " + action);
        println("args.size = " + args.size);
        for(i = 0; i < args.size; i++)
            println("arg " + i + ": " + args[i]);
    }
    if ( args.size == 0 )
        return;

    if ( action != "set" && action != "sync" )
        return;

    self thread commandHandler( "!" + args[0], self, false );
}

register_menu_handler( module_name, callback )
{
    if(!isdefined(level.xoia_menu_handlers))
		level.xoia_menu_handlers = [];

    level.xoia_menu_handlers[ module_name ] = callback;
}