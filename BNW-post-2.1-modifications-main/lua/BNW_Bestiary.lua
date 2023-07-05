-- ========= FF6 Lua Bestiary v1.01 ========= --
--  * Bestiary. L when at the main menu, or while paused in combat.
--    When in combat, it will only show the enemies in the current fight.
--    When at the main menu, it will show every enemy in the game. Beware spoilers!
--  * Switch bestiary pages with Y. Scroll with any d-pad direction. Close with B.

-- Set this to true to only allow the bestiary to be shown in battle, not the main menu (should not be local)
-- will inherit from other scripts if this script is used as a plugin instead of standalone
disableMainMenuBestiary = disableMainMenuBestiary or false

----------------- code below here, nothing else to touch -------------------


_bst = {}
_bst.allowBestiary = true

_bst.monSpecials = {
[0x00]="+Blind", [0x01]="+Zombie", [0x02]="+Poison", [0x03]="+Magitek", [0x04]="+Invis", [0x05]="+Imp", [0x06]="+Stone", [0x07]="+Death", [0x08]="+Doom", [0x09]="+Critical", [0x0A]="+Blink", [0x0B]="+Silence", [0x0C]="+Berserk", [0x0D]="+Muddle", [0x0E]="+Sap", [0x0F]="+Sleep", [0x10]="+Dance", [0x11]="+Regen", [0x12]="+Slow", [0x13]="+Haste", [0x14]="+Stop", [0x15]="+Shell", [0x16]="+Safe", [0x17]="+Reflect", [0x18]="+Rage", [0x19]="+Frozen", [0x1A]="+Reraise", [0x1B]="+Morph", [0x1C]="+Spellcast", [0x1D]="+Flee", [0x1E]="+Interceptor", [0x1F]="+Float", [0x20]=" Damage + 50%", [0x21]=" Damage +100%", [0x22]=" Damage +150%", [0x23]=" Damage +200%", [0x24]=" Damage +250%", [0x25]=" Damage +300%", [0x26]=" Damage +350%", [0x27]=" Damage +400%", [0x28]=" Damage +450%", [0x29]=" Damage +500%", [0x2A]=" Damage +550%", [0x2B]=" Damage +600%", [0x2C]=" Damage +650%", [0x2D]=" Damage +700%", [0x2E]=" Damage +750%", [0x2F]=" Damage +800%",
}

_bst.inputs = { { nil, nil, nil, nil, "R", "L", "X", "A", },
				 { "Right", "Left", "Down", "Up", "Start", "Select", "Y", "B" } }
function _bst.trim(out) return (out:gsub("^%s*(.-)%s*$", "%1")) end
function _bst.translateStringFromGame(byteTable)
	local out = ""
	for i=1,#byteTable do
		local hex = byteTable[i]
		if (textMap[hex]) then 
			out = out .. textMap[hex]
		else
			out = out .. " "
		end
	end
	out = _bst.trim(out)
	return out
end

function _bst.getStringFromGame(idx,offset,length)
    local end_offset = offset + (idx*length)
    local n = memory.readbyterange(end_offset, length)
    return translateStringFromGame(n)
end
_bst.vulnStatusList = { {"Blind", "Zombi", "Poisn", "", "", "Imp  ", "Stone", "Death"},
                       {"", "", "", "Mute ", "Bserk", "Muddl", "Sap  ", "Sleep"},
                       {"", "", "Slow ", "", "Stop ", "", "", ""} }
_bst.blockedStatusList = { {"Blind", "Zombi", "Poisn", "", "", "Imp  ", "Stone", "Death"},
                       {"", "", "", "Mute ", "Bserk", "Muddl", "Sap  ", "Sleep"},
                       {"", "", "Slow ", "", "Stop ", "", "", ""} }
_bst.appliedStatusList = { {"", "Zombi", "", "", "", "", "", ""},
                       {"", "", "", "", "", "", "Sap  ", ""},
                       {"Float", "Regen", "", "Haste", "", "Shell", "Safe ", "Rflct"} }
                       
