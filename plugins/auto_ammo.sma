#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

new const max_bpammo[31] = {
    0, 52, 0, 90, 0, 32, 0, 100, 90, 0,
    120, 100, 100, 90, 90, 90, 100, 120, 30, 120,
    200, 32, 90, 120, 90, 0, 35, 90, 90, 0, 100
};

public plugin_init()
{
    register_plugin("Full reserve ammo", "1.0", "cs16-server");
    RegisterHam(Ham_Spawn, "player", "on_spawn", 1);

    new const weapons[][] = {
        "weapon_p228", "weapon_scout", "weapon_xm1014", "weapon_mac10",
        "weapon_aug", "weapon_elite", "weapon_fiveseven", "weapon_ump45",
        "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp",
        "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
        "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1",
        "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_p90"
    };
    for (new i = 0; i < sizeof weapons; i++)
        RegisterHam(Ham_Item_AddToPlayer, weapons[i], "on_weapon_acquired", 1);
}

public on_spawn(id)
{
    if (!is_user_alive(id)) return;

    new weapons[32], count, weapon;
    get_user_weapons(id, weapons, count);
    for (new i = 0; i < count; i++) {
        weapon = weapons[i];
        if (weapon < sizeof max_bpammo && max_bpammo[weapon] > 0)
            cs_set_user_bpammo(id, weapon, max_bpammo[weapon]);
    }
}

public on_weapon_acquired(entity, id)
{
    if (!is_user_alive(id)) return;

    new weapon = cs_get_weapon_id(entity);
    if (weapon > 0 && weapon < sizeof max_bpammo && max_bpammo[weapon] > 0)
        cs_set_user_bpammo(id, weapon, max_bpammo[weapon]);
}
