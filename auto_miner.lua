script_name("Abe's Auto Mainer")

require 'lib.sampfuncs'
local vkeys = require 'vkeys'
local SE = require 'lib.samp.events'

local is_on = false

local set_pos = false

local current_status = "start_mine"

--- Pos Data
local posX, posY, posZ = 0, 0, 0
local target_x, target_y, target_z = 0, 0, 0

local set_up = false
local time2turn = false

--- Main
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then
		return
	end
	while not isSampAvailable() do wait(100) end

    while true do wait(0)
        if wasKeyPressed(vkeys.VK_F11) then
            is_on = not is_on
            local display = is_on and "ON" or "OFF"
            sampTextdrawCreate(1, "AUTO MINING " .. display , 320.0, 200.0)
            wait(2000)
            sampTextdrawDelete(1)
            posX, posY, posZ = 0, 0, 0
            target_x, target_y, target_z = 0, 0, 0
        end
        if wasKeyPressed(vkeys.VK_F2) then
            set_pos = not set_pos
            if set_pos == true then
                posX, posY, posZ = getCharCoordinates(PLAYER_PED)
                local str = string.format("Orizin pos set at %d, %d, %d ...", posX, posY, posZ)
                sampTextdrawCreate(1, str, 320.0, 200.0)
                wait(2000)
                sampTextdrawDelete(1)
            else
                target_x, target_y, target_z = getCharCoordinates(PLAYER_PED)
                local str1 = string.format("Target pos set at %d, %d, %d ...", target_x, target_y, target_z)
                sampTextdrawCreate(1, str1, 320.0, 200.0)
                wait(2000)
                sampTextdrawDelete(1)
                set_up = true
                sampAddChatMessage( "set up ended...auto mining will starting soon.....", 0xFF0000FF)
                current_status = "start_mine"
            end
        end
        if is_on == true and set_up == true then
            if current_status == "start_mine" then
                moveToCoord(posX, posY, posZ)
                setVirtualKeyDown(vkeys.VK_LBUTTON, true)
                wait(300)
                setVirtualKeyDown(vkeys.VK_LBUTTON, false)
            elseif current_status == "mined success" then
                time2turn = not time2turn
                current_status = "waiting"
                
                if time2turn == true then
                    moveToCoord(target_x, target_y, target_z)
                else
                    moveToCoord(posX, posY, posZ)
                end
                
                setVirtualKeyDown(vkeys.VK_LBUTTON, true)
                wait(300)
                setVirtualKeyDown(vkeys.VK_LBUTTON, false)
            end
        end
    end
end

function SE.onServerMessage(color, text)
    if text:find('You mined') then
        current_status = "mined success"
        print("mined success!!")
    elseif text:find('You are not at mining') or text:find('You are already in process of mining.') then
        current_status = "idle"
        print("already mining or not_at_pos")
    elseif text:find("You cannot mine at the same") then
        current_status = "idle"
        print("cant mine samp position!!") 
    end
end

function moveToCoord(x, y, z)
    local task = openSequenceTask()
    taskGoStraightToCoord(-1, x, y, z, 4, -1) 
    closeSequenceTask(task)
    performSequenceTask(PLAYER_PED, task)
    clearSequenceTask(task)

    local dist = 0
    repeat
        wait(100)
        local cx, cy, cz = getCharCoordinates(PLAYER_PED)
        dist = getDistanceBetweenCoords3d(cx, cy, cz, x, y, z)
    until dist < 1.0 or not is_on
end