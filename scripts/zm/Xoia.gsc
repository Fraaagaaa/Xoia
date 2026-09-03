#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;

#define DEBUG 0
#define VERSION "1.0"
#define PATCH_NAME "Xoia"

#define FILE_MONITOR "xoia/monitor.log"
#define FILE_TWITCH_SEND "twitch/send_to_twitch.txt"

#define CLEAR_WATERMARK_ROUND 10
#define MAX_FB_ROUND 7

#define FRIDGE_AND_BANK_ROUND 15

#define TIMER_HIDE 0
#define TIMER_TOP_RIGHT 1
#define TIMER_TOP_LEFT 2
#define TIMER_MID_LEFT 3
#define TIMER_AMMO 4

#define CAMO_GREEN_RUN 39
#define CAMO_MOB 40
#define CAMO_AQUA 41
#define CAMO_BREACH 42
#define CAMO_COYOTE 43
#define CAMO_GLAM 44
#define CAMO_ORIGINS 45

#define MISTY 1
#define RUSSMAN 2
#define MARLTON 3
#define STUHLINGER 4
#define CDC 5
#define CIA 6
#define ARLINGTON 7
#define OLEARY 8
#define DELUCA 9
#define HANDSOME 10
#define AFTERLIFE 11
#define DEMPSEY 12
#define NIKOLAI 13
#define TAKEO 14
#define RICHTOFEN 15

#define STAT_KEY_MAP "zm_prison"
#define STAT_KEY "clip"

#define WEAPON_NOT_PRESENT "weapon_not_in_map"
#define WEAPON_NOT_IN_BOX "weapon_not_in_box"
#define WEAPON_UNKNOWN "unknown_weapon"

#define SROUND_ARRAY(__type) level.special_rounds[__type]["rounds"]
#define SROUND_ARRAY_START(__type) level.special_rounds[__type]["start_round"]
#define SROUND_ARRAY_START_LAST(__type) SROUND_ARRAY_START(__type)[SROUND_ARRAY_START(__type).size - 1]
#define SROUND_ARRAY_COND(__type) level.special_rounds[__type]["condition"]
#define SROUND_ARRAY_INTERVAL(__type) level.special_rounds[__type]["freq"]
#define SROUND_ARRAY_LAST(__type) SROUND_ARRAY(__type)[SROUND_ARRAY(__type).size - 1]
#define SROUND_ARRAY_NEW(__type) SROUND_ARRAY(__type)[SROUND_ARRAY(__type).size]

#define BRUTUS_INTERVAL array(4,5,6)
#define BRUTUS_START array(4,5,6,7,8,9)
#define BRUTUS_COND "You must exit the golden gate"
#define LEAPERS_INTERVAL array(4,5)
#define LEAPERS_START array(5,6,7)
#define LEAPERS_COND undefined
#define TEMPLAR_INTERVAL array(3,4,5)
#define TEMPLAR_START array(10)
#define TEMPLAR_COND "You must have 4 generators on"
#define PANZER_INTERVAL array(4,5,6)
#define PANZER_START array(8)
#define PANZER_COND "You must open No Mans Land"

istown()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "town" && level.scr_zm_ui_gametype_group == "zsurvival");
}

isfarm()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "farm" && level.scr_zm_ui_gametype_group == "zsurvival");
}

isdepot()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zsurvival");
}

istranzit()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic");
}

isnuketown()
{
	return (level.script == "zm_nuked");
}

isdierise()
{
	return (level.script == "zm_highrise");
}

ismob()
{
	return (level.script == "zm_prison");
}

isburied()
{
	return (level.script == "zm_buried");
}

isorigins()
{
	return (level.script == "zm_tomb");
}

issurvivalmap()
{
	return (isnuketown() || istown() || isfarm() || isdepot());
}

isvictismap()
{
	return (istranzit() || isburied() || isdierise());
}

isstgame()
{
    return getDvar("fs_game") == "mods/zm_strattester";
}

isround(round)
{
	return round <= level.round_number;
}

init()
{
	createdvars();
	level thread dvar_tracker();
	level thread init_anticheat();
	level thread init_hud();
	level thread init_camos();
	level thread init_monitor();

    if(DEBUG)
    {
        if( level.player_out_of_playable_area_monitor && IsDefined( level.player_out_of_playable_area_monitor ) )
            self notify( "stop_player_out_of_playable_area_monitor" );
        level.player_out_of_playable_area_monitor = 0;
        level.player_too_many_players_check = 0;
        setDvar("sv_cheats", 1);
    }

	level thread connected();

    if(isnuketown())
	{
		level thread checkpaplocation();
	}

    if(isstgame())
        return;

    if(ismob())
    {
        replaceFunc(getfunction("maps/mp/zm_alcatraz_sq", "setup_master_key"), ::setup_master_key);
        replaceFunc(getfunction("maps/mp/zm_alcatraz_weap_quest", "tomahawk_upgrade_quest"), ::tomahawk_fix, true);
    }
    flag_wait("initial_blackscreen_passed");

	replaceFunc(getfunction("maps/mp/zombies/_zm_magicbox", "treasure_chest_weapon_spawn"), ::treasure_chest_weapon_spawn);
}

connected()
{
	level endon("end_game");
	while(true)
	{
        level waittill("connecting", player);

        if(isstgame())
            return;

        player thread disconnect();
		player thread spawned();
		player thread reapply_character_on_spawn();
		player thread xoia_sync_start();
		if(isvictismap())
		{
			player thread bank();
			player thread award_permaperks_safe();
		}
        player waittill("spawned_player");
		{
			if(isburied())
			{
				if(!isdefined(player.watching_stats))
				{
					player.initial_stats = array();
					player thread watch_stat("springpad_zm");
					player thread watch_stat("turbine");
					player thread watch_stat("subwoofer_zm");
					player.watching_stats = true;
				}
			}
			if(isdierise())
			{
                if(!isdefined(player.watching_stats))
                {
				    player.initial_stats = array();
				    player thread watch_stat("springpad_zm");
				    player.watching_stats = true;
                }
			}
			if(ismob())
			{
			}
		}
	}
}

disconnect()
{
    self waittill("disconnect");
    self cache_current_tomahawk();
}

spawned()
{
	self endon("disconnect");
	self waittill("spawned_player");

    if(!isdefined(self.timer))
    {
        self thread timer();
        self thread timerlocation();
    }

	self iprintln("^5[^6" + PATCH_NAME + " ^7V^2" + VERSION + "^5]");
}

watch_stat(stat)
{
    level endon( "end_game" );
    self endon( "disconnect" );

    if (!isdefined(self.initial_stats[stat]))
        self.initial_stats[stat] = self getdstat( "buildables", stat, "buildable_pickedup" );

    while(true)
    {
        stat_number = self getdstat( "buildables", stat, "buildable_pickedup" );
        delta = stat_number - self.initial_stats[stat];

        if ( delta > 0 && stat_number > 0 )
        {
			level notify("stat_changed");
            self.initial_stats[stat] = stat_number;
            level.buildable_stats[stat] = level.buildable_stats[stat] + delta;
            for(i = 1; i > 0; i -= 0.02)
            {
                level.turbine_hud.alpha = i;
                level.subwoofer_hud.alpha = i;
                level.springpad_hud.alpha = i;
                wait 0.1;
            }
            level.turbine_hud.alpha = 0;
            level.subwoofer_hud.alpha = 0;
            level.springpad_hud.alpha = 0;
        }
        wait 0.1;
    }
}

change_player_model(desired_character)
{
    level endon("end_game");
    self endon("disconnect");

    // FIX (punto 5 del encargo): antes esta funcion cambiaba el modelo pero
    // no guardaba en ningun sitio que personaje habia elegido el jugador.
    // Al reaparecer (revive / nueva ronda) el juego resetea el modelo del
    // jugador al de por defecto y la seleccion se perdia. Guardamos el
    // valor en el propio jugador para poder reaplicarlo en cada respawn
    // (ver reapply_character_on_spawn() mas abajo).
    self.xoia_character = desired_character;

    switch(desired_character)
    {
        case MISTY:
            self setmodel( "c_zom_player_farmgirl_dlc1_fb" );
            self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
            self setviewmodel( "c_zom_farmgirl_viewhands" );
            break;
        case RUSSMAN:
            self setmodel( "c_zom_player_oldman_dlc1_fb" );
            self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
            self setviewmodel( "c_zom_oldman_viewhands" );
            break;
        case MARLTON:
            self setmodel( "c_zom_player_reporter_dlc1_fb" );
            self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
            self setviewmodel( "c_zom_reporter_viewhands" );
            break;
        case STUHLINGER:
            self setmodel( "c_zom_player_engineer_dlc1_fb" );
            self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
            self setviewmodel( "c_zom_engineer_viewhands" );
            break;
        case CDC:
            self setmodel("c_zom_player_cdc_fb");
            self setviewmodel("c_zom_suit_viewhands");
            break;
        case CIA:
            self setmodel("c_zom_player_cdc_fb");
            self setviewmodel("c_zom_suit_viewhands");
            break;
        case OLEARY:
            self setmodel( "c_zom_player_oleary_fb" );
            self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
            break;
        case DELUCA:
            self setmodel( "c_zom_player_deluca_fb" );
            self setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
            break;
        case HANDSOME:
            self setmodel( "c_zom_player_handsome_fb" );
            self setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
            break;
        case ARLINGTON:
            self setmodel( "c_zom_player_arlington_fb" );
            self setviewmodel( "c_zom_arlington_coat_viewhands" );
            break;
        case AFTERLIFE:
            self setmodel( "c_zom_player_handsome_fb" );
            self setviewmodel( "c_zom_ghost_viewhands" );
            break;
        case DEMPSEY:
            self setmodel( "c_zom_tomb_dempsey_fb" );
            self setviewmodel( "c_zom_dempsey_viewhands" );
            break;
        case NIKOLAI:
            self setmodel( "c_zom_tomb_nikolai_fb" );
            self setviewmodel( "c_zom_nikolai_viewhands" );
            break;
        case TAKEO:
            self setmodel( "c_zom_tomb_takeo_fb" );
            self setviewmodel( "c_zom_takeo_viewhands" );
            break;
        case RICHTOFEN:
            self setmodel( "c_zom_tomb_richtofen_fb" );
            self setviewmodel( "c_zom_richtofen_viewhands" );
            break;
    }
}

// FIX v2 (el jugador reporta que "al reaparecer nunca se devuelve el
// personaje"): la version anterior solo escuchaba "spawned_player" en
// bucle. Pero en el resto de Xoia.gsc, "spawned_player" SIEMPRE se usa con
// un unico waittill (linea 197 en connected(), y en spawned() mas abajo),
// nunca en bucle -> todo indica que en este mod solo se notifica UNA VEZ
// por jugador (el primer spawn de la partida), no en cada revive/ronda.
// Un jugador que muere del todo (se desangra sin que lo revivan) no
// "respawnea" hasta EMPEZAR LA SIGUIENTE RONDA -> ese es el punto real de
// reaparicion. Xoia.gsc ya usa "start_of_round" de forma fiable en varios
// sitios (busca "level waittill(\"start_of_round\")"), asi que lo usamos
// como segunda via, ademas de mantener el primer spawn por si acaso.
reapply_character_on_spawn()
{
    level endon("end_game");
    self endon("disconnect");

    // Primer spawn de la partida.
    self waittill("spawned_player");
    if(isdefined(self.xoia_character))
    {
        wait 0.05;
        self change_player_model(self.xoia_character);
    }

    // Cualquier respawn real (tras desangrarse sin revivir) ocurre al
    // empezar la ronda siguiente. Una revivida a mitad de ronda NO crea
    // una entidad nueva ni resetea el modelo, asi que no hace falta
    // escuchar nada para ese caso.
    for(;;)
    {
        level waittill("start_of_round");

        if(isdefined(self.xoia_character) && isalive(self))
        {
            wait 0.05;
            self change_player_model(self.xoia_character);
        }
    }
}

