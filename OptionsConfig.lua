MeleeUtils_OptionsConfig = {
    name = "Melee Utils",
    handler = MeleeUtils,
    type = "group",
    args = {
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable or disable the addon",
            get = function(info) return MeleeUtils.db.profile.enabled end,
            set = function(info, value) MeleeUtils.db.profile.enabled = value end,
        },
        someSetting = {
            type = "range",
            name = "Some Setting",
            desc = "Adjust some setting",
            min = 1,
            max = 100,
            step = 1,
            get = function(info) return MeleeUtils.db.profile.someSetting end,
            set = function(info, value) MeleeUtils.db.profile.someSetting = value end,
        },
        rogue = {
            type = "group",
            name = "Rogue Options",
            desc = "Settings specific to rogues",
            args = {
                someSetting = {
                    type = "range",
                    name = "Some Setting",
                    desc = "Adjust some setting",
                    min = 1,
                    max = 100,
                    step = 1,
                    get = function(info) return true end,
                    set = function(info, value)  end,
                },
            },
        },
    },
}
