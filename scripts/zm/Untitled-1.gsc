
#if FEATURE_BOX_LOCATION == 1
box_location_input(value, key, player)
{
    if (!can_set_box_location())
    {
        return true;
    }

    conf = box_location_config();

    /* Show possible options */
    if (value == "")
    {
        filtered_by_map = [];
        foreach (loc_config in conf)
        {
            cb = loc_config["map_callback"];
            if ([[cb]]())
            {
                filtered_by_map[filtered_by_map.size] = COLOR_TXT(loc_config["aliases"][0], COL_YELLOW) + " for " + loc_config["name"];
            }
        }

        if (filtered_by_map.size)
        {
            print_scheduler("LB options: " + array_implode(", ", filtered_by_map), gethostplayer());
        }
        return true;
    }

    selection = undefined;
    foreach (loc_config in conf)
    {
        cb = loc_config["map_callback"];
        if ((tolower(value) == loc_config["script_noteworthy"] || isinarray(loc_config["aliases"], tolower(value))) && [[cb]]())
        {
            selection = loc_config;
        }
    }

    /* Check selection against map chests */
    chests_script = get_noteworthy_chests();
    if (!isdefined(selection) || chests_script.size < 2 || !isinarray(chests_script, selection["script_noteworthy"]))
    {
        print_scheduler("Incorrect selection: " + COLOR_TXT(value, COL_RED), gethostplayer());
        return true;
    }

    /* Check if selected box is already there */
    foreach (chest in level.chests)
    {
        if (chest.script_noteworthy == selection["script_noteworthy"] && chest.hidden == 0)
        {
            print_scheduler("Box already in selected location", gethostplayer());
            return true;
        }
    }

    /* Attempt moving the chest */
    if (move_chest(selection))
    {
        b2_flag_set(F_BOXLOCATION_LOCKED);
        print_scheduler("Box moved to: " + COLOR_TXT(selection["name"], COL_YELLOW));
    }

    return true;
}

move_chest(box_config)
{
    DEBUG_PRINT("moving chest: " + sstr(box_config));

    chests_new = [];

    /* All chests here do exist */
    foreach (chest in level.chests)
    {
        chest notify("kill_chest_think");
        /* Kill the FX playing on active box location, hide_chest won't do it */
        if (isdefined(chest.zbarrier) && chest.zbarrier getclientfield("magicbox_amb_fx"))
        {
            DEBUG_PRINT("overriding clientfield 'magicbox_amb_fx'");
            chest.zbarrier setclientfield("magicbox_amb_fx", 0);
        }

        if (chest.script_noteworthy == box_config["script_noteworthy"])
        {
            lb_chest = chest;
        }
        else
        {
            chests_new[chests_new.size] = chest;
        }

        /* Classic maps use this flag to check */
        if (is_classic() && is_true(level.random_pandora_box_start))
        {
            chest.start_exclude = 1;

            if (chest.script_noteworthy == box_config["script_noteworthy"])
            {
                chest.start_exclude = 0;
            }
        }
    }

    /* We're in trouble if we get into this if */
    if (!isdefined(lb_chest))
    {
        array_thread(level.chests, maps\mp\zombies\_zm_magicbox::treasure_chest_think);
        DEBUG_PRINT("lb_chest undefined, should never happen!");
        return false;
    }

    /* Pandora box based maps (mob & origins) */
    if (is_true(level.random_pandora_box_start))
    {
        maps\mp\zombies\_zm_magicbox::init_starting_chest_location("start_chest");
    }
    /* script noteworthy based maps */
    else
    {
        /* I have to reindex the global array, since the actual location is index dependent */
        level.chests = [];
        level.chests[0] = lb_chest;
        foreach (new in chests_new)
        {
            level.chests[level.chests.size] = new;
        }

        maps\mp\zombies\_zm_magicbox::init_starting_chest_location(box_config["script_noteworthy"]);
    }

    array_thread(level.chests, maps\mp\zombies\_zm_magicbox::treasure_chest_think);

    return true;
}

can_set_box_location()
{
    /* 1 or 0 boxes on the map */
    if (level.chests.size < 2)
    {
        DEBUG_PRINT("can_set_box_location false => chest size");
        return false;
    }

    /* random_pandora_box_start not used */
    if (!is_true(level.random_pandora_box_start))
    {
        chests = get_noteworthy_chests();
        start_chests = 0;
        foreach (chest in chests)
        {
            if (is_town() && issubstr(chest, "town_chest"))
                start_chests++;
            else if (is_nuketown() && issubstr(chest, "start_chest"))
                start_chests++;
        }
        if (start_chests < 2)
        {
            DEBUG_PRINT("can_set_box_location false => start chests size");
            return false;
        }
    }

    /* Check if GSC logic is ready */
    if (!flag_exists("moving_chest_enabled") || !flag("moving_chest_enabled"))
    {
        DEBUG_PRINT("can_set_box_location false => moving_chest_enabled");
        return false;
    }
    /* Exit if box has been hit already */
    if (is_true(level.total_box_hits))
    {
        DEBUG_PRINT("can_set_box_location false => total_box_hits");
        b2_flag_set(F_BOXLOCATION_LOCKED);
        return false;
    }
    /* Mob can't lb until exit 1st afterlife */
    if ((!flag_exists("afterlife_start_over") || !flag("afterlife_start_over")) && is_mob())
    {
        DEBUG_PRINT("can_set_box_location false => afterlife_start_over");
        print_scheduler(COLOR_TXT("Players must leave initial afterlife mode first!", COL_YELLOW), gethostplayer());
        return false;
    }

    return true;
}

get_noteworthy_chests()
{
    chests = [];
    foreach (chest in level.chests)
    {
        chests[chests.size] = chest.script_noteworthy;
    }
    return chests;
}

box_location_config()
{
    conf = [];
    /*                                      script_noteworthy   aliases                             name                map_cb      */
    conf[conf.size] = register_box_location("town_chest_2",     array("dt", "cage"),                "Double Tap Cage",  ::is_town);
    conf[conf.size] = register_box_location("town_chest",       array("qr", "quick"),               "Quick Revive Room",::is_town);
    conf[conf.size] = register_box_location("cafe_chest",       array(LOCATION_CAFE, "cateteria"),  "Cafeteria",        ::is_mob);
    conf[conf.size] = register_box_location("start_chest",      array(LOCATION_WARDEN, "office"),   "Warden's Office",  ::is_mob);
    conf[conf.size] = register_box_location("start_chest2",     array("yellow"),                    "Yellow House",     ::is_nuketown);
    conf[conf.size] = register_box_location("start_chest1",     array("green"),                     "Green House",      ::is_nuketown);
    conf[conf.size] = register_box_location("bunker_tank_chest",array("2", "tank"),                 "Generator 2",      ::is_origins);
    conf[conf.size] = register_box_location("bunker_cp_chest",  array("3", "speed"),                "Generator 3",      ::is_origins);

    return conf;
}

register_box_location(script_noteworthy, aliases, name, map_callback)
{
    location = [];
    location["script_noteworthy"] = script_noteworthy;
    location["aliases"] = aliases;
    location["name"] = name;
    location["map_callback"] = map_callback;
    return location;
}
#endif