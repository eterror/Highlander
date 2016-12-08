--------------------------------
-- HIGHLANDER / HOGS OF WAR
-- version 0.4b
-- by mikade
--------------------------------

--------------------------------
-- HACKED SCRIPT
-- Fanat & Terror
--------------------------------

HedgewarsScriptLoad("/Scripts/Locale.lua")
HedgewarsScriptLoad("/Scripts/Tracker.lua")
HedgewarsScriptLoad("/Scripts/Params.lua")

-- These define weps allowed by the script. At present Tardis and Resurrection is banned for example
-- These were arbitrarily defined out-of-order in initial script, so that was preserved here, resulting 
-- in a moderately odd syntax.
local atkWeps = 	{
					[amBazooka]=true, [amBee]=true, [amMortar]=true, [amDrill]=true, [amSnowball]=true,
                    [amGrenade]=true, [amClusterBomb]=true, [amMolotov]=true, [amWatermelon]=true,
                    [amHellishBomb]=true, [amGasBomb]=true, [amShotgun]=true, [amDEagle]=true,
                    [amFlamethrower]=true, [amSniperRifle]=true, [amSineGun]=true, 
					[amFirePunch]=true, [amWhip]=true, [amBaseballBat]=true, [amKamikaze]=true,
                    [amSeduction]=true, [amHammer]=true, [amMine]=true, [amDynamite]=true, [amCake]=true,
                    [amBallgun]=true, [amSMine]=true, [amRCPlane]=true, [amBirdy]=true, [amKnife]=true,
                    [amAirAttack]=true, [amMineStrike]=true, [amNapalm]=true, [amDrillStrike]=true, [amPiano]=true, [amAirMine] = true,
					}

local utilWeps =  {
					[amBlowTorch]=true, [amPickHammer]=true, [amGirder]=true, [amPortalGun]=true,
					[amRope]=true, [amParachute]=true, [amTeleport]=true, [amJetpack]=true,
					[amInvulnerable]=true, [amLaserSight]=true, [amVampiric]=true,
					[amLowGravity]=true, [amExtraDamage]=true, [amExtraTime]=true,
					[amLandGun]=true, [amRubber]=true, [amIceGun]=true,
					}

local allWeapons = {
    "GRANADE", "CLUSTER", "ZOOKA", "BEE", "SHOTGUN", "PNEUM", "7", "ROPE", "MINE", "EAGLE",
    "DYNA", "PUNCH", "WHIP", "BASEBALL", "CHUTE", "AIRSTRIKE", "MINESTRIKE", "TORCH", "GIRDER", "TP",
    "21", "MORTAR", "23", "CAKE", "LOVE", "MELON", "666", "NAP", "DRILL", "BALL",
    "RCP", "GRAV", "DMG", "DYNA", "TIME", "LASER", "37", "SNIP", "UFO", "VODKA",
    "BIRD", "PORTAL", "PIANO", "SER", "SIN", "FLAME", "STICKY", "HAMMER", "49", "DRILLSTRIKE",
    "MUDBALL", "52", "LANDSPR", "ICE", "KNIFE", "RUBBER", "AIRMINE", "58", "59", "60"
    }

local wepArray = {}

local atkChoices = {}
local utilChoices = {}

local currHog
local lastHog
local started = false
local switchStage = 0

local lastWep = amNothing
local shotsFired = 0

local probability = {1,2,5,10,20,50,200,500,1000000};
local atktot = 0
local utiltot = 0
local maxWep = 57 -- game crashes if you exceed supported #

local someHog = nil -- just for looking up the weps

local mode = nil
local hogNum = 1
local last_team
local hog_numer = 1

-- cheating fanat code start
local all_hhgs = {}

local vgt = {}
local cc

local allMines = {}
local allBarrels = {}
local allAirMines = {}

local lastHogX, lastHogy

local laser

function onPrecise()
	lastHogX = GetX(CurrentHedgehog)
	lastHogY = GetY(CurrentHedgehog)
	preciseHeld = true