// FIX (no recuerda el personaje al empezar la partida): abre el menu
// invisible "XoiaSync" (ver optionsxoia.lua) nada mas terminar de cargar
// el jugador, replicando exactamente lo que hace el mod de referencia con
// "StratTesterPerkSync". Ese menu lee el dvar de perfil PERSISTIDO
// ("seta") del cliente y lo reenvia por SendMenuResponse, lo que hace que
// change_player_model() se ejecute automaticamente con el ultimo personaje
// que el jugador eligio, sin que tenga que abrir el menu a mano.
//
// AVISO SIN VERIFICAR: "self openmenu(...)" para forzar la apertura de un
// menu Lua desde GSC es una tecnica estandar en mods de zombies de T6,
// pero no he podido compilar/probar esto en tu entorno de Plutonium. Si al
// probarlo el menu invisible no llega a abrirse, dimelo: en optionsstrattester.lua
// no encontre el punto exacto donde se abre "StratTesterPerkSync" (no esta
// en los 3 archivos que me pasaste), asi que puede que tu base use un gancho
// distinto (por ejemplo, algo en un options.lua propio de Strat Tester) que
// tendria que revisar para replicarlo con precision.
xoia_sync_start()
{
    level endon("end_game");
    self endon("disconnect");

    flag_wait("initial_blackscreen_passed");
    self openmenu("XoiaSync");
}

set_exert_id()
{
    self endon("disconnect");
    wait_network_frame();
    self maps\mp\zombies\_zm_audio::setexertvoice(self.characterindex);
}

createdvars()
{
    createDvar("box", 1);
    createDvar("timer", 1);
    createDvar("splits", 0);

    enabledvarchangednotify("timer");
    enabledvarchangednotify("cg_drawfps");
    enabledvarchangednotify("chat");

    if (issurvivalmap())
    {
        createDvar("avg", 1);
        enabledvarchangednotify("avg");
        createDvar("papcamo", CAMO_GREEN_RUN);

        createDvar("boxhits", 1);
        enabledvarchangednotify("boxhits");
    }
    if (isvictismap())
    {
        createDvar("papcamo", CAMO_GREEN_RUN);
    }
    if (ismob())
    {
        createDvar("traptimer", 0);
        enabledvarchangednotify("traptimer");
        createDvar("papcamo", CAMO_MOB);
    }
    if (isorigins())
    {
        createDvar("papcamo", CAMO_ORIGINS);
    }
    if (isnuketown())
    {
        createDvar("forcepap", 0);
    }
}

createDvar(dvar, set)
{
    if (getDvar(dvar) == "")
        setDvar(dvar, set);
}

custom_pap_camo(weapon)
{
    if(!isdefined(self.pack_a_punch_weapon_options))
        self.pack_a_punch_weapon_options = [];

    smiley_face_reticle_index = 1;
    base = maps\mp\zombies\_zm_weapons::get_base_name(weapon);
    camo_index = 39;

    if(base == "rnma_upgraded_zm" || base == "rnma_zm" || base == "slowgun_upgraded_zm") camo_index = 39;
    else if(base == "mg08_upgraded_zm" || base == "mg08_zm" || base == "c96_upgraded_zm" || base == "c96_zm") camo_index = 40;
    else if (getDvar("papcamo") != "") camo_index = getDvarInt("papcamo");
    else if (level.script == "zm_prison") camo_index = 40;
    else if (level.script == "zm_tomb") camo_index = 45;

    lens_index = randomintrange(0, 6);
    reticle_index = randomintrange(0, 16);
    reticle_color_index = randomintrange(0, 6);
    plain_reticle_index = 16;
    r = randomint(10);
    use_plain = r < 3;

    if(base == "saritch_upgraded_zm")
        reticle_index = smiley_face_reticle_index;

    else if(use_plain)
        reticle_index = plain_reticle_index;

    scary_eyes_reticle_index = 8;
    purple_reticle_color_index = 3;
    if(reticle_index == scary_eyes_reticle_index)
        reticle_color_index = purple_reticle_color_index;

    letter_a_reticle_index = 2;
    pink_reticle_color_index = 6;
    if(reticle_index == letter_a_reticle_index)
        reticle_color_index = pink_reticle_color_index;

    letter_e_reticle_index = 7;
    green_reticle_color_index = 1;

    if(reticle_index == letter_e_reticle_index)
        reticle_color_index = green_reticle_color_index;


    if(!maps\mp\zombies\_zm_weapons::is_weapon_upgraded(weapon))
        return self calcweaponoptions(0, 0, 0, 0, 0);

    self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions(camo_index, lens_index, reticle_index, reticle_color_index);
    return self.pack_a_punch_weapon_options[weapon];
}

timer()
{
    level endon("end_game");
    self endon("disconnect");

    self.timer = newclienthudelem(self);
    self.timer.alpha = 1;
    self.timer.color = (1, 1, 1);
    self.timer.hidewheninmenu = true;
    self.timer.fontscale = 1.7;

    self thread round_timer();
    flag_wait("initial_blackscreen_passed");

    if(!isdefined(level.start_time))
    {
        self.timer settimerup(0);
        level.start_time = int(gettime() / 1000);
    }
    else
    {
        actual_time = int(gettime() / 1000);
        time_past = actual_time - level.start_time;
        self.timer settimerup(-time_past);
    }
}

round_timer()
{
    level endon("end_game");

    self.round_timer = newclienthudelem(self);
    self.round_timer.alpha = 1;
    self.round_timer.fontscale = 1.7;
    self.round_timer.color = (0.8, 0.8, 0.8);
    self.round_timer.hidewheninmenu = true;
    self.round_timer.x = self.timer.x;
    self.round_timer.y = self.timer.y + 15;
    flag_wait("initial_blackscreen_passed");
    while(true)
    {
        self.round_timer settimerup(0);
        level waittill("end_of_round");
        self.round_timer thread display_round_time((level.round_end_time - level.round_start_time) / 1000);
        level waittill("start_of_round");
    }
}

display_round_time(time)
{
    level endon("end_game");
    level endon("start_of_round");

    while (true)
    {
        // -0.1 avoids flickering
        self settimer(time - 0.1);
        wait 0.05;
    }
}

traptimer()
{
    level endon("end_game");

    level.traptimer = createserverfontstring( "objective", 1.4 );
    level.traptimer.alignx = "left";
    level.traptimer.aligny = "top";
    level.traptimer.horzalign = "user_left";
    level.traptimer.vertalign = "user_top";
    level.traptimer.x = -2;
    level.traptimer.y = 14;
    level.traptimer.fontscale = 1.4;
    level.traptimer.hidewheninmenu = true;
    level.traptimer.hidden = 0;
    level.traptimer.label = &"";

    while(true)
    {
        if(getDvarInt("traptimer"))
        {
            level waittill( "trap_activated" );
            if( level.trap_activated )
            {
                wait 0.1;
                level.traptimer.color = ( 0, 1, 0 );
                level.traptimer.alpha = 1;
                level.traptimer settimer( 25 );
                wait 25;
                level.traptimer settimer( 25 );
                level.traptimer.color = ( 1, 0, 0 );
                wait 25;
                level.traptimer.alpha = 0;
            }
        }
        level waittill("dvar_changed");
    }
}

timerlocation()
{
    level endon("end_game");
    self endon("disconnect");

    while(true)
    {
        switch(getDvarInt("timer"))
        {
            case TIMER_HIDE:
                self.timer.alpha = 0;
                self.round_timer.alpha = 0;
                break;
            case TIMER_TOP_RIGHT:
                self.timer.alignx = "right";
                self.timer.aligny = "top";
                self.timer.horzalign = "user_right";
                self.timer.vertalign = "user_top";
                self.timer.x = -1;
                self.timer.y = 13;
                self.timer.alpha = 1;
                self.round_timer.alpha = 1;
                if(getDvar("cg_drawFPS") != "Off")
                    self.timer.y += 6;
                if(getDvar("cg_drawFPS") != "Off" && GetDvar("language") == "japanese")
                    self.timer.y += 10;
                if(isdierise())
                    self.timer.y = 30;
                break;
            case TIMER_TOP_LEFT:
                self.timer.alignx = "left";
                self.timer.aligny = "top";
                self.timer.horzalign = "user_left";
                self.timer.vertalign = "user_top";
                self.timer.x = 1;
                self.timer.y = 0;
                self.timer.alpha = 1;
                self.round_timer.alpha = 1;
                if(isorigins()) self.timer.y = 45;
                if(issurvivalmap()) self.timer.y = 40;
                if(isdierise() && level.springpad_hud.alpha != 0) self.timer.y = 10;
                if(isburied() && level.springpad_hud.alpha != 0) self.timer.y = 35;
                break;
            case TIMER_MID_LEFT:
                self.timer.alignx = "left";
                self.timer.aligny = "top";
                self.timer.horzalign = "user_left";
                self.timer.vertalign = "user_top";
                self.timer.x = 1;
                self.timer.y = 250;
                self.timer.alpha = 1;
                self.round_timer.alpha = 1;
                break;
            case TIMER_AMMO:
                self.timer.alignx = "right";
                self.timer.aligny = "top";
                self.timer.horzalign = "user_right";
                self.timer.vertalign = "user_top";
                self.timer.x = -170;
                self.timer.y = 415;
                self.timer.alpha = 1;
                self.round_timer.alpha = 1;
                break;

            default: break;
        }
        self.round_timer.alignx = self.timer.alignx;
        self.round_timer.aligny = self.timer.aligny;
        self.round_timer.horzalign = self.timer.horzalign;
        self.round_timer.vertalign = self.timer.vertalign;
        self.round_timer.x = self.timer.x;
        self.round_timer.y = self.timer.y + 15;
        if(isdefined(level.traptimer))
        {
            level.traptimer.alignx = self.timer.alignx;
            level.traptimer.aligny = self.timer.aligny;
            level.traptimer.horzalign = self.timer.horzalign;
            level.traptimer.vertalign = self.timer.vertalign;
            level.traptimer.x = self.timer.x;
            level.traptimer.y = self.timer.y + 30;
        }

        wait 0.1;
        if(GetDvar("language") == "japanese")
        {
            self.timer.fontscale = 1.5;
            self.round_timer.fontscale = self.timer.fontscale;
        }
        level waittill("dvar_changed");
    }
}

fridgecase(wpn)
{
    if(level.round_number >= FRIDGE_AND_BANK_ROUND)
    {
        globalprint("Fridge not allowed after round 15");
        return;
    }

    self maps\mp\zombies\_zm_stats::clear_stored_weapondata();

    upgraded = IsSubStr(wpn, "+");

    weapon = get_weapon_key(wpn, upgraded, undefined);

    if (weapon == WEAPON_UNKNOWN)
    {
        globalprint("Unknown weapon ^1" + wpn);
        return;
    }
    if (weapon == WEAPON_NOT_PRESENT)
    {
        globalprint("The weapon '" + wpn + "' is not on this map");
        return;
    }
    if (weapon == WEAPON_NOT_IN_BOX)
    {
        globalprint("The weapon can not be in the box");
        return;
    }

    dw = weapondualwieldweaponname(weapon);
    alt = weaponaltweaponname(weapon);

    self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", weapon);
    self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", weaponclipsize(weapon));
    self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", weaponmaxammo(weapon));

    if (isdefined(alt) && alt != "")
    {
        // grenade launcher
        self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_name", alt);
        self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_clip", weaponclipsize(alt));
        self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_stock", weaponmaxammo(alt));
    }

    if (isdefined(dw) && dw != "")
    {
        self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "dw_name", dw);
        self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "lh_clip", weaponclipsize(dw));
    }

    name = get_weapon_display(weapon);
    globalprint(self.name + " fridge now contains " + name);
}

