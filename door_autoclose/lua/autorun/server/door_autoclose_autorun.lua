include("__door_autoclose_config.lua")

local doors = {
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true,
    ["prop_dynamic"] = true
}

local function DoorIsOpen( door )	
	local doorClass = door:GetClass()

	if ( doorClass == "func_door" or doorClass == "func_door_rotating" or doorClass == "func_movelinear" ) then
		return door:GetInternalVariable( "m_toggle_state" ) == 0
	elseif ( doorClass == "prop_door_rotating"  or doorClass == "prop_dynamic") then
		return door:GetInternalVariable( "m_eDoorState" ) ~= 0
	else
		return false
	end
end

hook.Add("InitPostEntity", "DC_AutoCloseDoor", function()
	for _, ent in pairs(ents.GetAll()) do
		if !doors[ent:GetClass()] then continue end

		local lastOpen = CurTime()
		local isOpen = false
		local timerID = "dc_doorthink#"..ent:EntIndex() 
		timer.Create(timerID, 0.15, 0, function()
			if !IsValid(ent) then timer.Remove(timerID) return end

			isOpen = DoorIsOpen(ent)

			//print(isOpen)

			if !isOpen then
				lastOpen = CurTime()
				return
			end

			if (lastOpen + DC_DOORAUTOCLOSE.Config.time) < CurTime() then
				ent:Fire("Close")

				if IsValid(ent.lastUser) then
					ent.lastUser:SendLua("notification.AddLegacy( '"..DC_DOORAUTOCLOSE.Config.message.."', 0, 3 ) surface.PlaySound( 'buttons/button15.wav' )")
				end

				lastOpen = CurTime()
			end
		end)
	end
end)

hook.Add("PlayerUse", "DC_AutoCloseDoor", function(ply, ent)
	if !IsValid(ent) or !doors[ent:GetClass()] then return end

	ent.lastUser = ply
end)