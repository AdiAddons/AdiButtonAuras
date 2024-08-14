std = 'lua51'

quiet = 1 -- suppress report output for files without warnings.

only = {
	'011', -- syntax error
	'111', -- setting an undefined global variable
	'112', -- mutating an undefined global variable
	'113', -- accessing an undefined global variable
	'611', -- a line consists of nothing but whitespace
	'612', -- a line contains trailing whitespace
	'613', -- trailing whitespace in a string
	'614', -- trailing whitespace in a comment
	'621', -- inconsistent indentation (SPACE followed by TAB)
}

exclude_files = {
	'./tests/*'
}

read_globals = {
	-- Addons and Libraries
	'AceGUIWidgetLSMlists',
	'AdiButtonAuras',
	'AdiDebug',
	'LibStub',

	-- ABA API
	'AddRuleFor',
	'BuffAliases',
	'BuildAuraHandler_FirstOf',
	'BuildAuraHandler_Longest',
	'BuildAuraHandler_Single',
	'BuildDispelHandler',
	'BuildDesc',
	'BuildKey',
	'Configure',
	'DebuffAliases',
	'Debug',
	'DescribeAllSpells',
	'DescribeAllTokens',
	'DescribeFilter',
	'DescribeHighlight',
	'DescribeLPSSource',
	'GetBuff',
	'GetDebuff',
	'GetLib',
	'GetPlayerBuff',
	'GetPlayerDebuff',
	'ImportPlayerSpells',
	'IterateBuffs',
	'IterateDebuffs',
	'IteratePlayerBuffs',
	'IteratePlayerDebuffs',
	'L',
	'LongestDebuffOf',
	'PassiveModifier',
	'PetBuffs',
	'PLAYER_CLASS',
	'SelfBuffAliases',
	'SelfBuffs',
	'SharedSimpleBuffs',
	'SharedSimpleDebuffs',
	'ShowDispellable',
	'ShowHealth',
	'ShowPower',
	'ShowStacks',
	'ShowTempPet',
	'ShowTempWeaponEnchant',
	'ShowTotem',
	'SimpleBuffs',
	'SimpleDebuffs',

	-- WoW API
	C_AddOns = {
		fields = {
			'GetAddOnMetadata',
			'IsAddOnLoaded',
			'LoadAddOn',
		},
	},
	C_Spell = {
		fields = {
			'GetSpellCharges',
			'GetSpellCastCount',
			'GetSpellInfo',
			'GetSpellLink',
			'GetSpellName',
		},
	},
	C_SpellBook = {
		fields = {
			'HasPetSpells',
		},
	},
	'GetNumGroupMembers',
	'GetPetTimeRemaining',
	'GetRuneCooldown',
	'GetShapeshiftFormID',
	'GetSpellBonusHealing',
	'GetTime',
	'GetTotemInfo',
	'GetWeaponEnchantInfo',
	'IsPlayerSpell',
	'UnitCanAttack',
	'UnitCastingInfo',
	'UnitChannelInfo',
	'UnitClass',
	'UnitGUID',
	'UnitHealth',
	'UnitHealthMax',
	'UnitIsDeadOrGhost',
	'UnitIsPlayer',
	'UnitName',
	'UnitPower',
	'UnitPowerMax',
	'UnitStagger',

	-- Lua API
	'bit',
	'ceil',
	'floor',
	'format',
	'ipairs',
	'math',
	'max',
	'min',
	'pairs',
	'print',
	'select',
	'string',
	'strmatch',
	'table',
	'tinsert',
	'type',
}