award_permaperks_safe()
{
    level endon("end_game");
    self endon("disconnect");

    if(level.round_number >= FRIDGE_AND_BANK_ROUND)
        return;

    while (!isalive(self))
        wait 0.05;

    wait 0.5;
    perks_to_process = [];

    perks_to_process[perks_to_process.size] = permaperk_array("revive");
    perks_to_process[perks_to_process.size] = permaperk_array("multikill_headshots");
    perks_to_process[perks_to_process.size] = permaperk_array("perk_lose");
    perks_to_process[perks_to_process.size] = permaperk_array("jugg", undefined, undefined, 15);
    perks_to_process[perks_to_process.size] = permaperk_array("flopper", array("zm_buried"));
    perks_to_process[perks_to_process.size] = permaperk_array("box_weapon", array("zm_highrise", "zm_buried"), array("zm_transit"));
    perks_to_process[perks_to_process.size] = permaperk_array("cash_back");
    perks_to_process[perks_to_process.size] = permaperk_array("sniper");
    perks_to_process[perks_to_process.size] = permaperk_array("insta_kill");
    perks_to_process[perks_to_process.size] = permaperk_array("double_points");

    foreach (perk in perks_to_process)
    {
        if( !(istranzit() && perk == permaperk_array("box_weapon", array("zm_highrise", "zm_buried"), array("zm_transit"))))
            self resolve_permaperk(perk);
        wait 0.05;
    }
    if(istranzit())
        level.pers_box_weapon_lose_round = 0;

    wait 0.5;
    self maps\mp\zombies\_zm_stats::uploadstatssoon();
}

permaperk_array(code, maps_award, maps_take, to_round)
{
    if (!isDefined(maps_award))
        maps_award = array("zm_transit", "zm_highrise", "zm_buried");
    if (!isDefined(maps_take))
        maps_take = [];
    if (!isDefined(to_round))
        to_round = 255;

    permaperk = [];
    permaperk["code"] = code;
    permaperk["maps_award"] = maps_award;
    permaperk["maps_take"] = maps_take;
    permaperk["to_round"] = to_round;

    return permaperk;
}

resolve_permaperk(perk)
{
    wait 0.05;

    perk_code = perk["code"];

    if (isround(perk["to_round"]))
        return;

    if (isinarray(perk["maps_award"], level.script) && !self.pers_upgrades_awarded[perk_code])
    {
        for (j = 0; j < level.pers_upgrades[perk_code].stat_names.size; j++)
        {
            stat_name = level.pers_upgrades[perk_code].stat_names[j];
            stat_value = level.pers_upgrades[perk_code].stat_desired_values[j];

            self award_permaperk(stat_name, perk_code, stat_value);
        }
    }

    if (isinarray(perk["maps_take"], level.script) && self.pers_upgrades_awarded[perk_code])
        self remove_permaperk(perk_code);
}

award_permaperk(stat_name, perk_code, stat_value)
{
    flag_set("permaperks_were_set");
    self.stats_this_frame[stat_name] = 1;
    self maps\mp\zombies\_zm_stats::set_global_stat(stat_name, stat_value);
    self playsoundtoplayer("evt_player_upgrade", self);
}

remove_permaperk(perk_code)
{
    self.pers_upgrades_awarded[perk_code] = 0;
    self playsoundtoplayer("evt_player_downgrade", self);
}

bank()
{
    flag_wait("initial_blackscreen_passed");
    if(level.round_number != 1) return;

    self.account_value = level.bank_account_max;
}

init_monitor()
{
    level thread monitor_log();
    level thread readchat();
    level thread readtwitchchat();
    level thread readconsole();
    level thread drops_grabbed();
    level thread monitor_round_loop();
    replacefunc(getfunction("maps/mp/zombies/_zm_powerups", "powerup_grab"), ::powerup_grab);

    flag_wait("initial_blackscreen_passed");

    level.game_start_time = int(gettime() / 1000);
    if(isorigins())
    {
        level thread track_templars();
        level thread track_panzers();
    }
    if(ismob()) level thread track_brutus();
}

monitor_log()
{
    // meter en el globalprint un notify para cunado escribe algo de los comandos
    level endon("end_game");

    f = fs_fopen(FILE_MONITOR, "write");
    fs_fclose(f);
    while(true)
    {
        level waittill("monitor_log", log);
        f = fs_fopen(FILE_MONITOR, "append");
        fs_writeline(f, log);
        fs_fclose(f);
    }
}

readtwitchchat()
{
    level endon("game_ended");

    while(true)
    {
        level waittill("new_twitch_message", message);
        msg = strtok(message, "|");
        thread commandHandler(msg[1], undefined, true);
    }
}

addCommands(commands, alias)
{
    if(!isdefined(alias))
        alias = false;

    if(!alias)
        foreach(command in commands)
            level.chatcommands[level.chatcommands.size] = "!" + command;
    else
        foreach(command in commands)
            level.chatcommandsaliases[level.chatcommandsaliases.size] = "!" + command;
}

readchat()
{
    level endon("end_game");

    if(!isdefined(level.chatcommands))
        level.chatcommands = [];
    if(!isdefined(level.chatcommandsaliases))
        level.chatcommandsaliases = [];
    // Hacer un tab con info:
    // Zombis esta ronda
    // Boxhits
    // NextSpecialRound
    // Ronda actual
    // Downs
    // Si se ha usado firstbox
    // SPH actual, Mejor SPH, SPH de la última ronda

    // Hacer un tab para mariconadas
    // cambiar de personaje
    // cambiar el camo
    // cambiar el timer
    // Activar el timer de trampa
    // Cambiar el backspeed
    // Forzar el pap en nuketown
    // Cambiar la llave en mob

    // Hacer un tab con los tiempos de la partida
    // misc
    addCommands(array("help", "dg", "backspeed", "boxhits", "boxtracker"), false);
    addCommands(array("bs", "bh", "bt"), true);

    // Timers
    addCommands(array("timer", "time", "times", "roundtime", "sph", "traptimer"), false);
    addCommands(array("t", "rt", "tt"), true);

    // special rounds
    addCommands(array("nextleapers", "leapers", "brutus", "panzers", "templars", "nextpanzer", "nexttemplars", "rounders", "nextbrutus"), false);
    addCommands(array("nl", "nextleaper", "nb", "nextbrutus", "np", "nt", "nexttemplar"), true);
    addCommands(array("frozen"), false);

    // Zombies
    addCommands(array("zombiecount", "totalzombiecount"), false);
    addCommands(array("zc", "tzc"), true);

    // Set-up
    addCommands(array("fridge", "key", "forcepap", "firstbox", "box"), false);
    addCommands(array("f", "fb"), true);

    // Cosmetic
    addCommands(array("character", "papcamo"), false);
    addCommands(array("c", "pap", "camo"), true);

    while (true) 
    {
        level waittill("say", message, player);
        thread commandHandler(message, player, false);
    }
}

readconsole()
{
    level endon("end_game");

    while (true) 
    {
        level waittill("dvar_changed", dvar, new);
        if(dvar != "chat")
            continue;

        thread commandHandler(new, undefined, false);
    }
}

commandHandler(org_message, player, twitch)
{
    setDvar("chat", "xxxxxxxxxxxx");
    if(!isdefined(player)) player = gethostplayer();
    if(!isdefined(twitch)) twitch = false;


    message = tolower(org_message);
    msg = strtok(message, " ");

    if(msg[0][0] != "!")
        return;

    if(!in_array(msg[0], level.chatcommands) && !in_array(msg[0], level.chatcommandsaliases))
    {
        globalprint("Unknown command ^1" + org_message + "^7. Try !help");
        return;
    }

    level notify("monitor_log", message);
    processCommand(msg, player, twitch);
}

processCommand(command, player, twitch)
{
    if(!twitch)
    {
        // This can not be used by twitch chat
        switch(command[0])
        {
            case "!help": helpcase(); break;

            case "!firstbox": case "!fb": fbcase(command); break;
            case "!box": boxcase(command[1]); break;
            case "!bt": case "!boxtracker": setDvar("boxhits", !getDvarInt("boxhits")); break;
            case "!character": case "!c": charactercase(player, command[1]); break;
            case "!forcepap": forcepapcase(); break;

            case "!timer": timercase(command[1]); break;
            case "!traptimer": case "!tt": traptimercase(); break;

            case "!papcamo": case "!pap": case "!camo": camo(command[1]); break;

            case "!fridge": case "!f": player fridgecase(command[1]); break;

            case "!key": keycase(command[1]); break;

            case "!bs": case "!backspeed": bscase(); break;

            default: break;
        }
    }
    switch(command[0])
    {
        case "!zc": case "zombiecount": print_zombies_at_round(command[1], twitch); break;
        case "!tzc": case "totalzombiecount": total_zombie_count(command[1], command[2], twitch); break;
        case "!dg": print_drops_grabbed(command[1], twitch); break;
        case "!bh": case "!boxhits": globalprint("Box hits: " + level.total_chest_accessed, twitch); break;


        case "!times": print_times(twitch); break;
        case "!rt": case "!roundtime": print_round_times(command[1], twitch); break;
        case "!t": case "!time": print_game_time(twitch); break;
        case "!sph": print_sph(command[1], twitch); break;

        case "!nb": case "!nextbrutus": next_special_round("Brutus", twitch); break;
        case "!nt": case "!nexttemplars": case "!nexttemplar": next_special_round("Templar", twitch); break;
        case "!np": case "!nextpanzer": next_special_round("Panzer", twitch); break;
        case "!nl": case "!nextleapers": case "!nextleaper": next_special_round("Leaper", twitch); break;

        case "!frozen": frozenrounds(twitch); break;

        case "!rounders": rounderscase(twitch); break;
        case "!brutus": special_rounds("Brutus", twitch); break;
        case "!templars": special_rounds("Templar", twitch); break;
        case "!panzers": special_rounds("Panzer", twitch); break;
        case "!leapers": special_rounds("Leaper", twitch); break;

        default: break;
    }
}

frozenrounds(twitch)
{
    if(!isorigins())
        return;

    globalprint("Small frozen rounds: 121, 123, 127, 129, 133, 135, 140,\n141, 143, 150, 152, 153, 154, 162+", twitch);
}

keycase(loc)
{
    if(IsSubStr(loc, "cafe") || IsSubStr(loc, "west"))
    {
        gethostplayer() maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat(STAT_KEY, 1, STAT_KEY_MAP);
        globalprint("Key override set to cafeteria, please restart the match");
    }
    else if(IsSubStr(loc, "war") || IsSubStr(loc, "east") || IsSubStr(loc, "spe"))
    {
        gethostplayer() maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat(STAT_KEY, 2, STAT_KEY_MAP);
        globalprint("Key override set to warden's office, please restart the match");
    }
    else if(IsSubStr(loc, "re"))
    {
        gethostplayer() maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat(STAT_KEY, 0, STAT_KEY_MAP);
        globalprint("Key override has been reseted, please restart the match");
    }
    else
        globalprint("Unknown location, please try with cafe, warden or reset");
}

setup_master_key()
{
    // Use the same stats as b2op for convinience
    switch (gethostplayer() maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(STAT_KEY, STAT_KEY_MAP))
    {
        case 1:
            level.is_master_key_west = 0;
            level notify("modded", "key");
            break;
        case 2:
            level.is_master_key_west = 1;
            level notify("modded", "key");
            break;
        default:
            level.is_master_key_west = randomintrange(0, 2);
    }

    setclientfield("fake_master_key", level.is_master_key_west + 1);

    if (level.is_master_key_west)
    {
        level thread [[getfunction("maps/mp/zm_alcatraz_sq", "key_pulley")]]("west");
        array_delete(getentarray("wires_pulley_east", "script_noteworthy"));
    }
    else
    {
        level thread [[getfunction("maps/mp/zm_alcatraz_sq", "key_pulley")]]("east");
        array_delete(getentarray("wires_pulley_west", "script_noteworthy"));
    }

    exploder(100 + level.is_master_key_west);
}

tomahawkcase()
{
    setDvar("tomahawk", !getDvarInt("tomahawk"));

    if(getDvarInt("tomahawk"))
        globalprint("Players will recieve an upgraded tomahawk when reconnected");
    else
        globalprint("Players will not recieve an upgraded tomahawk when reconnected");
}

forcepapcase()
{
    setDvar("forcepap", !getDvarInt("forcepap"));
    if(getDvarInt("forcepap"))
    {
        globalprint("Next restart the game will automatically restart for Pack-A-Punch and JUG location");
        globalprint("This might crash the game while restarting");
    }
    else
        globalprint("Pack-A-Punch and JUG location will not be manipulated");
}

charactercase(who, c)
{
    who change_player_model(c);
}

