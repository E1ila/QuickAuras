local out = MeleeUtils.out

SLASH_MELEEUTILS1 = "/meleeutils";
SLASH_MELEEUTILS2 = "/mu";
SLASH_MELEEUTILS3 = "/melee";
SlashCmdList.MELEEUTILS = function(msg)
    local _, _, cmd, arg1 = string.find(msg, "([%w]+)%s*(.*)$")
    if not cmd then
        Settings.OpenToCategory("Melee Utils")
    else
        cmd = string.upper(cmd)
        if "HELP" == cmd or "H" == cmd then
            out("Use MeleeUtils to track your grinding session yield. Options:")
            out(" |cff00ff00/mu|r toggle logging on/off")
        elseif "DEBUG" == cmd then
            MeleeUtilsGlobalVars.debug = not MeleeUtilsGlobalVars.debug
            if MeleeUtilsGlobalVars.debug then
                out("Debug mode |cff00ff00enabled")
            else
                out("Debug mode |cffff0000disabled")
            end
        else
            out("Unknown command " .. cmd)
        end
    end
end