end

function onPreciseUp()
	preciseHeld = false
end

function onGameTick20()
	
    for i in pairs(all_hhgs) do
		if CurrentHedgehog == nil then
			--pass
		elseif GetX(all_hhgs[i]["gear"]) == nil then
			table.remove(all_hhgs[i])
		elseif all_hhgs[i]["gear"] ~= CurrentHedgehog then
			cc = -32
			local dx, dy = GetGearVelocity(all_hhgs[i]["gear"])			
			vgt[i] = {}
			if math.abs(GetX(CurrentHedgehog) - GetX(all_hhgs[i]["gear"])) < 120 and math.abs(GetY(CurrentHedgehog) - GetY(all_hhgs[i]["gear"])) < 120 then
				-- hide images
			elseif dy == 0 and (dx == 0 or dx == -1) then
				for weapon in pairs(all_hhgs[i]["weapons"]) do
					table.insert(vgt[i], AddVisualGear(0, 0, vgtStraightShot,0,true,3))

					if (preciseHeld == true) then
						SetVisualGearValues(vgt[i][weapon], GetX(all_hhgs[i]["gear"])+cc, GetY(all_hhgs[i]["gear"])+30, 0, 0, 0, all_hhgs[i]["weapons"][weapon]-1, 500, sprAMAmmos, 500)
					end

					cc = cc + 32
				end
			end

		end
	end
	table.remove(vgt)

	for i in pairs(allMines) do
	    if GetX(allMines[i]) == nil or GetX(currHog) == nil then
			--pass
		elseif math.abs(GetX(currHog) - GetX(allMines[i])) < 90 and math.abs(GetY(currHog) - GetY(allMines[i])) < 90 then
		    DrawTag(GetTimer(allMines[i]), GetX(allMines[i]), GetY(allMines[i]))
		end			
	end

	for i in pairs(allBarrels) do
	    if GetX(allBarrels[i]) == nil or GetX(currHog) == nil then
			--pass
		elseif math.abs(GetX(currHog) - GetX(allBarrels[i])) < 30 and math.abs(GetY(currHog) - GetY(allBarrels[i])) < 30 then
		    DrawTag(GetHealth(allBarrels[i]), GetX(allBarrels[i]), GetY(allBarrels[i])+20)
		end			
	end

	for i in pairs(allAirMines) do
	    if GetX(allAirMines[i]) == nil or GetX(currHog) == nil then
			--pass
		elseif math.abs(GetX(currHog) - GetX(allAirMines[i])) < 70 and math.abs(GetY(currHog) - GetY(allAirMines[i])) < 70 then
		    DrawTag(GetTimer(allAirMines[i]), GetX(allAirMines[i]), GetY(allAirMines[i]))
		end			
	end


	if CurrentHedgehog ~= nil then
		if (preciseHeld == true) then
			showJump()
			showLaser()
		elseif GetCurAmmoType() == 23 then
			kami()
		elseif GetCurAmmoType() == 17 then
			showAIRsight()
		elseif GetCurAmmoType() == 16 then
			showAIRsight()
		elseif GetCurAmmoType() == 50 then
			showAIRsight()
		end
	end
end

function DrawTag(value, X, Y)
	tCol = 0x00ff00ff 
	zoomL = 1.3
			
	DeleteVisualGear(vTag)
	vTag = AddVisualGear(0, 0, vgtHealthTag, 0, false)
	
	g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 = GetVisualGearValues(vTag)
	SetVisualGearValues	(
	    vTag, 		--id
		X,	--xoffset
		Y-60, --yoffset
		0, 			--dx
		0, 			--dy
		zoomL, 			--zoom
		0, 			--~= 0 means align to screen
		g7, 			--frameticks
		value, 		--value
		24000, 		--timer
		tCol		--GetClanColor( GetHogClan(CurrentHedgehog) )
	)

end

