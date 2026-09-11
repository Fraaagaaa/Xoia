#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

#define DEBUG 1

init()
{
    level thread update_info_dvars();
    level thread init_menu_system();
    register_menu_handler( "character", ::on_character_menu );
    register_menu_handler( "game_monitor", ::on_game_monitor_menu);
}

update_info_dvars()
{
    level endon("end_game");
    
    setdvar("xoia_info_zombies", "0");
    setdvar("xoia_info_boxhits", "0");
    setdvar("xoia_info_round", "0");
    
    while(true)
    {
        if(isdefined(level.round_number))
        {
            zombies_total = scripts\zm\Xoia::zombies_at_round(level.round_number);
            zombies_alive = get_current_zombie_count();
            setdvar("xoia_info_zombies", zombies_alive + " / " + zombies_total);
            setdvar("xoia_info_round", level.round_number);
        }
        
        if(isdefined(level.total_chexoia_accessed))
        {
            setdvar("xoia_info_boxhits", level.total_chexoia_accessed);
        }
        
        wait 1;
    }
}

init_menu_system()
{
    level endon ("end_game");
    flag_wait("initial_blackscreen_passed");

    foreach ( player in getplayers() )
        player thread menu_dispatcher();

    while ( true )
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
            self IPrintLn("Not right menu");
            continue;
        }

        if (!issubstr(response, "xoia+"))
        {
            self IPrintLn("No right module");
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