traptimercase()
{
    setDvar("traptimer", !getDvarInt("traptimer"));
}

timercase(pos)
{
    if(pos >= 0 && pos < 5)
        setDvar("timer", pos);
    else
        globalprint("Unkown position, please use 1, 2, 3, 4 or 0 to hide the timer");
}

bscase()
{
    if(getDvarInt("player_strafeSpeedScale") != 1) //	Console
    {
        setdvar("player_strafeSpeedScale", 1 );
        setdvar("player_backSpeedScale", 1 );
        globalprint("Changed player speed to match console");
    }
    else // Steam
    {
        setdvar("player_strafeSpeedScale", 0.9 );
        setdvar("player_backSpeedScale", 0.7 );
        globalprint("Changed player speed to match steam");
    }
}

print_game_time(twitch)
{
    time_now = int(gettime() / 1000);
    game_time = time_now - level.start_time;
    globalprint("Game time: " + int_to_time(game_time), twitch);
}

next_special_round(type, twitch)
{
    if(!isdefined(level.special_rounds[type]))
    {
        globalprint("Not tracking " + type, twitch);
        return;
    }
    if(SROUND_ARRAY(type).size == 0)
    {
        if(level.round_number > SROUND_ARRAY_START_LAST(type))
            globalprint(SROUND_ARRAY_COND(type), twitch);
        else
        {
            msg = "Next " + type + " round: ";
            for(i = 0; i < SROUND_ARRAY_START(type).size - 1; i++)
            {
                add = level.round_number < SROUND_ARRAY_START(type)[i];
                if(add)
                    msg += SROUND_ARRAY_START(type)[i] + ", ";
            }
            msg += SROUND_ARRAY_START_LAST(type);
            globalprint(msg, twitch);
        }
        return;
    }

    if(type == "Panzer" && level.players.size != 1)
    {
        globalprint("Next Panzer round: " + SROUND_ARRAY_LAST(type) + 3, twitch);
        return;
    }

    msg = "Next potential " + type + " rounds: ";
    for(j = 0; j < SROUND_ARRAY_INTERVAL(type).size - 1; j++)
    {
        add = level.round_number < SROUND_ARRAY_INTERVAL(type)[j] + SROUND_ARRAY_LAST(type);
        if(add)
            msg += SROUND_ARRAY_INTERVAL(type)[j] + SROUND_ARRAY_LAST(type) + ", ";
    }
    msg += SROUND_ARRAY_INTERVAL(type)[j] + SROUND_ARRAY_LAST(type);
    globalprint(msg, twitch);
}

print_drops_grabbed(round, twitch)
{
    if(!isdefined(round))
        rnd = level.round_number;
    else
        rnd = string_to_float(round);

    if(rnd > level.round_number)
        globalprint("You haven't reached round " + rnd + " yet.", twitch);
    else
        globalprint("Drops grabbed on round " + rnd + ": " + level.drops_grabbed[rnd], twitch);
}

drops_grabbed()
{
    level.drops_grabbed = array();  
    for(i = 0; i < 300; i++)
        level.drops_grabbed [i] = 0;
    while(true)
    {
        level waittill_any("powerup_grabbed");
        level.drops_grabbed[level.round_number]++;
    }
}

print_zombies_at_round(round, twitch)
{
    if(!isdefined(round))
        rnd = level.round_number;
    else
        rnd = string_to_float(round);

    zombies = zombies_at_round(rnd);
    health = zombies_health_at_round(rnd);
    globalprint("Zombies at round " + rnd + ": " + zombies + ", horedes: " + zombies / 24 + ", health: " + health, twitch);
}

print_sph(round, twitch)
{
    rnd = string_to_float(round);
    globalprint("SPH on round " + rnd + ": " + level.round_times[rnd - 1] / (zombies_at_round(rnd) / 24), twitch);
}

zombies_health_at_round(round)
{
    if(!isdefined(round))
        rnd = level.round_number;
    else
        rnd = string_to_float(round);

    if(rnd < 10)
        return rnd * 100 + 50;

    health = 950;
    for(i = 9; i < rnd; i++)
    {
        if(i >= 162)
            return health;

        health *= 1.1;
    }

    return health;
}

zombies_at_round(round)
{
    if(!isdefined(round))
        rnd = level.round_number;
    else
        rnd = string_to_float(round);

    zombies1p = array(6, 8, 13, 18, 24, 27, 28, 28, 29);
    zombies2p = array(7, 9, 15, 21, 27, 31, 32, 33, 34);
    zombies3p = array(9, 10, 18, 25, 32, 38, 40, 43, 45);
    zombies4p = array(10, 12, 21, 29, 37, 45, 49, 52, 56);
    if(rnd < 10)
    {
        if(level.players.size == 1) return zombies1p[rnd - 1];
        if(level.players.size == 2) return zombies2p[rnd - 1];
        if(level.players.size == 3) return zombies3p[rnd - 1];
        if(level.players.size == 4) return zombies4p[rnd - 1];
    }

    switch(level.players.size)
    {
        case 1: return int(0.09 * rnd * rnd + 24);
        case 2: return int(0.09 * 2 * rnd * rnd + 24);
        case 3: return int(0.09 * 4 * rnd * rnd + 24);
        case 4: return int(0.09 * 6 * rnd * rnd + 24);
    }
}

print_round_times(round, twitch)
{
    if(!isdefined(round))
        rnd = level.round_number;
    else
        rnd = string_to_float(round);
    if(rnd <= level.round_number)
    {
        if (rnd == 1 && level.round_number == 1)
            globalprint("Round time: " + int_to_time(int(gettime() / 1000) - level.start_time), twitch);
        else if(rnd == level.round_number)
            globalprint("Round time: " + int_to_time(int(gettime() / 1000) - level.round_start_time / 1000), twitch);
        else
            globalprint("Round time on " + rnd + ": " + int_to_time(level.round_times[rnd - 1]), twitch);
    }
    else
        globalprint("You havent reach round " + rnd + " yet.", twitch);
}

monitor_round_loop()
{
    level endon("end_game");
    level.round_times = array();
    level.round_total_time = array();

    if(isdierise())
    {
        level.special_rounds["Leaper"] = array();
        SROUND_ARRAY("Leaper") = array();
        SROUND_ARRAY_COND("Leaper") = LEAPERS_COND;
        SROUND_ARRAY_INTERVAL("Leaper") = LEAPERS_INTERVAL;
        SROUND_ARRAY_START("Leaper") = LEAPERS_START;

        while(true)
        {
            level waittill("start_of_round");
            level.round_start_time = gettime();
            level.round_total_time[level.round_total_time.size] = (level.round_start_time / 1000 - level.game_start_time);

            if(flag("leaper_round")) SROUND_ARRAY_NEW("Leaper") = level.round_number;
            level waittill("end_of_round");

            level.round_end_time = gettime();
            level.round_times[level.round_times.size] = (level.round_end_time - level.round_start_time) / 1000;
        }
    }

    while(true)
    {
        level waittill("start_of_round");
        level.round_start_time = gettime();
        level.round_total_time[level.round_total_time.size] = (level.round_start_time / 1000 - level.game_start_time);

        level waittill("end_of_round");

        level.round_end_time = gettime();
        level.round_times[level.round_times.size] = (level.round_end_time - level.round_start_time) / 1000;
    }
}

track_brutus()
{
    level endon("end_game");
    level.special_rounds["Brutus"] = array();
    SROUND_ARRAY("Brutus") = array();
    SROUND_ARRAY_COND("Brutus") = BRUTUS_COND;
    SROUND_ARRAY_INTERVAL("Brutus") = BRUTUS_INTERVAL;
    SROUND_ARRAY_START("Brutus") = BRUTUS_START;

    while(true)
    {
        level waittill("brutus_spawned", brutus);

        if(brutus get_current_zone() == "zone_golden_gate_bridge")
            continue;

        SROUND_ARRAY_NEW("Brutus") = level.round_number;
        level waittill("end_of_round");
    }
}

track_templars()
{
    level endon("end_game");

    if(isdefined(level.special_rounds["Templar"]))
        return;

    level.special_rounds["Templar"] = array();
    SROUND_ARRAY("Templar") = array();
    SROUND_ARRAY_COND("Templar") = TEMPLAR_COND;
    SROUND_ARRAY_INTERVAL("Templar") = TEMPLAR_INTERVAL;
    SROUND_ARRAY_START("Templar") = TEMPLAR_START;

    while(true)
    {
        flag_wait("recapture_event_in_progress");
        SROUND_ARRAY_NEW("Templar") = level.round_number;
        flag_waitopen("recapture_event_in_progress"); 
    }
}

track_panzers()
{
    level endon("end_game");
    level.special_rounds["Panzer"] = array();
    SROUND_ARRAY("Panzer") = array();
    SROUND_ARRAY_COND("Panzer") = PANZER_COND;
    SROUND_ARRAY_INTERVAL("Panzer") = PANZER_INTERVAL;
    SROUND_ARRAY_START("Panzer") = PANZER_START;

    while(true)
    {
        level waittill( "spawn_mechz" );
        SROUND_ARRAY_NEW("Panzer") = level.round_number;
        level waittill("end_of_round");
    }
}

int_to_time(duration)
{
    time_string = "";
    total_sec = int(duration);
    total_min = int(total_sec / 60);
    total_hours = int(total_min / 60);
    remaining_sec = int(total_sec % 60);
    remaining_min = int(total_min % 60);

    if(total_hours > 0)
    {
        if(total_hours <= 9 && total_hours != 0) {time_string += "0" + total_hours + ":";}
        if(total_hours > 9) {time_string += total_hours + ":";}
        if(remaining_min <= 9) {time_string += "0" + remaining_min + ":";}
        if(remaining_min > 9) {time_string += remaining_min + ":";}
        if(remaining_sec <= 9) {time_string += "0" + remaining_sec;}
        return time_string;
    }
    else
    {
        if(total_min > 0)
        {
            if(remaining_min < 9 && remaining_sec < 9) {time_string = "0" + remaining_min + ":" + "0" + remaining_sec; return time_string;}
            if(remaining_min < 9) {time_string = "0" + remaining_min + ":" + remaining_sec; return time_string;}
            if(remaining_sec < 9) {time_string = remaining_min + ":" + "0" + remaining_sec; return time_string;}
            time_string = remaining_min + ":" + remaining_sec; return time_string;
        }
        else
        {
            if(remaining_sec <= 9) {time_string = "0:0" + remaining_sec; return time_string;}
            time_string = "0:" + remaining_sec; return time_string;
        }
    }
}

print_times(twitch)
{
    rnd = level.round_number;

    if(rnd < 5)
        return;

    msg = "Times: ";
    count = 0;

    step = 5;

    if(rnd >= 70)
        step = 10;

    for(i = step; i <= rnd; i += step)
    {
        if(isdefined(level.round_total_time[i - 1]))
        {
            msg += "[" + i + "]: " + int_to_time(level.round_total_time[i - 1]);
            count++;

            if(count == 4)
            {
                globalprint(msg, twitch);
                msg = "Times: ";
                count = 0;
            }
            else
                msg += "\t";
        }
    }

    if(count > 0)
        globalprint(msg, twitch);
}

total_zombie_count(iz, dr, twitch)
{
    iz = string_to_float(iz);
    if(isdefined(dr))
        dr = string_to_float(dr);
    zm = 0;
    if(!isdefined(dr))
        for(i = 1; i <= iz; i++)
            zm+= zombies_at_round(i);
    else
        if(iz > dr) return;
        else
            for(i = iz; i <= dr; i++)
                zm+= zombies_at_round(i);
    if(!isdefined(dr))
        globalprint("Zombies from round 1 to round " + iz + ": " + zm, twitch);
    else
        globalprint("Zombies from round " + iz + " to round " + dr + ": " + zm, twitch);
}

rounderscase(twitch)
{
    if(isorigins())
    {
        rounders("Panzer", twitch);
        rounders("Templar", twitch);
    }
    if(isdierise())
        rounders("Leaper", twitch);
    if(ismob())
        rounders("Brutus", twitch);
    if(istranzit())
        rounders("Avogadro", twitch);
}