function showAIRsight() -- airstrike, drillstrike, minestrike
	AddVisualGear(CursorX-66, CursorY, vgtEvilTrace, 0, true,1)
	AddVisualGear(CursorX-33, CursorY, vgtEvilTrace, 0, true,1)
	AddVisualGear(CursorX+00, CursorY, vgtEvilTrace, 0, true,1)
	AddVisualGear(CursorX+33, CursorY, vgtEvilTrace, 0, true,1)
	AddVisualGear(CursorX+66, CursorY, vgtEvilTrace, 0, true,1)
end

function showLaser()
	local Angle, Power, WDTimer, Radius, Density, Karma, DirAngle, AdvBounce, ImpactSound, nImpactSounds, Tint, Damage, Boom = GetGearValues(CurrentHedgehog)
    local dx, dy = GetGearVelocity(CurrentHedgehog)
    local sign
    if dx < 0 then
        sign = -1
    else
        sign = 1
    end
    for i = 39,LAND_WIDTH-1,12 do 
		laser = AddVisualGear(GetX(CurrentHedgehog)+sign*i*math.sin(Angle/2048 * math.pi), GetY(CurrentHedgehog)-i*math.cos(Angle/2048 * math.pi), vgtBeeTrace, 0, false)
    	SetVisualGearValues(laser, GetX(CurrentHedgehog)+sign*i*math.sin(Angle/2048 * math.pi), GetY(CurrentHedgehog)-i*math.cos(Angle/2048 * math.pi),  0, 0, 0, 3128, 140, vgtBeeTrace, 0)
    end
end

function kami()
	local Angle, Power, WDTimer, Radius, Density, Karma, DirAngle, AdvBounce, ImpactSound, nImpactSounds, Tint, Damage, Boom = GetGearValues(CurrentHedgehog)
    local dx, dy = GetGearVelocity(CurrentHedgehog)
    local sign
    if dx < 0 then
        sign = -1
    else
        sign = 1
    end
	
	for i = 39,500,12 do 
		kamig = AddVisualGear(GetX(CurrentHedgehog)+sign*i*math.sin(Angle/2048 * math.pi), GetY(CurrentHedgehog)-i*math.cos(Angle/2048 * math.pi), vgtBeeTrace, 0, false)
		SetVisualGearValues(kamig, GetX(CurrentHedgehog)+sign*i*math.sin(Angle/2048 * math.pi), GetY(CurrentHedgehog)-i*math.cos(Angle/2048 * math.pi),  0, 0, 0, 3128, 140, vgtBeeTrace, 0)
	end

	AddVisualGear(GetX(CurrentHedgehog)+sign*512*math.sin(Angle/2048 * math.pi), GetY(CurrentHedgehog)-512*math.cos(Angle/2048 * math.pi), vgtEvilTrace, 0, false)
end

function showJump()
	local dx, dy = GetGearVelocity(CurrentHedgehog)
    
	if dx < 0 then
        AddVisualGear(lastHogX-9, lastHogY-10, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-21, lastHogY-18, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-33, lastHogY-23, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX-45, lastHogY-25, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-57, lastHogY-23, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-69, lastHogY-18, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX-81, lastHogY-10, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-93, lastHogY+1, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-105, lastHogY+15, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX-114, lastHogY+28, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-123, lastHogY+43, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-132, lastHogY+59, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX-141, lastHogY+77, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-149, lastHogY+95, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX-158, lastHogY+117, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX-164, lastHogY+132, vgtEvilTrace, 0, false)	
    else
        AddVisualGear(lastHogX+9, lastHogY-10, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+21, lastHogY-18, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+33, lastHogY-23, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX+45, lastHogY-25, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+57, lastHogY-23, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+69, lastHogY-18, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX+81, lastHogY-10, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+93, lastHogY+1, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+105, lastHogY+15, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX+114, lastHogY+28, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+123, lastHogY+43, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+132, lastHogY+59, vgtSmokeTrace, 0, false)
		
		AddVisualGear(lastHogX+141, lastHogY+77, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+149, lastHogY+95, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+158, lastHogY+117, vgtSmokeTrace, 0, false)
		AddVisualGear(lastHogX+164, lastHogY+132, vgtEvilTrace, 0, false)	
    end	
