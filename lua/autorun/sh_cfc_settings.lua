AddCSLuaFile( "cfc_settings/client/cl_main.lua" )
AddCSLuaFile( "cfc_settings/client/cl_config.lua" )

if CLIENT then
    include( "cfc_settings/client/cl_main.lua" )
end