rounders(type, twitch)
{
    if(!isdefined(level.special_rounds[type]))
    {
        globalprint("Not tracking " + type, twitch);
        return;
    }

    if(SROUND_ARRAY(type).size < 2)
    {
        globalprint("No " + type + " rounders so far", twitch);
        return;
    }

    intervals = level.special_rounds[type]["freq"];

    counts = [];
    total = 0;
    weighted = 0;
    forced = 0;

    for(i = 0; i < intervals.size; i++)
        counts[i] = 0;

    for(i = 0; i < SROUND_ARRAY(type).size - 1; i++)
    {
        diff = SROUND_ARRAY(type)[i + 1] - SROUND_ARRAY(type)[i];
        found = false;

        for(j = 0; j < intervals.size; j++)
        {
            if(diff == intervals[j])
            {
                counts[j]++;
                total++;
                weighted += diff;
                found = true;
                break;
            }
        }

        if(!found)
            forced++;
    }

    avg = (total > 0) ? weighted / total : 0;

    msg = type + " rounders: ";

    for(i = 0; i < intervals.size; i++)
        msg += intervals[i] + " [" + counts[i] + "] ";

    msg += "avg [" + avg + "]";

    if(forced != 0)
        msg += ", forced [" + forced + "]";

    globalprint(msg, twitch);
}

special_rounds(type, twitch)
{
    if(!isdefined(level.special_rounds[type]))
    {
        globalprint("Not Tracking " + type, twitch);
        return;
    }
    if(SROUND_ARRAY(type).size == 0)
    {
        globalprint("No " + type + " rounds so far", twitch);
        return;
    }

    msg = type + " rounds: ";

    for(i = 0; i < SROUND_ARRAY(type).size; i++)
    {
        if(!isdefined(SROUND_ARRAY(type)[i])) 
            continue;

        msg += SROUND_ARRAY(type)[i];

        is_last_in_chunk = (i == 9) || (i > 9 && (i - 9) % 15 == 0);
        is_last_in_array = (i == SROUND_ARRAY(type).size - 1);

        if(is_last_in_chunk || is_last_in_array)
        {
            msg += "\n"; 
        }
        else
        {
            msg += ", ";
        }
    }

    globalprint(msg, twitch);
}

helpcase()
{
    i = 0;
    while (i < level.commands.size)
    {
        text = "";
        for (j = 0; j < 12; j++)
        {
            if (!isdefined(level.commands[i + j]))
                break;

            if (j > 0)
                text += " ";

            text += level.commands[i + j];
        }

        globalprint(text);
        i += 12;
        wait 0.1;
    }
}

globalprint(message, twitch)
{
    if(!isdefined(twitch))
        twitch = false;

    foreach(player in level.players)
        player iprintln("^5[^6"+  PATCH_NAME + "^5]^7 " + message);

    if(twitch && message[0] != "!")
        level notify("send_to_twitch", message);
}

in_array(data, array)
{
    foreach(element in array)
        if(element == data)
            return true;
    return false;
}

fbcase(msg)
{
    if(!isdefined(level.force_weapons))
        level.force_weapons = array();

    if(!is_firstbox_allowed(true))
        return;

    added_weapons = false;

    // msg[0] = !fb 

    if(!isdefined(msg[1]))
    {
        globalprint(get_current_weapons_string());
        return;
    }

    if(msg[1] == "clear")
    {
        globalprint("Forced weapons cleared");
        level.force_weapons = array();
        return;
    }

    for(i = 1; isdefined(msg[i]); i++)
    {
        weapon = get_weapon_key(msg[i], false);

        if (weapon == WEAPON_UNKNOWN)
        {
            globalprint("Unknown weapon ^1" + msg[i]);
            continue;
        }
        if (weapon == WEAPON_NOT_PRESENT)
        {
            globalprint("The weapon '" + msg[i] + "' is not on this map");
            continue;
        }
        if (weapon == WEAPON_NOT_IN_BOX)
        {
            globalprint("The weapon can not be in the box");
            return;
        }
        added_weapons = true;
        level.force_weapons[level.force_weapons.size] = weapon;
    }

    if(added_weapons)
    {
        level notify("modded", "fb");
        globalprint(get_current_weapons_string());
        return;
    }
}

get_current_weapons_string()
{
    ws = "";
    if (level.force_weapons.size > 0)
    {
        for(i = 0; i < level.force_weapons.size; i++)
        {
            ws += get_weapon_display(level.force_weapons[i]);
            if (i < level.force_weapons.size - 1)
                ws += ", ";
        }
    }

    if(ws != "")
        return ("Current weapons in the box: " + ws);

    return ("There are no forced weapons");
}

get_weapon_key(weapon, upgraded, verifier)
{
    weapon_code = WEAPON_UNKNOWN;
    if(IsSubStr(weapon, "mk1") || IsSubStr(weapon, "ray"))
        weapon_code = "ray_gun";
    if(IsSubStr(weapon, "mk2"))
        weapon_code = "raygun_mark2";
    if(IsSubStr(weapon, "mon"))
        weapon_code = "cymbal_monkey";
    if(IsSubStr(weapon, "emp") || IsSubStr(weapon, "pem"))
        weapon_code = "emp_grenade";
    if(IsSubStr(weapon, "time"))
        weapon_code = "time_bomb";
    if(IsSubStr(weapon, "sli"))
        weapon_code = "slipgun";
    if(IsSubStr(weapon, "blu") || IsSubStr(weapon, "gat"))
        weapon_code = "blundergat";
    if(IsSubStr(weapon, "para"))
        weapon_code = "slowgun";
    if(IsSubStr(weapon, "ak47"))
        weapon_code = "ak47";
    if(IsSubStr(weapon, "an94"))
        weapon_code = "an94";
    if(IsSubStr(weapon, "gal"))
        weapon_code = "galil";
    if(IsSubStr(weapon, "hamr"))
        weapon_code = "hamr";
    if(IsSubStr(weapon, "m27"))
        weapon_code = "hk416";
    if(IsSubStr(weapon, "bk") || IsSubStr(weapon, "bal"))
        weapon_code = "knife_ballistic";
    if(IsSubStr(weapon, "wm") || IsSubStr(weapon, "war"))
        weapon_code = "m32";
    if(IsSubStr(weapon, "rpd"))
        weapon_code = "rpd";
    if(IsSubStr(weapon, "scar"))
        weapon_code = "scar";
    if(IsSubStr(weapon, "ak74"))
        weapon_code = "ak74u";
    if(IsSubStr(weapon, "16"))
        weapon_code = "m16";
    if(IsSubStr(weapon, "an") || IsSubStr(weapon, "94"))
        weapon_code = "an94";
    if(IsSubStr(weapon, "16"))
        weapon_code = "m16";
    if(IsSubStr(weapon, "mp5") || IsSubStr(weapon, "mp5"))
        weapon_code = "mp5k";

    if(weapon_code == WEAPON_UNKNOWN)
        return WEAPON_UNKNOWN;


    if(upgraded)
    {
        if(weapon_code == "m16")
            weapon_code += "_gl";
        weapon_code += "_upgraded";
    }

    weapon_code += "_zm";

    if(weapon_code == "an94_upgraded_zm")
        weapon_code += "+mms";

    if (isdefined(verifier))
        weapon_code = [[verifier]](weapon_code);

    return weapon_code;
}

get_weapon_display(weapon)
{
    if (weapon == "emp_grenade_zm")
    {
        if(getDvar("language") == "spanish")
            return "Granadas PEM";
        return "Emp Grenade";
    }

    if (weapon == "cymbal_monkey_zm")
    {
        if(getDvar("language") == "spanish")
            return "Monos";

        return "Cymbal Monkey";
    }
    return maps\mp\zombies\_zm_weapons::get_weapon_display_name(weapon);
}

// basic_verifier(code)
// {
//     if(!isdefined(level.zombie_weapons[code]))
//         return WEAPON_NOT_PRESENT;
//
//     if(!level.zombie_weapons[code].is_in_box)
//         return WEAPON_NOT_IN_BOX;
// }

boxcase(location)
{
    if(!is_boxmove_allowed(true))
        return;

    if(!ismob() && !isnuketown() && !isorigins() && !istown())
    {
        globalprint("Unable to change box location in this map");
        return;
    }

    chest = undefined;
    chest_name = undefined;
    if(ismob())
    {
        if(IsSubStr(location, "cafe"))
        {
            chest = "cafe_chest";
            chest_name = "cafeteria";
        }
        else if(IsSubStr(location, "war") || IsSubStr(location, "spe") || IsSubStr(location, "off"))
        {
            chest = "start_chest";
            chest_name = "wardens office";
        }
        else
        {
            globalprint("Unknow box location, available locations: cafe, warden");
            return;
        }
    }

    if(isnuketown())
    {
        if(IsSubStr(location, "gre"))
        {
            chest = "start_chest1";
            chest_name = "green house";
        }
        else if(IsSubStr(location, "ye"))
        {
            chest = "start_chest2";
            chest_name = "yellow house";
        }
        else
        {
            globalprint("Unkown box location, available locations: green, yellow");
            return;
        }
    }

    if(isorigins())
    {
        if(IsSubStr(location, "2"))
        {
            chest = "bunker_tank_chest";
            chest_name = "generator 2";
        }
        else if(IsSubStr(location, "3"))
        {
            chest = "bunker_cp_chest";
            chest_name = "generator 3";
        }
        else
        {
            globalprint("Unkown box location, available locations: gen2, gen3");
            return;
        }
    }

    if(istown())
    {
        if(IsSubStr(location, "dt") || IsSubStr(location, "cage") || IsSubStr(location, "double"))
        {
            chest = "town_chest_2";
            chest_name = "double tap";
        }
        else if(IsSubStr(location, "qr") || IsSubStr(location, "quick"))
        {
            chest = "town_chest";
            chest_name = "quick revive";
        }
        else
        {
            globalprint("Unkown box location, available locations: dt, qr");
            return;
        }
    }

    current_location = get_current_box_location();

    if(isdefined(chest) && current_location != chest)
    {
        globalprint("Moving chest to " + chest_name);
        boxmove(chest);
    }
    else
        globalprint("The chest is already at " + chest_name);
}

get_current_box_location()
{
    foreach(chest in level.chests)
        if(!chest.hidden)
            return chest.script_noteworthy;
}

boxmove( location )
{
    if ( isDefined( level._zombiemode_custom_box_move_logic ) )
        kept_move_logic = level._zombiemode_custom_box_move_logic;

    level._zombiemode_custom_box_move_logic = ::force_next_location;

    foreach ( chest in level.chests )
    {
        if ( !chest.hidden && chest.script_noteworthy == location )
        {
            if ( isDefined( kept_move_logic ) )
                level._zombiemode_custom_box_move_logic = kept_move_logic;
            return;
        }
        if ( !chest.hidden )
        {
            level.chest_min_move_usage = 8;
            level.chest_name = location;

            flag_set( "moving_chest_now" );
            chest thread fast_chest_move();

            wait 0.05;
            level notify( "weapon_fly_away_start" );
            wait 0.05;
            level notify( "weapon_fly_away_end" );

            break;
        }
    }

    while ( flag( "moving_chest_now" ) )
        wait 0.05;

    if ( isDefined( kept_move_logic ) )
        level._zombiemode_custom_box_move_logic = kept_move_logic;

    if ( isDefined( level.chest_name ) && isDefined( level.dig_magic_box_moved ) )
        level.dig_magic_box_moved = 0;

    level.chest_min_move_usage = 4;
}

fast_chest_move()
{
    if ( isdefined( self.zbarrier ) )
        self hide_chest( 1 );

    level.verify_chest = 0;

    if ( isdefined( level._zombiemode_custom_box_move_logic ) )
        [[ level._zombiemode_custom_box_move_logic ]]();
    else
        default_box_move_logic();

    if ( isdefined( level.chests[level.chest_index].box_hacks["summon_box"] ) )
        level.chests[level.chest_index] [[ level.chests[level.chest_index].box_hacks["summon_box"] ]]( 0 );

    playfx( level._effect["poltergeist"], level.chests[level.chest_index].zbarrier.origin );
    level.chests[level.chest_index] show_chest();
    flag_clear( "moving_chest_now" );
    self.zbarrier.chest_moving = 0;
}