end

function onParameters()
    parseParams()
    mode = params["mode"]
end

function CheckForWeaponSwap()
	if GetCurAmmoType() ~= lastWep then
		shotsFired = 0
	end
	lastWep = GetCurAmmoType()
end

function onSlot()
	CheckForWeaponSwap()
end

function onSetWeapon()
	CheckForWeaponSwap()
end

function onHogAttack()
	CheckForWeaponSwap()
	shotsFired = shotsFired + 1
end

function StartingSetUp(gear)
    for i = 1,maxWep do
        setGearValue(gear,i,0)
    end
    for w,c in pairs(wepArray) do
        if c == 9 and (atkWeps[w] or utilWeps[w])  then
            setGearValue(gear,w,1)
        end
	end

	setGearValue(gear,amSkip,100)
   
    local r = 0
    if atktot > 0 then
        r = GetRandom(atktot)+1
        for i = 1,maxWep do
        --for w,c in pairs(atkChoices) do
            --WriteLnToConsole('     c: '..c..' w:'..w..' r:'..r)
            if atkChoices[i] >= r then
                setGearValue(gear,i,1)
				all_hhgs[gear] = {["gear"] = gear, ["weapons"] = {i}}
                break
            end
        end
    end
    if utiltot > 0 then
        r = GetRandom(utiltot)+1
        for i = 1,maxWep do
       -- for w,c in pairs(utilChoices) do
            --WriteLnToConsole('util c: '..c..' w:'..w..' r:'..r)
            if utilChoices[i] >= r then
                setGearValue(gear,i,1)
				all_hhgs[gear]["weapons"][2] = i 
                break
            end
        end
    end

   
   -- weapons in hog name
  				if last_team == nil then
                    last_team = GetHogTeamName(gear)
                    SetHogName(gear, tostring(hog_numer) .. ' ' .. allWeapons[all_hhgs[gear]["weapons"][1]] .. " ".. allWeapons[all_hhgs[gear]["weapons"][2]])
                    hog_numer = hog_numer +1
                elseif last_team == GetHogTeamName(gear) then
                    SetHogName(gear, tostring(hog_numer) .. ' ' .. allWeapons[all_hhgs[gear]["weapons"][1]] .. " ".. allWeapons[all_hhgs[gear]["weapons"][2]])
                    hog_numer = hog_numer +1
                else
                    last_team = GetHogTeamName(gear)
                    hog_numer = 1
                    SetHogName(gear, tostring(hog_numer) .. ' ' .. allWeapons[all_hhgs[gear]["weapons"][1]] .. " ".. allWeapons[all_hhgs[gear]["weapons"][2]])
                    hog_numer = hog_numer +1
                end

end