function _bst.getStatuses(byteA,byteB,byteC,tablify,vulnerables, statuses)
	local outStatuses = {}
 for _,byte in pairs({ byteA, byteB, byteC }) do
        for i=1,#statuses[_] do
            if (statuses[_][i] ~= "") then
                local val = bit.band(byte,bit.lshift(1,(i-1)))
                if ((not vulnerables) and val > 0) then
                    outStatuses[#outStatuses+1] = statuses[_][i]
                elseif (vulnerables and val == 0) then
                    outStatuses[#outStatuses+1] = statuses[_][i]
                end
            end
        end
    end
	if (tablify) then return outStatuses end
	local out = ""
	for _,v in pairs(outStatuses) do
		out = out .. v .. " "
		if (_ % 6 == 0) then out = out .. "\n      " end
	end
	return _bst.trim(out)
end

-- initialize/detect mod type
_bst.Mod = {
    English  = 1,
    Vanilla  = 1,
    FF6E     = 1,
    Japanese = 2,
    FF6J     = 2,
    ROTDS    = 3,
    BNW      = 4,
    TEdition = 5,
    T        = 5,
    Tedition = 5,
    TMato    = 6,
}
_bst.MODS = { 
    ["FINAL FANTASY 3"]             = _bst.Mod.English,  -- vanilla, default
    ["FINAL FANTASY 6"]             = _bst.Mod.Japanese, -- jp vanilla
    ["ROTDS VERSION"]               = _bst.Mod.ROTDS,    -- uses rotds extended item/spell names
    ["FF6: BRAVE NEW WORLD"]        = _bst.Mod.BNW,      -- mod'd dance chance, uses extended skill names
    ["FF6 T-Edition"]               = _bst.Mod.TEdition, -- japanese rom, english translation
}


function _bst.initialize_mod_type()
    _bst.oldromname = _bst.romname
    -- read type from header, translate to string
    _bst.romname = memory.readbyterange(0xC0FFC0,0x14)
    for i=1,#_bst.romname do _bst.romname[i] = string.char(_bst.romname[i]) end
    _bst.romname = _bst.trim(table.concat(_bst.romname))
    if (_bst.romname ~= _bst.oldromname) then
        _bst.initialize()
    end
end
function _bst.initBestiaryUI()
    _bst.bestiaryUi = {}
        _bst.bestiaryUi.x = 260
        _bst.bestiaryUi.Display = false
        _bst.bestiaryUi.Hovered = 1
        _bst.bestiaryUi.Transitioning = 0
        _bst.bestiaryUi.Page = 1
        _bst.bestiaryUi.FilterMode = 1
        _bst.bestiaryUi.OnScreenEntries = 27
        _bst.bestiaryUi.EntryOffset = 0
        _bst.bestiaryUi.ToggleShowAll = false
end
function _bst.initialize()
    -- check what it starts with and set the rom to that type
    for i,v in pairs(_bst.MODS) do
        if (_bst.romname:sub(1,#i) == i) then _bst.MOD_TYPE = v break end
    end
    if (not _bst.MOD_TYPE) then
        print("Unknown mod detected. Using FF6 USA as type.")
        _bst.MOD_TYPE = _bst.Mod.Vanilla
    elseif (_bst.MOD_TYPE == _bst.Mod.TEdition) then
        -- checks if a specific string in the rom is "Inn" 
        local romname = memory.readbyterange(0x5FF2A1,3)
        if (romname[1] == 0x28 and romname[2] == 0x47 and romname[3] == 0x47) then
            _bst.MOD_TYPE = _bst.Mod.TMato
        end
    end
	
    _bst.initBestiaryUI()

    -- vanilla
    -- offset start, text length, index start
    _bst.paused = 0
    _bst.keymap = {}
    _bst.keymapLastFrame = {}
    _bst.keyHeldFrameTime = {}
    _bst.currentEnemyStates = {}

    _bst.textMap = { [0x80] = "A", [0x81] = "B", [0x82] = "C", [0x83] = "D", [0x84] = "E", [0x85] = "F", [0x86] = "G", [0x87] = "H", [0x88] = "I", [0x89] = "J", [0x8A] = "K", [0x8B] = "L", [0x8C] = "M", [0x8D] = "N", [0x8E] = "O", [0x8F] = "P", [0x90] = "Q", [0x91] = "R", [0x92] = "S", [0x93] = "T", [0x94] = "U", [0x95] = "V", [0x96] = "W", [0x97] = "X", [0x98] = "Y", [0x99] = "Z", [0x9A] = "a", [0x9B] = "b", [0x9C] = "c", [0x9D] = "d", [0x9E] = "e", [0x9F] = "f", [0xA0] = "g", [0xA1] = "h", [0xA2] = "i", [0xA3] = "j", [0xA4] = "k", [0xA5] = "l", [0xA6] = "m", [0xA7] = "n", [0xA8] = "o", [0xA9] = "p", [0xAA] = "q", [0xAB] = "r", [0xAC] = "s", [0xAD] = "t", [0xAE] = "u", [0xAF] = "v", [0xB0] = "w", [0xB1] = "x", [0xB2] = "y", [0xB3] = "z", [0xB4] = "0", [0xB5] = "1", [0xB6] = "2", [0xB7] = "3", [0xB8] = "4", [0xB9] = "5", [0xBA] = "6", [0xBB] = "7", [0xBC] = "8", [0xBD] = "9", [0xBE] = "!", [0xBF] = "?", [0xC3] = "'", [0xC4] = "-", [0xC5] = ".", }


	_bst.offNames = {
		spells = { 0xE6F567, 7, 0 },
		espers = { 0xE6F6E1, 8, 54 },
	   attacks = { 0xE6F7B9, 10, 81 },
	espattacks = { 0xE6FE8F, 10, 256 },
		dances = { 0xE6FF9D, 12, 283 },
    }
	_bst.offMonsterData = 0xCF0000
	_bst.lenMonsterData = 32
	_bst.offMonsterNames = 0xCFC050
	_bst.lenMonsterNames = 10
	_bst.offRageSkills = 0xCF4600
	_bst.offSketchSkills = 0xCF4300
	_bst.offControlSkills = 0xCF3D00
	_bst.offItemNames = 0xD2B300
	_bst.lenItemNames = 13
	_bst.offCommandNames = 0xD8CEA0
	_bst.lenCommandNames = 7
	_bst.offMonsterSpecialNames = 0xCFD0D0
	_bst.lenMonsterSpecialNames = 10
    _bst.monsterCount = 0x17F
	_bst.offPaused = 0x7E62ab
	_bst.offSteal = 0xCF3000
	_bst.offDrop = 0xCF3002
	_bst.lenStealDrop = 4
	_bst.offDances = 0xCFFE80
	_bst.offBattleMenuColumnDance = 0x7E8937
	_bst.offBattleMenuColumnRage = 0x7E892F
	_bst.offCursorState = 0x7E7bc2
	_bst.offWhichCharacter = 0x7E62ca
	_bst.offKnownRages = 0x7E257E
	_bst.lenKnownRages = 256
	_bst.offMenuClosingByte = 0x7E7BCB
	_bst.offTargettedMonsterByte = 0x7E7B7E
	_bst.offBattleCommandHover = 0x7E890F
	_bst.offBattleCommandList = 0x7E202E
	_bst.controlEnabled = true -- some hacks like BNW or T-Edition have removed relm's control from the game
    _bst.ragnarokEnabled = true -- some hacks have no ragnarok
	_bst.offKnownDances = 0x7E1D4C -- save ram
    _bst.offRagnarokChances = 0xC23DC5
    _bst.GameScenes = {
        Battle      = 0xC10BA7, -- combat
        Menu        = 0xC31387, -- any menu
    }
	if (_bst.MOD_TYPE == _bst.Mod.ROTDS) then
		_bst.offNames.spells = { 0xF16100, 9, 0 }
		_bst.offNames.espers = { 0xF162E6, 12, 54 }
		_bst.offNames.attacks = { 0xF1645E, 16, 81 }
		_bst.offNames.espattacks = { 0xF16DDE, 16, 256 }
		_bst.offNames.dances = { 0xF170FE, 13, 283 }
		_bst.lenItemNames = 13
	elseif (_bst.MOD_TYPE == _bst.Mod.BNW) then
		_bst.offNames.spells = { 0xEFFC00, 8, 0 }
		_bst.offNames.espers = { 0xEFFDB0, 9, 54 }
		_bst.offNames.attacks = { 0xE6F567, 11, 81 }
		_bst.offNames.espattacks = { 0xE6FCEC, 11, 256 }
		_bst.offNames.dances = { 0xE6FFA9, 12, 283 }
		_bst.controlEnabled = false
        _bst.ragnarokEnabled = false
	elseif (_bst.MOD_TYPE == _bst.Mod.TEdition or _bst.MOD_TYPE == _bst.Mod.TMato) then
        if (_bst.MOD_TYPE == _bst.Mod.TEdition) then
            _bst.textMap = { [0x60] = "A", [0x61] = "B", [0x62] = "C", [0x63] = "D", [0x64] = "E", [0x65] = "F", [0x66] = "G", [0x67] = "H", [0x68] = "I",
                [0x69] = "J", 
                [0x6A] = "K", [0x6B] = "L", [0x6C] = "M", [0x6D] = "N", [0x6E] = "O", [0x6F] = "P", [0x70] = "Q", [0x71] = "R", [0x72] = "S", [0x73] = "T", 
                [0x74] = "U", [0x75] = "V", [0x76] = "W", [0x77] = "X", [0x78] = "Y", [0x79] = "Z", 
                [0x7A] = "a", [0x7B] = "b", [0x7C] = "c", [0x7D] = "d", [0x7E] = "e", [0x7F] = "f", [0x80] = "g", [0x81] = "h", [0x82] = "i", [0x83] = "j", 
                [0x84] = "k", [0x85] = "l", [0x86] = "m", [0x87] = "n", [0x88] = "o", [0x89] = "p", [0x8A] = "q", [0x8B] = "r", [0x8C] = "s", [0x8D] = "t", 
                [0x8E] = "u", [0x8F] = "v", [0x90] = "w", [0x91] = "x", [0x92] = "y", [0x93] = "z", 
                [0x53] = "0", [0x54] = "1", [0x55] = "2", [0x56] = "3", [0x57] = "4", [0x58] = "5", [0x59] = "6", [0x5A] = "7", [0x5B] = "8", [0x5C] = "9", 
                [0x94] = "!", [0x95] = "?", [0x96] = ":", [0x97] = '"', [0x98] = "-", [0x99] = ".", 
                [0x9A] = ",", 
                [0x9B] = "_",
                [0x9C] = "(",
                [0x9D] = ")",
                [0x9E] = "'",
                [0x9F] = "#",
                [0xA0] = "ñ",
                [0xCD] = "%",
                [0xCE] = "/",
                [0xCF] = ";",
                [0x5F] = " ",
                -- extended glyphs
                [0x1FF0] = "~",
                [0x1FF1] = "&",
                [0x1FC7] = "*",
            }
            _bst.offItemNames = 0xD85000
            _bst.lenItemNames = 9
            _bst.offNames.spells = { 0xE97240, 9, 0 }
            _bst.offNames.espers  = { 0x58ED00, 8, 54 }
            _bst.offNames.attacks = { 0xE9756A, 17, 81 }
            --_bst.offNames.espattacks = { } -- not used for anything yet
            _bst.offNames.dances = { 0x58F000, 8, 283 }
            _bst.offMonsterNames = 0xCFC400
            _bst.lenMonsterNames = 8
            _bst.offMonsterSpecialNames = 0x401000
        elseif (_bst.MOD_TYPE == _bst.Mod.TMato) then
            _bst.textMap = { 
              [0x20] = "A", [0x21] = "B", [0x22] = "C", [0x23] = "D", [0x24] = "E", [0x25] = "F", [0x26] = "G", [0x27] = "H", [0x28] = "I", [0x29] = "J", 
              [0x2A] = "K", [0x2B] = "L", [0x2C] = "M", [0x2D] = "N", [0x2E] = "O", [0x2F] = "P", [0x30] = "Q", [0x31] = "R", [0x32] = "S", [0x33] = "T", 
              [0x34] = "U", [0x35] = "V", [0x36] = "W", [0x37] = "X", [0x38] = "Y", [0x39] = "Z", 
              [0x3A] = "a", [0x3B] = "b", [0x3C] = "c", [0x3D] = "d", [0x3E] = "e", [0x3F] = "f", [0x40] = "g", [0x41] = "h", [0x42] = "i", [0x43] = "j", 
              [0x44] = "k", [0x45] = "l", [0x46] = "m", [0x47] = "n", [0x48] = "o", [0x49] = "p", [0x4A] = "q", [0x4B] = "r", [0x4C] = "s", [0x4D] = "t", 
              [0x4E] = "u", [0x4F] = "v", [0x50] = "w", [0x51] = "x", [0x52] = "y", [0x53] = "z", 
              [0x54] = "0", [0x55] = "1", [0x56] = "2", [0x57] = "3", [0x58] = "4", [0x59] = "5", [0x5A] = "6", [0x5B] = "7", [0x5C] = "8", [0x5D] = "9", 
              [0x5E] = "!", [0x5F] = "?", [0x60] = "/", [0x61] = ":", [0x62] = [["]], [0x63] = "'", [0x64] = "-", 
              [0x65] = ".", [0x66] = ",", [0x67] = "_", [0x68] = ";", [0x69] = "#", [0x6A] = "+", [0x6B] = "(", [0x6C] = ")", [0x6D] = "%", 
              [0x6E] = "~", [0x6F] = "*", [0x70] = "@", [0x71] = "♪", [0x72] = "=", [0x73] = [["]], [0xFF] = [[ ]],
              [0x01] = "<NL>", [0xB3] = "[", [0xB4] = "]", [0xA0] = "&",
            }
            _bst.offItemNames = 0x59A560
            _bst.lenItemNames = 20
            _bst.offNames.spells = { 0x55c730, 9, 0 }
            _bst.offNames.espers  = { 0x558F20, 20, 54 }
            _bst.offNames.attacks = { 0x557F8C, 20, 93 }
            --_bst.offNames.espattacks = { } -- not used for anything yet
            _bst.offNames.swdtech = { 0x55a990, 12, 85 }
            _bst.offNames.misc_player = { 0x557E9C, 20, 81 }
            _bst.offNames.dances = { 0x558e20, 20, 283 }
            _bst.offMonsterNames = 0x55d650
            _bst.lenMonsterNames = 20
            _bst.offMonsterSpecialNames = 0x54d730
            _bst.lenMonsterSpecialNames = 20
        end
        _bst.monSpecials[0x05] = "+Imp" -- imp -> toad in t-edition
        _bst.monSpecials[0x0E] = "+Sap" -- sap -> disease
        _bst.monSpecials[0x30] = "+HP Absorb" -- new
        _bst.monSpecials[0x31] = "+MP Absorb" -- new
        _bst.monSpecials[0x32] = "+Reflectbreaker" -- new
		_bst.offMonsterData = 0x573E00
		_bst.lenMonsterData = 32
        _bst.monsterCount = 0x1FE
		_bst.offRageSkills = 0xCF1600
		_bst.offSketchSkills = 0xCF1200
		_bst.offControlSkills = 0xCF3D00
		_bst.offPaused = 0x7E627b
		_bst.offSteal = 0x41EA00
		_bst.offDrop = 0x41EA04
		_bst.lenStealDrop = 8
		_bst.offBattleMenuColumnDance = 0xC08907
		_bst.offBattleMenuColumnRage = 0xC08900
		_bst.offCursorState = 0xC07B92
		_bst.offWhichCharacter = 0xC0629a
		_bst.offKnownRages = 0xC01D2C --save ram
		_bst.lenKnownRages = 32
		_bst.offMenuClosingByte = 0xC07BC0
		_bst.offTargettedMonsterByte = 0xC07B4E
		_bst.offBattleCommandHover = 0xC088DF
		_bst.controlEnabled = false
        _bst.GameScenes = {
            Battle      = 0xC10B8A, -- combat
            Menu        = 0xC313F2, -- any menu
        }
	end
    _bst.reverseMap = {}
    for i,v in pairs(_bst.textMap) do
        _bst.reverseMap[v] = i
    end
    if (disableMainMenuBestiary) then
        print("* Bestiary loaded for ".._bst.romname..". Display with [L] when paused in battle. [Y] to switch pages, [B] to close, [DPAD] to scroll.")
    else
        print("* Bestiary loaded for ".._bst.romname..". Display with [L] on main menu or when paused in battle. [Y] to switch pages, [B] to close, [DPAD] to scroll.")
    end
end

-- skipFF to anything to prevent breaking on FF
function _bst.translate(byteTable,skipFF)
	local out = ""
	local start = 0
	if (not byteTable[start]) then start = 1 end
	for i=start,#byteTable do
		local hex = byteTable[i]
		if ((hex == 0xFF or not hex) and not skipFF) then break end
		if (_bst.textMap[hex]) then 
			out = out .. _bst.textMap[hex]
		else
			out = out .. " "
		end
	end
	out = _bst.trim(out)
	return out
end
function _bst.processEnemySpecial(idxTargetMonster,justTheSpecial)
	local monStats = memory.readbyterange(_bst.offMonsterData + (_bst.lenMonsterData * idxTargetMonster),_bst.lenMonsterData)
	local specialAttack = monStats[0x20]
	local noEvade = (bit.band(specialAttack,0x80) > 0)
	local noDamage = (bit.band(specialAttack,0x40) > 0)
	specialAttack = bit.band(specialAttack,0x3F)
	specialAttack = _bst.monSpecials[specialAttack]
	if (specialAttack) then
		if (noEvade or noDamage) then
			if (not justTheSpecial) then specialAttack = specialAttack..")\n(Special:" 
			else specialAttack = specialAttack.."\n" end
			if (noEvade) then specialAttack = specialAttack .. "Can't dodge" end
			if (noEvade and noDamage) then specialAttack = specialAttack .. " & " end
			if (noDamage) then specialAttack = specialAttack .. "No damage" end
		end
	else 
		specialAttack = "+???"
	end
	if (justTheSpecial) then return specialAttack end
	return "(Special:Attack"..specialAttack..")"
end

function _bst.getElements(byte,tablify)
	local elements = { "FIR", "ICE", "THN", "DRK", "WND", "HLY", "ERT", "WTR" }
	local outElements = {}
    for i=1,#elements do
		if (bit.band(byte,bit.lshift(1,(i-1))) > 0) then
			outElements[#outElements+1] = elements[i]
		end
	end
	if (tablify) then return outElements end
	local out = ""
	for _,v in pairs(outElements) do
		out = out .. v .. " "
		--if (_ % 5 == 0) then out = out .. "\n" end
	end
	return _bst.trim(out)
end
function _bst.getSpellName(index)
	local type = nil
	if (index >= _bst.offNames.dances[3]) then type = _bst.offNames.dances
	elseif (index >= _bst.offNames.espattacks[3]) then type = _bst.offNames.espattacks
	elseif (index >= _bst.offNames.attacks[3]) then type = _bst.offNames.attacks
    elseif (_bst.offNames.swdtech and index >= _bst.offNames.swdtech[3]) then type = _bst.offNames.swdtech
    elseif (_bst.offNames.misc_player and index >= _bst.offNames.misc_player[3]) then type = _bst.offNames.misc_player
	elseif (index >= _bst.offNames.espers[3]) then type = _bst.offNames.espers
	else type = _bst.offNames.spells
	end
	local beginOffset = type[1]
	local textLength = type[2]
	local startSkillIndex = type[3]
	local firstByte = beginOffset + ((index-startSkillIndex)*textLength)
    if (type == _bst.offNames.spells) then firstByte = firstByte + 1 end
	local out = memory.readbyterange(firstByte,textLength)
	out = _bst.translate(out)
    if (_bst.MOD_TYPE == _bst.Mod.TMato and out == "Rampage") then out = "Special" end
	return out
end
function _bst.getItemName(index)
	local out = memory.readbyterange(_bst.offItemNames + (index*_bst.lenItemNames),_bst.lenItemNames)
	out = _bst.translate(out,"don't-break-on-FF")
	if (out == "") then out = "(None)" end
	return out
end
function _bst.getMonsterSpecialName(index)
    if (_bst.MOD_TYPE == _bst.Mod.TEdition and enemyMoves) then return enemyMoves[index] end
	local out = memory.readbyterange(_bst.offMonsterSpecialNames + (index*_bst.lenMonsterSpecialNames),_bst.lenMonsterSpecialNames)
	out = _bst.translate(out,true)
	if (out == "") then out = "(None)" end
	return out
end
function _bst.getMonsterName(index)
	local out = memory.readbyterange(_bst.offMonsterNames + (index*_bst.lenMonsterNames),_bst.lenMonsterNames)
	out = _bst.translate(out,true)
	if (out == "") then out = "(None)" end
	return out
end
function _bst.getCommandName(index)
	local out = memory.readbyterange(_bst.offCommandNames + (index*_bst.lenCommandNames),_bst.lenCommandNames)
	out = _bst.translate(out)
	if (out == "") then out = "(None)" end
	return out
end

function _bst.tableAddNewLines(table,perRow,willHavePrefix,newlineIndent)
	local txtTable = ""
	local offset = 0
	if (willHavePrefix) then offset = perRow - 1 end
	for i,v in pairs(table) do
		txtTable = txtTable..v.." "
		if (i % perRow == offset) then 
			txtTable = _bst.trim(txtTable) .. "\n" 
			if (newlineIndent and newlineIndent > 0) then txtTable = txtTable..string.format("% "..newlineIndent.."s","") end
		end
	end
	txtTable = _bst.trim(txtTable)
	return txtTable
end

function _bst.doBestiary()
	if (not _bst.allowBestiary) then return end
	local combatEnemyIds = {}
	local combatEnemyIdsKeys = {}
	local menuMode = memory.readbyte(0x7E0026)
	local menuNextMode = memory.readbyte(0x7E0027)
	if (_bst.inBattle) then -- watch for enemies dyin'
		_bst.lastEnemyStates = {}
		for i,v in pairs(_bst.currentEnemyStates) do _bst.lastEnemyStates[i] = v end
		for i=5,10 do
			local deathByte = memory.readbyte(0x7E3EE4 + ((i-1)*2))
			deathByte = (bit.band(deathByte,0x80) > 0)
			_bst.currentEnemyStates[i] = deathByte
			local enemyId = memory.readword(0x7E2001 + 2*(i-5))
			if ((not _bst.lastEnemyStates[i]) and _bst.currentEnemyStates[i] and enemyId ~= 0xFFFF) then
			--	db.killEnemy(enemyId)
			end
			if (enemyId ~= 0xFFFF and (not combatEnemyIds[enemyId])) then 
				combatEnemyIds[enemyId] = true 
				combatEnemyIdsKeys[#combatEnemyIdsKeys + 1] = enemyId
			end
		end
		if ((not _bst.bestiaryUi.Display) or _bst.paused == 0) then 
			_bst.menuKeymapHijack = false 
			_bst.bestiaryUi.Display = false
		end
	end
	if ((not _bst.inBattle and menuMode == 0x05 and menuNextMode == 0x05 and not disableMainMenuBestiary) or (_bst.inBattle and _bst.paused > 0)) then
		if (_bst.keymap.L and not _bst.keymapLastFrame.L and _bst.bestiaryUi.Transitioning == 0
            and ((not battleDisplayingMenu) or (battleDisplayingMenu == "Bestiary"))) then
			_bst.bestiaryUi.Display = not _bst.bestiaryUi.Display
			if (_bst.bestiaryUi.Display) then 
				_bst.bestiaryUi.Transitioning = 1
				_bst.bestiaryUi.x = 260
				_bst.menuKeymapHijack = true
                if (_bst.inBattle and not battleDisplayingMenu) then
                    battleDisplayingMenu = "Bestiary"
                end
			elseif (not _bst.bestiaryUi.Display) then
				_bst.bestiaryUi.Transitioning = -1
				_bst.menuKeymapHijack = false
                if (_bst.inBattle and battleDisplayingMenu == "Bestiary") then
                    battleDisplayingMenu = nil
                end
			end
		end
        if (_bst.inBattle and _bst.paused and not _bst.bestiaryUi.Display) then
            local height = 144
            if (loadStatusGraphics) then 
                height = height - 8
            end
            gui.drawtext(8,height,"[L] Monster Info")
        end
		if (_bst.bestiaryUi.Display or _bst.bestiaryUi.Transitioning == -1) then
            if (_bst.inBattle) then
                _bst.bestiaryUi.FilterMode = 3
            else
                _bst.bestiaryUi.FilterMode = 2
            end
			if (_bst.bestiaryUi.ToggleShowAll) then
				_bst.bestiaryUi.FilterMode = (_bst.bestiaryUi.FilterMode + 1)
				_bst.bestiaryUi.Hovered = 1
				_bst.bestiaryUi.EntryOffset = 0
				_bst.bestiaryUi.ToggleShowAll = false
			end
			if (_bst.bestiaryUi.FilterMode == 3 and not _bst.inBattle) then _bst.bestiaryUi.FilterMode = _bst.bestiaryUi.FilterMode + 1 end
			if (_bst.bestiaryUi.FilterMode > 3) then _bst.bestiaryUi.FilterMode = 1 end
			local top = 0
			local left = 0
			local width = 248
			local height = 216
			local right = left+width
			local bottom = top+height
			
			if (_bst.bestiaryUi.Transitioning ~= 0) then 
				_bst.bestiaryUi.x = _bst.bestiaryUi.x - (24 * _bst.bestiaryUi.Transitioning)
				if (_bst.bestiaryUi.Transitioning == 1 and _bst.bestiaryUi.x <= left) then
					_bst.bestiaryUi.Transitioning = 0
					_bst.bestiaryUi.x = left
				elseif (_bst.bestiaryUi.Transitioning == -1 and _bst.bestiaryUi.x >= left+width) then
					_bst.bestiaryUi.Transitioning = 0
				end
                joypad.set(1,{}) -- negate input
			else
				_bst.bestiaryUi.x = left
			end
            -- less opaque bg color in battle coz pause bg is already there
			gui.box(_bst.bestiaryUi.x,top,width,height,(_bst.inBattle and 0x00000099) or 0x000000DD, 0xDD000000)
			--local data = db.query("killed_enemies",{"id", "numberKilled"})
            local data = {}
			if (#data == 0 and not _bst.inBattle) then _bst.bestiaryUi.FilterMode = 2 end
			local listData = {}
			if (_bst.bestiaryUi.FilterMode == 2) then
				for i=0,_bst.monsterCount do
                    local monStats = memory.readbyterange(_bst.offMonsterData + (_bst.lenMonsterData * i),_bst.lenMonsterData)
                    if (monStats[0x11] == 0xFF and monStats[0x10] == 0xFF and monStats[0x0F] == 0xFF) then
                    else
                        listData[#listData + 1] = { id = i, numberKilled = 0 }
                    end
				end
				for i,v in pairs(data) do listData[v.id + 1] = v end
			elseif (_bst.bestiaryUi.FilterMode == 1) then
				for i=0,_bst.monsterCount do
                    local monStats = memory.readbyterange(_bst.offMonsterData + (_bst.lenMonsterData * i),_bst.lenMonsterData)
                    if (monStats[0x11] == 0xFF and monStats[0x10] == 0xFF and monStats[0x0F] == 0xFF) then
                    else
                        listData[#listData + 1] = { id = i, numberKilled = 0 }
                    end
				end
				for i,v in pairs(data) do listData[i] = v end
			elseif (_bst.bestiaryUi.FilterMode == 3) then
				for i,v in pairs(combatEnemyIdsKeys) do
					listData[#listData + 1] = { id = v, numberKilled = 0 }--db.killCount(v) }
				end
			end

			if (_bst.menuKeymapHijack) then
				if ((_bst.keymap.down and not _bst.keymapLastFrame.down) or (_bst.keyHeldFrameTime.down and _bst.keyHeldFrameTime.down > 16 and _bst.keyHeldFrameTime.down % 2 == 1)) then 
					_bst.bestiaryUi.Hovered = _bst.bestiaryUi.Hovered + 1
					if (_bst.bestiaryUi.Hovered > #listData) then
						-- hard stop at end of list unless you press button again
						if (_bst.keymap.down and not _bst.keymapLastFrame.down) then _bst.bestiaryUi.Hovered = 1 
						else _bst.bestiaryUi.Hovered = #listData
						end
					end
				elseif ((_bst.keymap.up and not _bst.keymapLastFrame.up) or (_bst.keyHeldFrameTime.up and _bst.keyHeldFrameTime.up > 16 and _bst.keyHeldFrameTime.up % 2 == 1)) then
					_bst.bestiaryUi.Hovered = _bst.bestiaryUi.Hovered - 1
					if (_bst.bestiaryUi.Hovered < 1) then
						-- hard stop at end of list unless you press button again
						if (_bst.keymap.up and not _bst.keymapLastFrame.up) then _bst.bestiaryUi.Hovered = #listData 
						else _bst.bestiaryUi.Hovered = 1
						end
					end
				elseif ((_bst.keymap.left and not _bst.keymapLastFrame.left) or (_bst.keyHeldFrameTime.left and _bst.keyHeldFrameTime.left > 16 and _bst.keyHeldFrameTime.left % 2 == 1)) then
					_bst.bestiaryUi.Hovered = _bst.bestiaryUi.Hovered - 10
				elseif ((_bst.keymap.right and not _bst.keymapLastFrame.right) or (_bst.keyHeldFrameTime.right and _bst.keyHeldFrameTime.right > 16 and _bst.keyHeldFrameTime.right % 2 == 1)) then
					_bst.bestiaryUi.Hovered = _bst.bestiaryUi.Hovered + 10
				end

				if (_bst.bestiaryUi.Hovered > #listData) then _bst.bestiaryUi.Hovered = #listData
				elseif (_bst.bestiaryUi.Hovered < 1) then _bst.bestiaryUi.Hovered = 1
				end

				if (_bst.bestiaryUi.Hovered <= (_bst.bestiaryUi.EntryOffset)) then 
					_bst.bestiaryUi.EntryOffset = _bst.bestiaryUi.Hovered - 1
				elseif (_bst.bestiaryUi.Hovered > (_bst.bestiaryUi.EntryOffset + _bst.bestiaryUi.OnScreenEntries)) then 
					_bst.bestiaryUi.EntryOffset = _bst.bestiaryUi.Hovered - _bst.bestiaryUi.OnScreenEntries
				end
				
				if (_bst.keymap.Y and not _bst.keymapLastFrame.Y) then
					_bst.bestiaryUi.Page = bit.bxor(_bst.bestiaryUi.Page,3)
				end
				if (_bst.keymap.X and not _bst.keymapLastFrame.X) then
				--	if (#data > 0) then --temp
						--_bst.bestiaryUi.ToggleShowAll = true
--					end
				end
				if (_bst.keymap.B and not _bst.keymapLastFrame.B) then
					_bst.bestiaryUi.Display = false
					_bst.bestiaryUi.Transitioning = -1
					_bst.menuKeymapHijack = false
				end
                joypad.set(1,{})
			end

			local alphabetical = true
			if (alphabetical) then

			end

			for row,entry in pairs(listData) do
				local displayRow = row - _bst.bestiaryUi.EntryOffset
				if (row > _bst.bestiaryUi.EntryOffset and row <= (_bst.bestiaryUi.EntryOffset + _bst.bestiaryUi.OnScreenEntries)) then 
					local rowX = _bst.bestiaryUi.x + 4
					local rowY = top + 4 + ((displayRow - 1)*8)
					local name = _bst.getMonsterName(entry.id)
					local color = "white"
					if (combatEnemyIds[entry.id]) then
						color = 0xFF00BBFF
					elseif (entry.numberKilled == 0) then 
						--name = "??????" -- temp
						--color = 0xFF666666
					end
					if (row == _bst.bestiaryUi.Hovered) then
						color = "yellow"
					end
					gui.text(rowX,rowY,name,color,0x00000000)
				end
			end

			local monStats = memory.readbyterange(_bst.offMonsterData + (_bst.lenMonsterData * listData[_bst.bestiaryUi.Hovered].id),_bst.lenMonsterData)
            for i=1,#monStats do monStats[i-1] = monStats[i] end
			local infoPane = {}
			infoPane.top = top + 4
			infoPane.left = _bst.bestiaryUi.x + 72
			infoPane.bottom = infoPane.top + 214
			infoPane.right = infoPane.left + 168
			local infoText = ""
			local id = listData[_bst.bestiaryUi.Hovered].id
			gui.line(infoPane.left - 4, infoPane.top, infoPane.left - 4, infoPane.bottom, "white")
			if (listData[_bst.bestiaryUi.Hovered].numberKilled == 0 and false) then  -- temp
				if (combatEnemyIds[id]) then
					gui.text(infoPane.left + 2, infoPane.top, string.format("% -14s",_bst.getMonsterName(id)),0xFF00BBFF,0x00000000)
				else
					gui.text(infoPane.left + 2, infoPane.top, string.format("% -14s","??????"),"yellow",0x00000000)
				end
				infoText = "Not yet killed!"
				gui.text(infoPane.left + 15, infoPane.top + 12, infoText,"white",0x00000000)
			else
				if (combatEnemyIds[id]) then
					gui.text(infoPane.left + 2, infoPane.top, string.format("% -14s",_bst.getMonsterName(id)),"yellow",0x00000000)
				else
					gui.text(infoPane.left + 2, infoPane.top, string.format("% -14s",_bst.getMonsterName(id)),"yellow",0x00000000)
				end
				if (_bst.bestiaryUi.Page == 1) then
					gui.text(infoPane.left + 2 + (6*14) + 1, infoPane.top, string.format("Level: % -2s",monStats[0x10]),"white",0x00000000)
					--infoText = _bst.trim(infoText.."\n"..string.format("Number Killed: %s",listData[_bst.bestiaryUi.Hovered].numberKilled)) -- temp

					local monsterHP = (monStats[0x09] * 0x100) + monStats[0x08]
					local monsterMP = (monStats[0x0B] * 0x100) + monStats[0x0A]
					local monsterXP = (monStats[0x0D] * 0x100) + monStats[0x0C]
					local monsterGP = (monStats[0x0F] * 0x100) + monStats[0x0E]
					infoText = _bst.trim(infoText.."\n"..string.format("HP: % -5s  MP: % -5s",monsterHP,monsterMP))
					infoText = _bst.trim(infoText.."\n"..string.format("XP: % -5s  GP: % -5s",monsterXP,monsterGP))

					local monsterStats = { { "STR", monStats[0x01] }, { "MAG", monStats[0x07] }, { "ACC", monStats[0x02] },
										 { "SPD", monStats[0x00] }, { "EVA", monStats[0x03] }, { "MEV", monStats[0x04] },
										 { "DEF", monStats[0x05] }, { "MDF", monStats[0x06] } }
					local statsText = ""
					for i,v in pairs(monsterStats) do
						statsText = string.format("%s%s: %-3s ",statsText,v[1],v[2])
						--statsText = _bst.trim(statsText)
						if (i % 3 == 0) then statsText = statsText.."\n" end
					end
					statsText = statsText:gsub("\n ", "\n")
					infoText = infoText.."\n\n"..statsText
					local blockedStatuses = { monStats[0x14], monStats[0x15], monStats[0x16] }
					local appliedStatuses = { monStats[0x1B], monStats[0x1C], monStats[0x1D] }
					local vulnerableStatuses = {monStats[0x14], monStats[0x15], monStats[0x16] }
					local absorbElements = monStats[0x17]
					local immuneElements = monStats[0x18]
					local weakElements = monStats[0x19]
					vulnerableStatuses = _bst.getStatuses(vulnerableStatuses[1],vulnerableStatuses[2],vulnerableStatuses[3],true,true,_bst.vulnStatusList)
                    blockedStatuses = _bst.getStatuses(blockedStatuses[1],blockedStatuses[2],blockedStatuses[3],true,nil,_bst.blockedStatusList)
                    appliedStatuses = _bst.getStatuses(appliedStatuses[1],appliedStatuses[2],appliedStatuses[3],true,nil,_bst.appliedStatusList)
					if (#appliedStatuses > 0) then 
						appliedStatuses = _bst.tableAddNewLines(appliedStatuses,4,true)
						appliedStatuses = "GAINS:"..appliedStatuses
					else
						appliedStatuses = ""
					end
					if (#blockedStatuses > 0) then 
						blockedStatuses = _bst.tableAddNewLines(blockedStatuses,4,true)
						blockedStatuses = "BLOCK:"..blockedStatuses
					else
						blockedStatuses = ""
					end
					if (#vulnerableStatuses > 0) then 
						vulnerableStatuses = _bst.tableAddNewLines(vulnerableStatuses,4,true)
						vulnerableStatuses = "VULN :"..vulnerableStatuses
					else
						vulnerableStatuses = ""
					end
					infoText = infoText.."\n"
					if (#appliedStatuses > 0 or #blockedStatuses > 0) then
						infoText = _bst.trim(infoText.."\n".._bst.trim(appliedStatuses.."\n"..blockedStatuses))
					end
					if (#vulnerableStatuses > 0) then
						infoText = _bst.trim(infoText.."\n".._bst.trim(vulnerableStatuses))
					end
					absorbElements = _bst.getElements(absorbElements,true)
					immuneElements = _bst.getElements(immuneElements,true)
					weakElements = _bst.getElements(weakElements,true)
					if (#absorbElements > 0) then
						absorbElements = _bst.tableAddNewLines(absorbElements,5,true,4)
						absorbElements = "ABS:"..absorbElements
					else absorbElements = "" end
					if (#immuneElements > 0) then
						immuneElements = _bst.tableAddNewLines(immuneElements,5,true,4)
						immuneElements = "NULL:"..immuneElements
					else immuneElements = "" end
					if (#weakElements > 0) then
						weakElements = _bst.tableAddNewLines(weakElements,5,true,5)
						weakElements = "WEAK:"..weakElements
					else weakElements = "" end
					infoText = infoText.."\n"
					infoText = _bst.trim(infoText.."\n"..weakElements)
					infoText = _bst.trim(infoText.."\n"..immuneElements)
					infoText = _bst.trim(infoText.."\n"..absorbElements)

					infoText = _bst.trim(infoText)
					gui.text(infoPane.left + 2, infoPane.top + 9, infoText,"white",0x00000000)
					local _, lineCount = infoText:gsub('\n', '\n')
					lineCount = lineCount + 1
				elseif (_bst.bestiaryUi.Page == 2) then
					local stealLoc = _bst.offSteal + (_bst.lenStealDrop*id)
					local dropLoc = _bst.offDrop + (_bst.lenStealDrop*id)
					-- rare/common steal, rare/common drop
					local items = { memory.readbyte(stealLoc), memory.readbyte(stealLoc+1), memory.readbyte(dropLoc), memory.readbyte(dropLoc + 1) }
					local itemNames = { }
					for i,v in pairs(items) do
						if (v == 0xFF) then 
							itemNames[i] = "---"
						else
							itemNames[i] = _bst.getItemName(v)
						end
					end
					local infoText = ""
					infoText = _bst.trim(infoText.."\n"..string.format("Drops\nCommon:%s\n  Rare:%s\n\nSteals\nCommon:%s\n  Rare:%s",itemNames[4],itemNames[3],itemNames[2],itemNames[1]))
					if (id <= 255) then
						-- rage info
						local rageLoc = _bst.offRageSkills + (2*id)
						local rageAttacks = { memory.readbyte(rageLoc), memory.readbyte(rageLoc+1) }
						if (rageAttacks[1] == 0xFF and rageAttacks[2] == 0xFF) then
							infoText = infoText.."\n\nRage: Not rageable!"
						else
							for i=1,2 do rageAttacks[i] = _bst.getSpellName(rageAttacks[i]) end
							infoText = infoText.."\n\nRage: "..rageAttacks[1].."\n      "..rageAttacks[2]
						end
					else infoText = infoText.."\n\nRage: Not rageable!"
					end
					-- sketch info
					local cantSketchByte = monStats[0x13]
					if (bit.band(cantSketchByte,0x20) > 0) then
						infoText = infoText.."\n\nSketch: Can't sketch!"
					else
						local sketchLoc = _bst.offSketchSkills + (2*id)
						local sketchAttacks = { memory.readbyte(sketchLoc), memory.readbyte(sketchLoc+1) }
						for i=1,2 do sketchAttacks[i] = _bst.getSpellName(sketchAttacks[i]) end
						local out = "Sketch:(75%) "..sketchAttacks[2] .. "\n       (25%) " .. sketchAttacks[1] ..""
						infoText = infoText.."\n\n"..out
					end
					-- control info
					if (_bst.controlEnabled) then 
						local cantControlByte = monStats[0x13]
						if (bit.band(cantControlByte,0x80) > 0) then
							infoText = infoText.."\n\nControl: Can't control!"
						else
							local controlLoc = _bst.offControlSkills + (4*id)
							local controlAttacks = { memory.readbyte(controlLoc), memory.readbyte(controlLoc+1), memory.readbyte(controlLoc+2), memory.readbyte(controlLoc+3) }
							local namesControlAttacks = {}
							for i=1,4 do 
								if (controlAttacks[i] ~= 0xFF) then 
									namesControlAttacks[#namesControlAttacks + 1] = _bst.getSpellName(controlAttacks[i]) 
								end
							end
							local out = "Control:"..table.concat(namesControlAttacks,"\n        ")
							infoText = infoText.."\n\n"..out
						end
					end
                    if (_bst.ragnarokEnabled) then
                        local ragnarokByte = monStats[0x11]
                        local ragnarokGroup = bit.band(ragnarokByte,0x1F)
                        local ragnarokChance = bit.band(ragnarokByte,0xE0) 
                        local chance = memory.readbyte(_bst.offRagnarokChances + (ragnarokChance/32))
                        local ragnarokData = memory.readbyterange(0xC47F40 + (ragnarokGroup*4),4)
                        local ragnarokWeights = {}
                        for i=1,#ragnarokData do 
                            local name = _bst.getItemName(ragnarokData[i])
                            ragnarokData[i] = name
                            ragnarokWeights[name] = (ragnarokWeights[name] or 0) + 1
                        end
                        infoText = infoText .. ("\n\nRagnarok (%s/256): "):format(chance)
                        local count = 0
                        for i=1,#ragnarokData do
                            local name = ragnarokData[i]
                            local text = nil
                            if (ragnarokWeights[name]) then
                                text = ("[%d%%] %s"):format(ragnarokWeights[name]*25,name)
                                ragnarokWeights[name] = nil
                            end
                            if (text) then 
                                count = count + 1
                                if (count % 2 == 1) then
                                    infoText = infoText .. "\n"
                                elseif (count % 2 == 0) then
                                    infoText = infoText .. " | "
                                end
                                infoText = infoText .. text
                            end
                        end
                    end
					local specialAttack = _bst.trim(_bst.processEnemySpecial(id,true))
                    local specialName = _bst.trim(_bst.getMonsterSpecialName(id))
					infoText = infoText.."\n\nSpecial: "..specialName.."\n"..specialAttack
					gui.text(infoPane.left + 2, infoPane.top + 9, infoText,"white",0x00000000)
				end
			end
			--gui.text(_bst.bestiaryUi.x + 4, bottom - 10, "[X:Filter]".._bst.bestiaryUi.FilterMode,"white",0x00000000) -- temp
			gui.text(infoPane.right - 10, infoPane.top, _bst.bestiaryUi.Page,"white",0x00000000)
			gui.text(infoPane.right - 10, infoPane.top+9, "Y","white",0x00000000)
			gui.text(infoPane.right - 22, infoPane.top+18, string.format("#%-3s",id),"white",0x00000000) 
		end

	end
end


function _bst.main()
    _bst.initialize_mod_type()
	_bst.keymapLastFrame = _bst.keymap
    local jp = joypad.get(1)
    _bst.keymap = jp

    local NMIByte = bit.band(0x00FFFFFF,memory.readdword(0x7E1501))
    local wasBattle = _bst.inBattle
	_bst.inBattle = NMIByte == _bst.GameScenes.Battle
    _bst.paused = memory.readbyte(_bst.offPaused) --> 0x00) and 1 or 0
    if (wasBattle ~= _bst.inBattle) then
        _bst.initBestiaryUI()
    end
    _bst.doBestiary()
	if (_bst.menuKeymapHijack == true) then
		for i,v in pairs(_bst.keymapLastFrame) do -- allow for repeating
			if (_bst.keymap[i]) then 
				_bst.keyHeldFrameTime[i] = (_bst.keyHeldFrameTime[i] and (_bst.keyHeldFrameTime[i] + 1)) or 1
			else
				_bst.keyHeldFrameTime[i] = nil
			end
		end
	end    
end
-- if this isn't being appended onto an existing script, just run it
if (not main) then
    emu.registerbefore(_bst.main)
else
    -- if it is being appended, back up the old main
    -- then run that first, then run the bestiary
    _bst._old_main = main
    main = function()
        _bst._old_main()
        _bst.main()
    end
    emu.registerbefore(main)
end
-- ========= END OF BESTIARY ========= --