force_next_location()
{
    for (i = 0; i < level.chests.size; i++)
        if (level.chests[i].script_noteworthy == level.chest_name)
            level.chest_index = i;
}

camo(str)
{
    str = tolower(str);
    if(str == "help")
    {
        if(isburied())
            globalprint("Available camos: Green Run, Burning Embers, Aqua, Breach, Coyote, Glam, None");
        else if(isorigins())
            globalprint("Available camos: Green Run, Burning Embers, Mob, Aqua, Breach, Coyote, Glam, Origins, None");
        else if(ismob())
            globalprint("Available camos: Green Run, Burning Embers, None");
        else
            globalprint("Available camos: Green Run, None");

        return;
    }

    switch(str)
    {
        case "1": case "none": case "no": setDvar("papcamo", 1); globalprint("Pack a punch camo removed"); break;
        case "40": case "mob": case "burning embers": case "burningembers": case "burning": case "motd":
                                          if(isorigins() || isburied() || ismob())
                                          {
                                              setDvar("papcamo", CAMO_MOB);
                                              globalprint("Pack-A-Punch camo changed to Burning Embers");
                                          } 
                                          else globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help");
                                          break;
        case "39": case "greenrun":
                                          setDvar("papcamo", CAMO_GREEN_RUN);
                                          globalprint("Pack-A-Punch camo changed to Green Run");
                                          break;
        case "41": case "aqua": 
                                          if(isorigins() || isburied())
                                          {
                                              setDvar("papcamo", CAMO_AQUA );
                                              globalprint("Pack a punch camo changed to Aqua");
                                          }
                                          else globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help");
                                          break;
        case "42": case "breach":
                                          if(isburied() || isorigins())
                                          {
                                              setDvar("papcamo", CAMO_BREACH);
                                              globalprint("Pack-A-Punch camo changed to Breach");
                                          }
                                          else globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help");
                                          break;
        case "43": case "coyote":
                                          if(isburied() || isorigins())
                                          {
                                              setDvar("papcamo", CAMO_COYOTE);
                                              globalprint("Pack-A-Punch camo changed to Coyote");
                                          }
                                          else globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help");
                                          break;
        case "44": case "glam":
                                          if(isburied() || isorigins())
                                          {
                                              setDvar("papcamo", CAMO_GLAM);
                                              globalprint("Pack-A-Punch camo changed to Glam");
                                          }
                                          else globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help");
                                          break;
        case "45": case "origins":
                                          if(isorigins())
                                          {
                                              setDvar("papcamo", CAMO_ORIGINS);
                                              globalprint("Pack-A-Punch camo changed to Ice Crystal");
                                          }
                                          else globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help");
                                          break;
        default: globalprint("Unable to switch Pack-A-Punch camo, try !papcamo help"); break;
    }
}

checkpaplocation()
{
    if(isstgame())
        return;
    if(getDvarInt("forcepap"))
    {
        wait 1;
        if(level.players.size > 1)
            wait 4;
        pap = getent( "specialty_weapupgrade", "script_noteworthy" );
        jug = getent( "vending_jugg", "targetname" );
        if(pap.origin[0] > -1700 || jug.origin[0] > -1700) level.players[0] notify ("menuresponse", "", "restart_level_zm");
    }
}

displayBoxHits()
{
    level endon("end_game");

    level.boxhits = createserverfontstring( "objective", 1.4 );
    level.boxhits.hidewheninmenu = true;
    level.boxhits.y = 0;
    level.boxhits.x = 0;
    level.boxhits.alignx = "center";
    level.boxhits.horzalign = "user_center";
    level.boxhits.vertalign = "user_top";
    level.boxhits.aligny = "top";
    level.boxhits.alpha = 0;
    level.boxhits setvalue(0);
    if(issurvivalmap())
    {
        level.total_chest_accessed_mk2 = 0;
        level.total_chest_accessed_ray = 0;
        level.boxhits.alignx = "left";
        level.boxhits.horzalign = "user_left";
        level.boxhits.x = 0;
        level.boxhits.alpha = 1;
    }

    flag_wait("initial_blackscreen_passed");

    while(!isdefined(level.total_chest_accessed) || !isdefined(level.chest_accessed))
        wait 0.1;


    while(true)
    {
        wait 0.1;
        level waittill("box_spin_done");
        level.total_chest_accessed++;

        level.boxhits setvalue(level.total_chest_accessed);

        if(!issurvivalmap())
        {
            for(i = 1; i > 0.1; i -= 0.02)
            {
                level.boxhits.alpha = i;
                wait 0.1;
            }
            level.boxhits.alpha = 0;
        }
    }
}

raygunDisplay()
{
    level endon("end_game");

    level.total_chest_accessed_ray = 0;
    level.total_chest_accessed_mk2 = 0;
    level.total_mk2 = 0;
    level.total_ray = 0;

    level.total_ray_display = createserverfontstring( "objective", 1.3 );
    level.total_ray_display .hidewheninmenu = true;
    level.total_ray_display.y = 26;
    level.total_ray_display.x = 0;
    level.total_ray_display.alignx = "left";
    level.total_ray_display.horzalign = "user_left";
    level.total_ray_display.vertalign = "user_top";
    level.total_ray_display.aligny = "top";
    level.total_ray_display.alpha = 1;

    level.total_mk2_display = createserverfontstring( "objective", 1.3 );
    level.total_mk2_display.hidewheninmenu = true;
    level.total_mk2_display.y = 14;
    level.total_mk2_display.x = 0;
    level.total_mk2_display.alignx = "left";
    level.total_mk2_display.horzalign = "user_left";
    level.total_mk2_display.vertalign = "user_top";
    level.total_mk2_display.aligny = "top";
    level.total_mk2_display.alpha = 1;

    level.total_ray_display setvalue(0);
    level.total_mk2_display setvalue(0);

    if(getDvarInt("avg"))
    {
        level.total_mk2_display.label = &"^3Mark 2 AVG: ^5";
        level.total_ray_display.label = &"^3Raygun AVG: ^5";
    }
    else
    {
        level.total_mk2_display.label = &"^3Total Mark 2: ^5";
        level.total_ray_display.label = &"^3Total Raygun: ^5";
    }

    while(true)
    {
        level waittill_any("box_spin_done", "dvar_changed");
        level.total_mk2_display.alpha = getDvarInt("boxhits");
        level.total_ray_display.alpha = getDvarInt("boxhits");
        level.boxhits.alpha = getDvarInt("boxhits");

        if(getDvarInt("avg"))
        {
            level.total_mk2_display.label = &"^3Mark 2 AVG: ^5";
            level.total_ray_display.label = &"^3Raygun AVG: ^5";
            if(level.total_mk2 != 0) level.total_mk2_display setvalue(level.total_chest_accessed_mk2 / level.total_mk2);
            if(level.total_ray != 0) level.total_ray_display setvalue(level.total_chest_accessed_ray / level.total_ray);
        }
        else
        {
            level.total_mk2_display.label = &"^3Total Mark 2: ^5";
            level.total_ray_display.label = &"^3Total Raygun: ^5";
            level.total_mk2_display setvalue(level.total_mk2);
            level.total_ray_display setvalue(level.total_ray);
        }
    }
}

getForceWeapon()
{
    if(!isdefined(level.force_weapons))
        return "no_weapon";
    if(level.force_weapons[0].size == 0)
        return "no_weapon";

    w = level.force_weapons[0];

    level.force_weapons = array_remove_at(level.force_weapons, 0);

    return w;
}

array_remove_at(array, index)
{
    if(!isdefined(index))
        index = array.size;

    new_array = array();
    for(i = 0; i < array.size; i++)
    {
        if(i != index)
            new_array[new_array.size] = array[i];
    }

    return new_array;
}

