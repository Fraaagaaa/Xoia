#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

init()
{
    level thread update_info_dvars();
    level thread on_player_connect();
}

on_player_connect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread menu_response_tracker();
    }
}

menu_response_tracker()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("menuresponse", menu, response);
        
        if (issubstr(response, "xoia+"))
        {
            args = strtok(response, "+");
            
            // args[1] = módulo, args[2] = acción
            // NOTA: el antiguo handler "game"+"pause" (toggle manual de
            // cl_paused via setdvar) se ha eliminado. gracias a
            // options.lua (referencia del propio juego) sabemos que
            // "PAUSE HARD" es en realidad Engine.Exec(controller,"pause_hard"),
            // un comando de consola nativo del motor que no necesita pasar
            // por el servidor en absoluto. Ver CoD.Xoia.TogglePauseHard en
            // optionsxoia.lua.
            if(args[1] == "character" && args[2] == "set")
            {
                // Llamamos a la función ya existente en Xoia.gsc.
                // NOTA: char_index ahora es SIEMPRE un indice local al tipo
                // de mapa (1..N), calculado en optionsxoia.lua segun el
                // selector correspondiente (victis/survival/mob/origins),
                // igual que esperan los "case" de change_player_model().
                // change_player_model() se encarga de guardar char_index en
                // self.xoia_character para que se reaplique en cada respawn.
                char_index = int(args[3]);
                self thread scripts\zm\Xoia::change_player_model(char_index); 
            }
        }
    }
}

update_info_dvars()
{
    level endon("end_game");
    
    // Inicializar dvars
    setdvar("xoia_info_zombies", "0");
    setdvar("xoia_info_boxhits", "0");
    setdvar("xoia_info_round", "0");
    
    for(;;)
    {
        if(isdefined(level.round_number))
        {
            zombies_total = scripts\zm\Xoia::zombies_at_round(level.round_number);
            zombies_alive = get_current_zombie_count();
            setdvar("xoia_info_zombies", zombies_alive + " / " + zombies_total);
            setdvar("xoia_info_round", level.round_number);
        }
        
        if(isdefined(level.total_chest_accessed))
        {
            setdvar("xoia_info_boxhits", level.total_chest_accessed);
        }
        
        wait 1;
    }
}