--[[function SaveWeapons(gear)
-- er, this has no 0 check so presumably if you use a weapon then when it saves  you wont have it

	for i = 1, (#wepArray) do
		setGearValue(gear, wepArray[i], GetAmmoCount(gear, wepArray[i]) )
		 --AddAmmo(gear, wepArray[i], getGearValue(gear,wepArray[i]) )
	end

end]]

function ConvertValues(gear)
    for w,c in pairs(wepArray) do
		AddAmmo(gear, w, getGearValue(gear,w) )
    end
end


-- this is called when a hog dies
function TransferWeps(gear)

	wep2 = ""

	if CurrentHedgehog ~= nil then

        for w,c in pairs(wepArray) do
			val = getGearValue(gear,w)
			if val ~= 0 and (mode == "orig" or (wepArray[w] ~= 9 and getGearValue(CurrentHedgehog, w) == 0))  then
				setGearValue(CurrentHedgehog, w, val)
				table.insert(all_hhgs[CurrentHedgehog]["weapons"], w)
				-- if you are using multi-shot weapon, gimme one more
				if (GetCurAmmoType() == w) and (shotsFired ~= 0) then
					AddAmmo(CurrentHedgehog, w, val+1)
				-- assign ammo as per normal
				else
					AddAmmo(CurrentHedgehog, w, val)
					wep2 = wep2 .. allWeapons[w] .. ", "
				end

			end
		end

	end

	if (wep2 ~= "") then
		AddCaption("Weapons: " .. wep2, 0xffba00ff, capgrpAmmoinfo)
	end
end

function onGameInit()
	EnableGameFlags(gfInfAttack, gfRandomOrder, gfPerHogAmmo)
	DisableGameFlags(gfResetWeps, gfSharedAmmo)
	HealthCaseProb = 100
end

function onGameStart()
    utilChoices[amSkip] = 0
    local c = 0
    for i = 1,maxWep do
        atkChoices[i] = 0
        utilChoices[i] = 0
        if i ~= 7 then
            wepArray[i] = 0
            c = GetAmmoCount(someHog, i)
            if c > 8 then c = 9 end
            wepArray[i] = c
            if c < 9 and c > 0 then
                if atkWeps[i] then
                    --WriteLnToConsole('a    c: '..c..' w:'..i)
                    atktot = atktot + probability[c]
                    atkChoices[i] = atktot
                elseif utilWeps[i] then
                    --WriteLnToConsole('u    c: '..c..' w:'..i)
                    utiltot = utiltot + probability[c]
                    utilChoices[i] = utiltot
                end
            end
        end
    end

    --WriteLnToConsole('utiltot:'..utiltot..' atktot:'..atktot)
        
	ShowMission	(
				loc("HIGHLANDER (HACKED)"),
				loc("Not all hogs are born equal."),

				"- " .. loc("Eliminate enemy hogs and take their weapons.") .. "|" ..
				"- " .. loc("Per-Hog Ammo") .. "|" ..
				"- " .. loc("Weapons reset.") .. "|" ..
				"- " .. loc("Unlimited Attacks") .. "|" ..
				"", 4, 2000
				)

	runOnGears(StartingSetUp)
	runOnGears(ConvertValues)
end

function CheckForHogSwitch()

	if (CurrentHedgehog ~= nil) then

		currHog = CurrentHedgehog

		if currHog ~= lastHog then

			-- re-assign ammo to this guy, so that his entire ammo set will
			-- be visible during another player's turn
			if lastHog ~= nil then
				ConvertValues(lastHog)
			end

			-- give the new hog what he is supposed to have, too
			ConvertValues(CurrentHedgehog)

		end

		lastHog = currHog

	end

end

function onNewTurn()
	CheckForHogSwitch()
	preciseHeld = false
end


--function onGameTick20()
--CheckForHogSwitch()
-- if we use gfPerHogAmmo is this even needed? Err, well, weapons reset, so... yes?
-- orrrr, should we rather call the re-assignment of weapons onNewTurn()? probably not because
-- then you cant switch hogs... unless we add a thing in onSwitch or whatever
-- ye, that is probably better actually, but I'll add that when/if I add switch
--end

--[[function onHogHide(gear)
	-- waiting for Henek
end

function onHogRestore(gear)
	-- waiting for Henek
end]]

function onGearAdd(gear)

	--if GetGearType(gear) == gtSwitcher then
	--	SaveWeapons(CurrentHedgehog)
	--end

	if (GetGearType(gear) == gtHedgehog) then
		trackGear(gear)
        if someHog == nil then someHog = gear end
	-- cheating fanat code start
	elseif (GetGearType(gear) == gtMine) then
	    allMines[gear] = gear
	elseif (GetGearType(gear) == gtExplosives) then
		allBarrels[gear] = gear
	elseif (GetGearType(gear) == gtAirMine) then
		allAirMines[gear] = gear
	-- cheating fanat code end
	end

end

function onGearDelete(gear)

	if (GetGearType(gear) == gtHedgehog) then --or (GetGearType(gear) == gtResurrector) then
		--table.remove(all_hhgs[gear])
		TransferWeps(gear)
		trackDeletion(gear)
	end

end