treasure_chest_weapon_spawn( chest, player, respin )
{
    if ( isdefined( level.using_locked_magicbox ) && level.using_locked_magicbox )
    {
        self.owner endon( "box_locked" );
        self thread maps\mp\zombies\_zm_magicbox_lock::clean_up_locked_box();
    }

    self endon( "box_hacked_respin" );
    self thread clean_up_hacked_box();
    assert( isdefined( player ) );
    self.weapon_string = undefined;
    modelname = undefined;
    rand = undefined;
    number_cycles = 40;

    if ( isdefined( chest.zbarrier ) )
    {
        if ( isdefined( level.custom_magic_box_do_weapon_rise ) )
            chest.zbarrier thread [[ level.custom_magic_box_do_weapon_rise ]]();
        else
            chest.zbarrier thread magic_box_do_weapon_rise();
    }

    for ( i = 0; i < number_cycles; i++ )
    {
        if ( i < 20 )
        {
            wait 0.05;
            continue;
        }

        if ( i < 30 )
        {
            wait 0.1;
            continue;
        }

        if ( i < 35 )
        {
            wait 0.2;
            continue;
        }

        if ( i < 38 )
            wait 0.3;
    }

    if ( isdefined( level.custom_magic_box_weapon_wait ) )
        [[ level.custom_magic_box_weapon_wait ]]();

    if ( isdefined( player.pers_upgrades_awarded["box_weapon"] ) && player.pers_upgrades_awarded["box_weapon"] )
        rand = maps\mp\zombies\_zm_pers_upgrades_functions::pers_treasure_chest_choosespecialweapon( player );
    else
        rand = treasure_chest_chooseweightedrandomweapon( player );

    // FORCE WEAPONS

    if (!isround(MAX_FB_ROUND))
    {
        force_weapon = getForceWeapon();

        if(force_weapon != "no_weapon")
            rand = force_weapon;
    }

    pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

    if(issurvivalmap())
    {
        if(treasure_chest_canplayerreceiveweapon( player, "ray_gun_zm", pap_triggers ))
            level.total_chest_accessed_ray++;

        if(treasure_chest_canplayerreceiveweapon_mk2( player, pap_triggers ))
            level.total_chest_accessed_mk2++;

        if (rand =="ray_gun_zm")
            level.total_ray++;
        else if (rand == "raygun_mark2_zm")
            level.total_mk2++;
    }

    self.weapon_string = rand;
    wait 0.1;

    if ( isdefined( level.custom_magicbox_float_height ) )
        v_float = anglestoup( self.angles ) * level.custom_magicbox_float_height;
    else
        v_float = anglestoup( self.angles ) * 40;

    self.model_dw = undefined;
    self.weapon_model = spawn_weapon_model( rand, undefined, self.origin + v_float, self.angles + vectorscale( ( 0, 1, 0 ), 180.0 ) );

    if ( weapon_is_dual_wield( rand ) )
        self.weapon_model_dw = spawn_weapon_model( rand, get_left_hand_weapon_model_name( rand ), self.weapon_model.origin - vectorscale( ( 1, 1, 1 ), 3.0 ), self.weapon_model.angles );

    if ( getdvar( #"magic_chest_movable" ) == "1" && !( isdefined( chest._box_opened_by_fire_sale ) && chest._box_opened_by_fire_sale ) && !( isdefined( level.zombie_vars["zombie_powerup_fire_sale_on"] ) && level.zombie_vars["zombie_powerup_fire_sale_on"] && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() ) )
    {
        random = randomint( 100 );

        if ( !isdefined( level.chest_min_move_usage ) )
            level.chest_min_move_usage = 4;

        if ( level.chest_accessed < level.chest_min_move_usage )
            chance_of_joker = -1;
        else
        {
            chance_of_joker = level.chest_accessed + 20;

            if ( level.chest_moves == 0 && level.chest_accessed >= 8 )
                chance_of_joker = 100;

            if ( level.chest_accessed >= 4 && level.chest_accessed < 8 )
            {
                if ( random < 15 )
                    chance_of_joker = 100;
                else
                    chance_of_joker = -1;
            }

            if ( level.chest_moves > 0 )
            {
                if ( level.chest_accessed >= 8 && level.chest_accessed < 13 )
                {
                    if ( random < 30 )
                        chance_of_joker = 100;
                    else
                        chance_of_joker = -1;
                }

                if ( level.chest_accessed >= 13 )
                {
                    if ( random < 50 )
                        chance_of_joker = 100;
                    else
                        chance_of_joker = -1;
                }
            }
        }

        if ( isdefined( chest.no_fly_away ) )
            chance_of_joker = -1;

        if ( isdefined( level._zombiemode_chest_joker_chance_override_func ) )
            chance_of_joker = [[ level._zombiemode_chest_joker_chance_override_func ]]( chance_of_joker );

        if ( chance_of_joker > random )
        {
            self.weapon_string = undefined;
            self.weapon_model setmodel( level.chest_joker_model );
            self.weapon_model.angles = self.angles + vectorscale( ( 0, 1, 0 ), 90.0 );

            if ( isdefined( self.weapon_model_dw ) )
            {
                self.weapon_model_dw delete();
                self.weapon_model_dw = undefined;
            }

            self.chest_moving = 1;
            flag_set( "moving_chest_now" );
            level.chest_accessed = 0;
            level.chest_moves++;
        }
    }

    self notify( "randomization_done" );

    if ( flag( "moving_chest_now" ) && !( level.zombie_vars["zombie_powerup_fire_sale_on"] && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() ) )
    {
        if ( isdefined( level.chest_joker_custom_movement ) )
            self [[ level.chest_joker_custom_movement ]]();
        else
        {
            wait 0.5;
            level notify( "weapon_fly_away_start" );
            wait 2;

            if ( isdefined( self.weapon_model ) )
            {
                v_fly_away = self.origin + anglestoup( self.angles ) * 500;
                self.weapon_model moveto( v_fly_away, 4, 3 );
            }

            if ( isdefined( self.weapon_model_dw ) )
            {
                v_fly_away = self.origin + anglestoup( self.angles ) * 500;
                self.weapon_model_dw moveto( v_fly_away, 4, 3 );
            }

            self.weapon_model waittill( "movedone" );
            self.weapon_model delete();

            if ( isdefined( self.weapon_model_dw ) )
            {
                self.weapon_model_dw delete();
                self.weapon_model_dw = undefined;
            }

            self notify( "box_moving" );
            level notify( "weapon_fly_away_end" );
        }
    }
    else
    {
        acquire_weapon_toggle( rand, player );

        if ( rand == "tesla_gun_zm" || rand == "ray_gun_zm" )
        {
            if ( rand == "ray_gun_zm" )
                level.pulls_since_last_ray_gun = 0;

            if ( rand == "tesla_gun_zm" )
            {
                level.pulls_since_last_tesla_gun = 0;
                level.player_seen_tesla_gun = 1;
            }
        }

        if ( !isdefined( respin ) )
        {
            if ( isdefined( chest.box_hacks["respin"] ) )
                self [[ chest.box_hacks["respin"] ]]( chest, player );
        }
        else if ( isdefined( chest.box_hacks["respin_respin"] ) )
            self [[ chest.box_hacks["respin_respin"] ]]( chest, player );

        if ( isdefined( level.custom_magic_box_timer_til_despawn ) )
            self.weapon_model thread [[ level.custom_magic_box_timer_til_despawn ]]( self );
        else
            self.weapon_model thread timer_til_despawn( v_float );

        if ( isdefined( self.weapon_model_dw ) )
        {
            if ( isdefined( level.custom_magic_box_timer_til_despawn ) )
                self.weapon_model_dw thread [[ level.custom_magic_box_timer_til_despawn ]]( self );
            else
                self.weapon_model_dw thread timer_til_despawn( v_float );
        }

        self waittill( "weapon_grabbed" );

        if ( !chest.timedout )
        {
            if ( isdefined( self.weapon_model ) )
                self.weapon_model delete();

            if ( isdefined( self.weapon_model_dw ) )
                self.weapon_model_dw delete();
        }
    }

    self.weapon_string = undefined;
    self notify( "box_spin_done" );
    level notify("box_spin_done");
}

move_chest(desired_box)
{
    chests_new = [];

    foreach (chest in level.chests)
    {
        chest notify("kill_chest_think");
        if (isdefined(chest.zbarrier) && chest.zbarrier getclientfield("magicbox_amb_fx"))
            chest.zbarrier setclientfield("magicbox_amb_fx", 0);

        if (chest.script_noteworthy == desired_box)
            box_location = chest;
        else
            chests_new[chests_new.size] = chest;

        if (is_classic() && is_true(level.random_pandora_box_start))
        {
            chest.start_exclude = 1;

            if (chest.script_noteworthy == desired_box)
            {
                chest.start_exclude = 0;
            }
        }
    }

    if (!isdefined(box_location))
    {
        array_thread(level.chests, maps\mp\zombies\_zm_magicbox::treasure_chest_think);
        return;
    }

    if (is_true(level.random_pandora_box_start))
    {
        maps\mp\zombies\_zm_magicbox::init_starting_chest_location("start_chest");
    }
    else
    {
        level.chests = [];
        level.chests[0] = box_location;
        foreach (new in chests_new)
            level.chests[level.chests.size] = new;

        maps\mp\zombies\_zm_magicbox::init_starting_chest_location(desired_box);
    }

    array_thread(level.chests, maps\mp\zombies\_zm_magicbox::treasure_chest_think);
}

init_hud()
{
    if(isstgame())
        return;

    if(isdefined(level.hud_module) && level.hud_module)
        return;

    if(!isdefined(level.hud_enabled))
        level.hud_enabled = true;
    if(!isdefined(level.total_chest_accessed))
        level.total_chest_accessed = 0;

    level thread displayBoxHits();
    level thread roundcounter();

    if(ismob())
        level thread traptimer();

    if(isburied() || isdierise())
        level thread buildable_hud();

    if(issurvivalmap())
        level thread raygunDisplay();

    level thread setHUDLanguage();
}

roundcounter()
{
    level endon("end_game");

    round = 0;
    level.roundcounter = createserverfontstring( "objective", 10 );
    level.roundcounter.hidewheninmenu = true;
    level.roundcounter.y = -5;
    level.roundcounter.x = 70;
    level.roundcounter.alignx = "left";
    level.roundcounter.horzalign = "user_left";
    level.roundcounter.vertalign = "user_bottom";
    level.roundcounter.aligny = "bottom";
    level.roundcounter.alpha = 0;
    level.roundcounter.color = (0.27, 0, 0);
    if(getDvar("language") == "japanese")
        level.roundcounter.x = 130;
    while(true)
    {
        level waittill("start_of_round");
        round++;
        level.roundcounter setvalue(round);
        if(round > 255)
            level.roundcounter.alpha = 1;
    }
}

buildable_hud()
{
    level endon("end_game");

    level.springpad_hud = createserverfontstring( "objective", 1.3 );
    level.springpad_hud.hidewheninmenu = true;

    if(level.script == "zm_buried") level.springpad_hud.y = 0;
    else level.springpad_hud.y = 15;

    level.springpad_hud.x = 2;
    level.springpad_hud.fontscale = 1.1;
    level.springpad_hud.alignx = "left";
    level.springpad_hud.horzalign = "user_left";
    level.springpad_hud.vertalign = "user_top";
    level.springpad_hud.aligny = "top";
    level.springpad_hud setvalue(0);

    level.subwoofer_hud = createserverfontstring( "objective", 1.3 );
    level.subwoofer_hud.hidewheninmenu = true;
    level.subwoofer_hud.y = 10;
    level.subwoofer_hud.x = 2;
    level.subwoofer_hud.fontscale = 1.1;
    level.subwoofer_hud.alignx = "left";
    level.subwoofer_hud.horzalign = "user_left";
    level.subwoofer_hud.vertalign = "user_top";
    level.subwoofer_hud.aligny = "top";
    level.subwoofer_hud setvalue(0);

    level.turbine_hud = createserverfontstring( "objective", 1.3 );
    level.turbine_hud.hidewheninmenu = true;
    level.turbine_hud.y = 20;
    level.turbine_hud.x = 2;
    level.turbine_hud.fontscale = 1.1;
    level.turbine_hud.alignx = "left";
    level.turbine_hud.horzalign = "user_left";
    level.turbine_hud.vertalign = "user_top";
    level.turbine_hud.aligny = "top";
    level.turbine_hud setvalue(0);

    level.turbine_hud.alpha = 0;
    level.subwoofer_hud.alpha = 0;
    level.springpad_hud.alpha = 0;

    if (isdierise())
    {
        level.subwoofer_hud destroy();
        level.turbine_hud destroy();
    }
    level.buildable_stats = array();
    level.buildable_stats["springpad_zm"] = 0;
    level.buildable_stats["turbine"] = 0;
    level.buildable_stats["subwoofer_zm"] = 0;

    wait 1;
    if(level.buildable_stats["springpad_zm"] > 0)
        level.buildable_stats["springpad_zm"] = 0;
    if(level.buildable_stats["turbine"] > 0)
        level.buildable_stats["turbine"] = 0;
    if(level.buildable_stats["subwoofer_zm"] > 0)
        level.buildable_stats["subwoofer_zm"] = 0;

    if(isburied())
        while(true)
        {
            level waittill("stat_changed");
            level.subwoofer_hud setvalue( level.buildable_stats["subwoofer_zm"] );
            level.turbine_hud setvalue( level.buildable_stats["turbine"] );
            level.springpad_hud setvalue( level.buildable_stats["springpad_zm"] );
        }
    if(isdierise())
        while(true)
        {
            level waittill("stat_changed");
            level.springpad_hud setvalue( level.buildable_stats["springpad_zm"] );
        }
}

setHUDLanguage()
{
    switch(getDvar("language"))
    {
        case "spanish":
            level.boxhits.label = &"^3Tiradas de caja: ^5";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3TRAMPOLINES: ^5";
            if(isdefined(level.subwoofer_hud))
            {
                level.subwoofer_hud.label = &"^3RESONADORES: ^5";
                level.turbine_hud.label = &"^3TURBINAS: ^5";
            }
            break;

        case "french":
            level.boxhits.label = &"^3Box hits: ^5";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3PROPULSEURS: ^5";
            if(isdefined(level.subwoofer_hud))
            {
                level.subwoofer_hud.label = &"^3RÉSONATEUR: ^5";
                level.turbine_hud.label = &"^3TURBINES: ^5";
            }
            break;
        case "japanese":
            level.boxhits.label = &"^3Box hits: ^5";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3スプリングパッド: ^5";
            if(isdefined(level.subwoofer_hud))
            {
                level.subwoofer_hud.label = &"^3レゾネーター: ^5";
                level.turbine_hud.label = &"^3タービン: ^5";
            }
            break;
        default:
            level.boxhits.label = &"^3Box hits: ^5";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3SPRINGPADS: ^5";
            if(isdefined(level.subwoofer_hud))
            {
                level.subwoofer_hud.label = &"^3RESONATORS: ^5";
                level.turbine_hud.label = &"^3TURBINES: ^5";
            }
            break;
    }
}

init_anticheat()
{
    if(isstgame())
        return;
    if(isdefined(level.anticheat_module) && level.anticheat_module)
        return;

    if(isdefined(level.anticheat_module))
        level.anticheat_module = true;

    level thread modding_warnings();
    level thread alwaysDrawIdentifier();
    level thread endgameHashFlash();
    level thread HashFlashLoop();
}

endgameHashFlash()
{
    level waittill("end_game");
    cmdexec("flashScriptHashes");
}

HashFlashLoop()
{
    while(true)
    {
        level waittill("start_of_round");
        if(level.round_number % 10 == 8)
            cmdexec("flashScriptHashes");
    }
}

init_camos()
{
    if((isdefined(level.animated_camos) && level.animated_camos) || (isdefined(level.custom_camos) && level.custom_camos))
        return;

    replaceFunc(getfunction("maps/mp/zombies/_zm_weapons", "get_pack_a_punch_weapon_options"), ::custom_pap_camo);
    checkPapMaterial();
}

checkPapMaterial()
{
    camo = getDvarInt("papcamo");
    if(istranzit() || istown() || isnuketown() || isdierise())
    {
        if(camo != CAMO_GREEN_RUN)
            setDvar("papcamo", CAMO_GREEN_RUN);
        return;
    }

    if(ismob())
    {
        if(camo != CAMO_GREEN_RUN || camo != CAMO_MOB)
            setDvar("papcamo", CAMO_MOB);
        return;
    }

    if(isburied())
    {
        if(camo == CAMO_ORIGINS)
            setDvar("papcamo", CAMO_GREEN_RUN);
        return;
    }
}

treasure_chest_canplayerreceiveweapon_mk2( player, pap_triggers )
{
    weapon = "raygun_mark2_zm";

    if ( !get_is_in_box( weapon ) )
        return 0;

    if ( isdefined( player ) && player has_weapon_or_upgrade( weapon ) )
        return 0;

    if ( !limited_weapon_below_quota( weapon, player, pap_triggers ) )
        return 0;

    if ( !player player_can_use_content( weapon ) )
        return 0;

    if ( isdefined( level.custom_magic_box_selection_logic ) )
    {
        if ( ![[ level.custom_magic_box_selection_logic ]]( weapon, player, pap_triggers ) )
            return 0;
    }

    if ( isdefined( player ) && player has_weapon_or_upgrade( "ray_gun_zm" ) )
        return false;

    return 1;
}

alwaysDrawIdentifier()
{
    level endon("end_game");
    while(true)
    {
        setDvar("cg_drawidentifier", 1);
        wait 0.05;
    }
}

dvar_tracker()
{
    while(true)
    {
        level waittill("dvar_changed", dvar, new, old);
        level notify("dvar_" + dvar + "_changed", new);
    }
}

is_firstbox_allowed(should_print)
{
    if(!isdefined(should_print))
        should_print = false;

    allowed = true;

    if(isround(MAX_FB_ROUND))
        allowed = false;
    if(level.chest_moves > 0)
        allowed = false;

    if(!allowed)
    {
        if(should_print)
            globalprint("Firstbox not allowed");

        return false;
    }
    return true;
}

is_boxmove_allowed(should_print)
{
    if(!isdefined(should_print))
        should_print = false;

    allowed = true;

    if(isround(MAX_FB_ROUND))
        allowed = false;
    if(level.total_chest_accessed > 0)
        allowed = false;

    if(!allowed)
    {
        if(should_print)
            globalprint("Box move not allowed");

        return false;
    }
    return true;
}


modding_warnings()
{
    level endon("end_game");

    modded_stuff = array();
    while(true)
    {
        level waittill("modded", what);

        if(isinarray(modded_stuff, what))
            continue;

        modded_stuff[modded_stuff.size] = what;

        switch(what)
        {
            case "fb": 
                thread modding_watermark("FIRST BOX");
                break;
            case "key":
                thread modding_watermark("KEY");
                break;
            default: break;
        }
    }
}

modding_watermark(label)
{
    level endon("end_game");

    if(!isdefined(level.watermark_label))
        level.watermark_label = label;
    else
    {
        level.watermark_label += "\t\t\t" + label;
        level.modding_watermark settext(level.watermark_label);
        return;
    }

    level.modding_watermark = createserverfontstring( "objective", 1.2 );

    level.modding_watermark setpoint("CENTER", "TOP", get_xpos_watermark(), -5);
    level.modding_watermark settext(level.watermark_label);

    level.modding_watermark.hidewheninmenu = false;
    level.modding_watermark.alpha = 0.3;
    level.modding_watermark.color = (0.8, 0, 0.8);

    while(!isround(CLEAR_WATERMARK_ROUND))
        level waittill("end_of_round");

    level.modding_watermark destroyelem();
}

get_xpos_watermark()
{
    if (!isDefined(level.watermark_x_index))
        level.watermark_x_index = 0;
    else
        level.watermark_x_index++;

    i = level.watermark_x_index;

    if (level.watermark_x_index == 0)
        return 0;

    value = ((level.watermark_x_index + 1) / 2) * 90;

    if (level.watermark_x_index % 2 == 1)
        value *= -1;

    return value;
}

tomahawk_fix()
{
    if (isdefined(level.gamedifficulty) && level.gamedifficulty == 0)
    {
        return;
    }

    self endon("disconnect");

    if (!isdefined(level.tomahawk_cache["" + (self.entity_num)]) || level.tomahawk_cache["" + (self.entity_num)] != "upgraded_tomahawk_zm")
    {
        upgrade = getfunction("maps/mp/zm_alcatraz_weap_quest", "tomahawk_upgrade_quest");
        disabledetouronce(upgrade);
        self [[upgrade]]();
        return;
    }


    self.tomahawk_upgrade_kills = 15;

    wait 1.0;

    self ent_flag_init("gg_round_done" );
    self ent_flag_set("gg_round_done" );

    if (!isdefined(self.retriever_trigger))
    {
        trigger = getent("retriever_pickup_trigger", "script_noteworthy");
        self.retriever_trigger = trigger;
    }
    self.retriever_trigger setinvisibletoplayer(self);

    self takeweapon("bouncing_tomahawk_zm");
    self set_player_tactical_grenade("none");
    self notify("tomahawk_upgraded_swap");
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent("quest_generic");
    e_org = spawn("script_origin", self.origin + vectorscale((0, 0, 1), 64.0));
    e_org playsoundwithnotify("zmb_easteregg_scream", "easteregg_scream_complete");
    e_org waittill("easteregg_scream_complete");
    e_org delete();

    wait 0.5;

    tomahawk_pick = getent("spinning_tomahawk_pickup", "targetname");
    tomahawk_pick setclientfield("play_tomahawk_fx", 2);
    self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
}

cache_current_tomahawk()
{
    if(!ismob() || !isdefined(self.current_tomahawk_weapon))
        return;


    if (!isdefined(level.tomahawk_cache))
    {
        level.tomahawk_cache = [];
    }
    level.tomahawk_cache["" + (self.entity_num)] = self.current_tomahawk_weapon;
}

powerup_grab( powerup_team )
{
    if ( isdefined( self ) && self.zombie_grabbable )
    {
        self thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_zombie_grab")]]( powerup_team );
        return;
    }

    self endon( "powerup_timedout" );
    self endon( "powerup_grabbed" );
    range_squared = 4096;

    while ( isdefined( self ) )
    {
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( ( self.powerup_name == "minigun" || self.powerup_name == "tesla" || self.powerup_name == "random_weapon" || self.powerup_name == "meat_stink" ) && ( players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() || players[i] usebuttonpressed() && players[i] in_revive_trigger() ) )
                continue;

            if ( isdefined( self.can_pick_up_in_last_stand ) && !self.can_pick_up_in_last_stand && players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                continue;

            ignore_range = 0;

            if ( isdefined( players[i].ignore_range_powerup ) && players[i].ignore_range_powerup == self )
            {
                players[i].ignore_range_powerup = undefined;
                ignore_range = 1;
            }

            if ( distancesquared( players[i].origin, self.origin ) < range_squared || ignore_range )
            {
                if ( isdefined( level._powerup_grab_check ) )
                {
                    if ( !self [[ level._powerup_grab_check ]]( players[i] ) )
                        continue;
                }

                if ( isdefined( level.zombie_powerup_grab_func ) )
                    level thread [[ level.zombie_powerup_grab_func ]]();
                else
                {
                    switch ( self.powerup_name )
                    {
                        case "nuke":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "nuke_powerup")]]( self, players[i].team );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "nuke" );
                            zombies = getaiarray( level.zombie_team );
                            players[i].zombie_nuked = arraysort( zombies, self.origin );
                            players[i] notify( "nuke_triggered" );
                            break;
                        case "full_ammo":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "full_ammo_powerup")]]( self, players[i] );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "full_ammo" );
                            break;
                        case "double_points":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "double_points_powerup")]]( self, players[i] );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "double_points" );
                            break;
                        case "insta_kill":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "insta_kill_powerup")]]( self, players[i] );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "insta_kill" );
                            break;
                        case "carpenter":
                            if ( is_classic() )
                                players[i] thread maps\mp\zombies\_zm_pers_upgrades::persistent_carpenter_ability_check();

                            if ( isdefined( level.use_new_carpenter_func ) )
                                level thread [[ level.use_new_carpenter_func ]]( self.origin );
                            else
                                level thread [[getfunction("maps/mp/zombies/_zm_powerups", "start_carpenter")]]( self.origin );

                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "carpenter" );
                            break;
                        case "fire_sale":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "start_fire_sale")]]( self );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "firesale" );
                            break;
                        case "bonfire_sale":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "start_bonfire_sale")]]( self );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "firesale" );
                            break;
                        case "minigun":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "minigun_weapon_powerup")]]( players[i] );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "minigun" );
                            break;
                        case "free_perk":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "free_perk_powerup")]]( self );
                            break;
                        case "tesla":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "tesla_weapon_powerup")]]( players[i] );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "tesla" );
                            break;
                        case "random_weapon":
                            if ( !level [[getfunction("maps/mp/zombies/_zm_powerups", "random_weapon_powerup")]]( self, players[i] ) )
                                continue;

                            break;
                        case "bonus_points_player":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "bonus_points_player_powerup")]]( self, players[i] );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "bonus_points_solo" );
                            break;
                        case "bonus_points_team":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "bonus_points_player_powerup")]]( self );
                            players[i] thread [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_vo")]]( "bonus_points_team" );
                            break;
                        case "teller_withdrawl":
                            level thread [[getfunction("maps/mp/zombies/_zm_powerups", "teller_withdrawl")]]( self, players[i] );
                            break;
                        default:
                            if ( isdefined( level._zombiemode_powerup_grab ) )
                                level thread [[ level._zombiemode_powerup_grab ]]( self, players[i] );
                            else
                            {
                            }

                            break;
                    }
                }

                maps\mp\_demo::bookmark( "zm_player_powerup_grabbed", gettime(), players[i] );

                if ( [[getfunction("maps/mp/zombies/_zm_powerups", "should_award_stat")]]( self.powerup_name ) )
                {
                    players[i] maps\mp\zombies\_zm_stats::increment_client_stat( "drops" );
                    players[i] maps\mp\zombies\_zm_stats::increment_player_stat( "drops" );
                    players[i] maps\mp\zombies\_zm_stats::increment_client_stat( self.powerup_name + "_pickedup" );
                    players[i] maps\mp\zombies\_zm_stats::increment_player_stat( self.powerup_name + "_pickedup" );
                }

                if ( self.solo )
                {
                    playfx( level._effect["powerup_grabbed_solo"], self.origin );
                    playfx( level._effect["powerup_grabbed_wave_solo"], self.origin );
                }
                else if ( self.caution )
                {
                    playfx( level._effect["powerup_grabbed_caution"], self.origin );
                    playfx( level._effect["powerup_grabbed_wave_caution"], self.origin );
                }
                else
                {
                    playfx( level._effect["powerup_grabbed"], self.origin );
                    playfx( level._effect["powerup_grabbed_wave"], self.origin );
                }

                if ( isdefined( self.stolen ) && self.stolen )
                    level notify( "monkey_see_monkey_dont_achieved" );

                if ( isdefined( self.grabbed_level_notify ) )
                    level notify( self.grabbed_level_notify );

                self.claimed = 1;
                self.power_up_grab_player = players[i];
                wait 0.1;
                playsoundatposition( "zmb_powerup_grabbed", self.origin );
                self stoploopsound();
                self hide();

                if ( self.powerup_name != "fire_sale" )
                {
                    if ( isdefined( self.power_up_grab_player ) )
                    {
                        if ( isdefined( level.powerup_intro_vox ) )
                        {
                            level thread [[ level.powerup_intro_vox ]]( self );
                            return;
                        }
                        else if ( isdefined( level.powerup_vo_available ) )
                        {
                            can_say_vo = [[ level.powerup_vo_available ]]();

                            if ( !can_say_vo )
                            {
                                self [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_delete")]]();
                                level notify("powerup_grabbed");
                                self notify( "powerup_grabbed" );
                                return;
                            }
                        }
                    }
                }

                level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( self.powerup_name, self.power_up_grab_player.pers["team"] );
                self [[getfunction("maps/mp/zombies/_zm_powerups", "powerup_delete")]]();
                level notify("powerup_grabbed");
                self notify( "powerup_grabbed" );
            }
        }
        wait 0.1;
    }
}