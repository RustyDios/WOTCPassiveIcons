//*******************************************************************************************
//  FILE:   X2Ability_RustyAddedPassives.uc                                    
//  
//	File created by RustyDios	27/10/19	20:30	
//	LAST UPDATED				08/12/19	15:40
//
//	This file adds new pure passives for abilities that don't 'trigger' on tac map start 
//		or basically anything I couldn't get to work fully in OPTC
//	Adds passive ability icons for the ruler armours panic (and Bio 2.0 Damage PCS)
//
//*******************************************************************************************

class X2Ability_RustyAddedPassives extends X2Ability config (XComWOTC_PI_CONFIG);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// Templates.AddItem(PurePassive('SerpentPanicPassive', "UILibrary_XPACK_Common.PerkIcons.strx_viperhunter", true, 'eAbilitySource_Item'));
	// Templates.AddItem(PurePassive('RagePanicPassive', "UILibrary_XPACK_Common.PerkIcons.strx_mutonhunter", true, 'eAbilitySource_Item'));
	// Templates.AddItem(PurePassive('IcarusPanicPassive', "UILibrary_XPACK_Common.PerkIcons.strx_archonhunter", true, 'eAbilitySource_Item'));

	Templates.AddItem(PurePassive('SerpentPanicPassive', "UILibrary_PerkIcons.UIPerk_mindmerge2", true, 'eAbilitySource_Item'));
	Templates.AddItem(PurePassive('RagePanicPassive', "UILibrary_PerkIcons.UIPerk_mindmerge2", true, 'eAbilitySource_Item'));
	Templates.AddItem(PurePassive('IcarusPanicPassive', "UILibrary_PerkIcons.UIPerk_mindmerge2", true, 'eAbilitySource_Item'));

	Templates.AddItem(PurePassive('VaultAbilityPassive', "img:///UILibrary_DLC2Images.UIPerk_icarusvault", true, 'eAbilitySource_Item'));

	Templates.AddItem(PurePassive('BioDamageControlPassive', "img:///UILibrary_PerkIcons.UIPerk_damage_control", true, 'eAbilitySource_Item'));

	return Templates;
}	
