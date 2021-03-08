//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTCPassiveIcons.uc                                    
//  
//	File created by RustyDios	06/08/19	01:30	
//	LAST UPDATED				19/07/20	05:00
//
//	Included changes copied from ADVENT Avengers "Ability Tweaks" Mod;;
//		Added a bunch of tweaks for other mods Passive (Vest) Icons
//	FOR FULL LIST (INCLUDING OTHER .INI CHANGES) SEE THE README.TXT
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTCPassiveIcons extends X2DownloadableContentInfo config (WOTC_PI_CONFIG);

// Grab strings from the localisation files
var localized array <string> RustyLocName, RustyLocDesc;

// Grab variables from the config
var config bool bPI_ICONS_SPARKVAULT;

var config bool bPI_ICONS_STASISVEST, bPI_ICONS_STUNVEST_MOD, bPI_ICONS_HELLWEAVE, bPI_ICONS_FLAMEVIPER_MOD, bPI_ICONS_HAZMATVEST, bPI_ICONS_VALENTINESVIPER_MOD, bPI_ICONS_BIONANO_MOD, bPI_ICONS_BIOVIPER_MOD;
var config bool bPI_ICONS_BIOVIPERADV_MOD, bPI_ICONS_COTKVIPERVEST_MOD, bPI_ICONS_BITTERFROST_MOD, bPI_ICONS_PASSIVEWALL, bPI_ICONS_PASSIVEWALLVEST_MOD, bPI_ICONS_PHANTOMVEST_MOD, bPI_ICONS_WALKERSERVOS_MOD;

var config bool bPI_ICONS_MINDSHIELD, bPI_ICONS_MINDSHIELDADV_MOD, bPI_ICONS_MEDIKIT, bPI_ICONS_MEDIKITNANO, bPI_ICONS_MEDIKITBIO_MOD, bPI_ICONS_BIOPCS_MOD, bPI_ICONS_REFRACTION_MOD, bPI_ICONS_MOFSHIELDS_MOD;
var config bool bPI_ICONS_GTSSPARKREGEN_MOD, bPI_ICONS_RULERPANIC, bPI_ICONS_RULERPANIC_MODENEMIES_ICARUS, bPI_ICONS_RULERPANIC_MODENEMIES_TAURIANS, bPI_ICONS_RULERPANIC_MODENEMIES_SERPENTINE, bPI_ICONS_RULER_HIVECLIMB_MOD;

var config bool bPI_ICONS_SKULLMINE, bPI_ICONS_LOWVIS, bPI_ICONS_SUSTAINSPHERE, bPI_ICONS_MELEERES, bPI_ICONS_HOLYWARRIOR, bPI_ICONS_ARMORANDVESTCONFIG, bPI_ICONS_NANOLW;

var config bool bPI_DAMAGECHANGE_HELLWEAVE;
var config int iPI_HELLWEAVE_BASE, iPI_HELLWEAVE_PLUS, iPI_HELLWEAVE_SPREAD, iPI_HELLWEAVE_PIERCE;
var config name nPI_HELLWEAVE_TYPE;

var config bool bAddBonusToStasis, bAddBonusToHellweave, bAddBonusToHazmat, bAddBonusToNanoMedikit, bAddBonusToBioMedikit, bAddBonusToHolyWarrior;

/// Called on first time load game if not already installed	
static event OnLoadedSavedGame(){}								//empty_func
static event OnLoadedSavedGameToStrategy(){}					//empty_func

/// Called on new campaign while this DLC / Mod is installed
static event InstallNewCampaign(XComGameState StartState){}		//empty_func

//*******************************************************************************************
// ADD/CHANGES AFTER TEMPLATES LOAD ~ OPTC ~
//*******************************************************************************************

static event OnPostTemplatesCreated()
{
	local X2AbilityTemplateManager				AllAbilities;			//holder for all abilities

	local X2AbilityTemplate						CurrentAbility;			//current thing to focus on

	local X2Effect								TempEffect;				//placeholder for Effects
	local X2Effect_ApplyWeaponDamage			WeaponDamageEffect;		//required to manipulate hellweave damage
	local X2Effect_DamageImmunity				DamageImmunity;			//required to manipulate 'Immunities'
	local X2Effect_SustainingSphere				SustainEffect;			//used for sustaining sphere item
	local X2Effect_EnergyShield					ShieldedEffect;			//Metal over flesh Shields extends this type
	local X2Effect_BonusArmor					ShieldHardEffect;		//Metal over flesh ShieldHarden extends this
	local X2Effect_BonusArmor					DamageControlEffect;	//Bio Div 2.0 PCS extends this
	local X2Effect_Regeneration					RegenerationEffect;		//used in GTS SPARKS
	local X2Effect_PersistentTraversalChange	PTCEffect;				//used by HIVE armour

	local X2Condition_UnitType					UnitConditionModded;	//used to fix missing mod enemies from ruler panic

	//Grab the distinct template managers(lists) to search through
	AllAbilities     = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	//////////////////////////////////////////////////////////////////////////////////////////
	//	PASSIVE VAULT ON SPARKS
	//		This gives SPARKS the Vault passive icon as they can naturally jump up
	//////////////////////////////////////////////////////////////////////////////////////////

	if (default.bPI_ICONS_SPARKVAULT)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('Overdrive');
		if (CurrentAbility != none )
		{
			CurrentAbility.AdditionalAbilities.AddItem('VaultAbilityPassive');
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	//	PASSIVE VEST/UTILITY ITEMS ICONS
	//		For any vest/utility item that grants a damage immunity
	//		Find the original ability, change the icon/colour etc, ensure it has a 'damage immunity', display it
	//		Set an Immunity to show with a Passive Icon on tactical HUD
	//		Items in ((Double Brackets)) are MOD added items
	//////////////////////////////////////////////////////////////////////////////////////////

	// NO ICON FOR	::	NANOVIBERVEST	GRANTED STUFF	:: HP BONUS				AB_TEMPLATE_NAME	::	NanofiberVestBonus
	if (default.bPI_ICONS_NANOLW)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('NanofiberVestBonus_LW');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
				DamageImmunity = new class'X2Effect_DamageImmunity';
				DamageImmunity.BuildPersistentEffect(1, true, false, false);
				DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('NanofiberVestBonus_LW'), RustyLocDescCheck('NanofiberVestBonus_LW'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
			CurrentAbility.AddTargetEffect(DamageImmunity);
		}
	}

	// NO ICON FOR	::	PLATED VEST		GRANTED STUFF	:: HP BONUS, AP BONUS	AB_TEMPLATE_NAME	::	PlatedVestBonus

	// NEW PASSIVE ICON FOR	::	STASIS VEST 
	// IMMUNITIES GRANTED	::	2HP REGEN, MAX 8HP ([BLEEDING])
	if (default.bPI_ICONS_STASISVEST)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('StasisVestBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
				DamageImmunity = new class'X2Effect_DamageImmunity';
				if (default.bAddBonusToStasis)
				{
					DamageImmunity.ImmuneTypes.AddItem('Bleeding');
				}
				DamageImmunity.BuildPersistentEffect(1, true, false, false);
				DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('StasisVestBonus'), RustyLocDescCheck('StasisVestBonus'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
			CurrentAbility.AddTargetEffect(DamageImmunity);
		}
	}

	// NEW PASSIVE ICON FOR	::	(( ADVENT DRONES ANTI STUN VEST ))
	// IMMUNITIES GRANTED	::	STUN, DISORIENT
	if (default.bPI_ICONS_STUNVEST_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('StunDroneShield');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect ) 
			{
				if (X2Effect_DamageImmunity (TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('StunDroneShield'), RustyLocDescCheck('StunDroneShield'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	HELLWEAVE (SCORCH CIRCUITS)
	// IMMUNITIES GRANTED	::	((FIRE, CHRYSSALID POISON)) (AND DAMAGE ON HIT, SEE BELOW)
	if (default.bPI_ICONS_HELLWEAVE)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('ScorchCircuits');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_scorchcircuits";
			if (default.bAddBonusToHellweave)
			{
					DamageImmunity = new class'X2Effect_DamageImmunity';
					DamageImmunity.ImmuneTypes.AddItem(default.nPI_HELLWEAVE_TYPE);
					DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
					DamageImmunity.BuildPersistentEffect(1, true, false, false);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('ScorchCircuits'), RustyLocDescCheck('ScorchCircuits'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				CurrentAbility.AddTargetEffect(DamageImmunity);
			}

			CurrentAbility = AllAbilities.FindAbilityTemplate('ScorchCircuitsDamage');
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_scorchcircuits";
		}
	}

	// NEW PASSIVE ICON FOR	::	(( ASHLYNNES_LEE FLAME VIPER VEST ))
	// IMMUNITIES GRANTED	::	FIRE
	if (default.bPI_ICONS_FLAMEVIPER_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('Ability_AshFlameScaleVest');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_scorchcircuits";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					//DamageImmunity.ImmuneTypes.AddItem('ViperCrush');
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Ability_AshFlameScaleVest',1), RustyLocDescCheck('Ability_AshFlameScaleVest',1), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	HAZMAT VEST/SUIT
	// IMMUNITIES GRANTED	::	ACID, FIRE, POISON, CHRYSSALID POISON,((FROST, ELECTRICAL))
	if (default.bPI_ICONS_HAZMATVEST)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('HazmatVestBonus');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_flamesealant";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					if (default.bAddBonusToHazmat)
					{
						DamageImmunity.ImmuneTypes.AddItem('Electrical');
						DamageImmunity.ImmuneTypes.AddItem('Frost');
					}
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('HazmatVestBonus'), RustyLocDescCheck('HazmatVestBonus'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('HazmatVestBonus_LW');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_flamesealant";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					if (default.bAddBonusToHazmat)
					{
						DamageImmunity.ImmuneTypes.AddItem('Electrical');
						DamageImmunity.ImmuneTypes.AddItem('Frost');
					}
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('HazmatVestBonus'), RustyLocDescCheck('HazmatVestBonus'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

	}
		
	// NEW PASSIVE ICON FOR	::	(( CX VALENTINES VIPER VEST ))
	// IMMUNITIES GRANTED	::	POISON
	if (default.bPI_ICONS_VALENTINESVIPER_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('ValentinesVest_Bonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					//DamageImmunity.ImmuneTypes.AddItem('ViperCrush');
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('ValentinesVest_Bonus',2), RustyLocDescCheck('ValentinesVest_Bonus',2), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX BIO DIVISION 2.0 BIO NANO SCALE VEST ))
	// IMMUNITIES GRANTED	::	ACID (AND 2 ARMOR PIPS)
	if (default.bPI_ICONS_BIONANO_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('AdventNanoScaleVestBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('AdventNanoScaleVestBonus',3), RustyLocDescCheck('AdventNanoScaleVestBonus',3), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX BIO DIVISION 2.0 BIO VIPERSCALE VEST ))
	// IMMUNITIES GRANTED	::	ACID, POISON AND VIPER CRUSH
	if (default.bPI_ICONS_BIOVIPER_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('BioViperScaleVestBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('BioViperScaleVestBonus',4), RustyLocDescCheck('BioViperScaleVestBonus',4), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX BIO DIVISION 2.0 BIO ADVANCED VIPERSCALE VEST ))
	// IMMUNITIES GRANTED	::	ACID, (BLIND), POISON AND VIPER CRUSH
	if (default.bPI_ICONS_BIOVIPERADV_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('AdvancedBioViperScaleVestBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('AdvancedBioViperScaleVestBonus',5), RustyLocDescCheck('AdvancedBioViperScaleVestBonus',5), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	WALL PHASING (( MADE PASSIVE BY CX PSI OPS )) ADDITIONAL ABILITIES INC 'WraithActivation'
	// IMMUNITES GRANTED	::	WALL PHASING
	if (default.bPI_ICONS_PASSIVEWALL)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('WallPhasing');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_wraith";
				DamageImmunity = new class'X2Effect_DamageImmunity';
				//DamageImmunity.ImmuneTypes.AddItem('Melee');
				//DamageImmunity.ImmuneTypes.AddItem('ViperCrush');
				DamageImmunity.BuildPersistentEffect(1, true, false, false);
				DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('WallPhasing'), RustyLocDescCheck('WallPhasing'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				// The following lines stops duplicate abilities on wall phasing upgrades
			CurrentAbility.AddTargetEffect(DamageImmunity);
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX PSI OPS PHASE VEST ))
	// IMMUNITES GRANTED	::	PANIC, WALL PHASING AND LIGHTNING REFLEXES
	if (default.bPI_ICONS_PASSIVEWALLVEST_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('AdventWraithVestBonus');
		CurrentAbility.AbilitySourceName = 'eAbilitySource_Psionic';
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_wraith";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('AdventWraithVestBonus',6), RustyLocDescCheck('AdventWraithVestBonus',6), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX CHILDREN OF THE KING VIPER FROST VEST ))
	// IMMUNITES GRANTED	::	FROST AND POISON
	if (default.bPI_ICONS_COTKVIPERVEST_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('ViperFrostVestBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('ViperFrostVestBonus',7), RustyLocDescCheck('ViperFrostVestBonus',7), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( MITZRUTI BITTERFROST VEST ))
	// IMMUNITES GRANTED	::	FROST AND FIRE (AND FREEZE ON HIT, SEE MOD)
	if (default.bPI_ICONS_BITTERFROST_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('MZIceVestStats');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_scorchcircuits";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('MZIceVestStats'), RustyLocDescCheck('MZIceVestStats'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CORRUPT AVATAR PHANTOM VEST ))
	// IMMUNITES GRANTED	::	MINDSHIELD, REGEN
	if (default.bPI_ICONS_PHANTOMVEST_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('PsiVestBonus');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_mindshield";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mentalfortress";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('PsiVestBonus',12), RustyLocDescCheck('PsiVestBonus',12), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	//	PASSIVE ARMOUR HP AND STATS (PIPS, DODGE, MOBILITY ETC)
	//////////////////////////////////////////////////////////////////////////////////////////

	// WALL PHASING IS NOW MOVED ABOVE, JUST BECAUSE OF CX VEST
	
	// NEW PASSIVE ICON FOR	::	SERPENT SUIT/ARMOUR PANIC
	// ABILITY GRANTED		::	PANIC VIPERS ON SIGHT
	if (default.bPI_ICONS_RULERPANIC)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('SerpentPanic');
		if (CurrentAbility != none )
		{
			// CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mindmerge2";

			// GIVE A PASSIVE ABILITY TO SHOW
			CurrentAbility.AdditionalAbilities.AddItem('SerpentPanicPassive');
		}
	}

	if (default.bPI_ICONS_RULERPANIC_MODENEMIES_SERPENTINE)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('SerpentPanic');
		if (CurrentAbility != none )
		{
			// CurrentAbility.AbilityTargetConditions.UnitTypeCondition.IncludeTypes.AddItem('Viper');
			// From ~ CharTemplate.CharacterGroupName
			/* Currently Vipers include;
				Vanilla Vipers
				ABA Boa						ABA Mamba					ABA Wyvern			ABA Prime
				CX Children of the King		CX Valentines Viper			CX Bio Vipers		
				Viper Elite					Armoured Viper				Armoured Psi Viper
			*/

			// FIX TO INCLUDE MODDES VIPER TYPES
			UnitConditionModded = new class'X2Condition_UnitType';
			UnitConditionModded.IncludeTypes.AddItem('AshFlameViper');
			CurrentAbility.AbilityTargetConditions.AddItem(UnitConditionModded);
		}
	}

	// NEW PASSIVE ICON FOR	::	RAGE SUIT/ARMOUR PANIC
	// ABILITY GRANTED		::	PANIC MUTONS/BESERKERS ON SIGHT
	if (default.bPI_ICONS_RULERPANIC)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('RagePanic');
		if (CurrentAbility != none )
		{
			// CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mindmerge2";

			// GIVE A PASSIVE ABILITY TO SHOW
			CurrentAbility.AdditionalAbilities.AddItem('RagePanicPassive');
		}
	}

	if (default.bPI_ICONS_RULERPANIC_MODENEMIES_TAURIANS)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('RagePanic');
		if (CurrentAbility != none )
		{
			// CurrentAbility.AbilityTargetConditions.UnitTypeCondition.IncludeTypes.AddItem('Muton');
			// From ~ CharTemplate.CharacterGroupName
			/* Currently Mutons include;
				Vanilla Muton
				ABA Pyro			ABA Infector		ABA Prime
			*/
		
			// FIX TO INCLUDE MODDED MUTON TYPES
			UnitConditionModded = new class'X2Condition_UnitType';
			UnitConditionModded.IncludeTypes.AddItem('MutonElite');
			UnitConditionModded.IncludeTypes.AddItem('MutonCenturianElite');
			UnitConditionModded.IncludeTypes.AddItem('MutonCommando');
			CurrentAbility.AbilityTargetConditions.AddItem(UnitConditionModded);

			// CurrentAbility.AbilityTargetConditions.UnitTypeCondition.IncludeTypes.AddItem('Berserker');
			// From ~ CharTemplate.CharacterGroupName
			/* Currently Bersekers include;
				Vanilla Berserker
				ABA Firestarter		ABA Firestarter Prime		ABA Prime
				CX BioZerker		CX BerserkerRevamp
			*/

			// FIX TO INCLUDE MODDED BERSERKER TYPES
			UnitConditionModded = new class'X2Condition_UnitType';
			UnitConditionModded.IncludeTypes.AddItem('BerserkerOmega');
			UnitConditionModded.IncludeTypes.AddItem('EUBerserker');
			CurrentAbility.AbilityTargetConditions.AddItem(UnitConditionModded);

		}
	}

	// NEW PASSIVE ICON FOR	::	ICARUS ARMOUR PANIC
	// ABILITY GRANTED		::	PANIC ARCHONS ON SIGHT
	if (default.bPI_ICONS_RULERPANIC)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('IcarusPanic');
		if (CurrentAbility != none )
		{
			// CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mindmerge2";

			// GIVE A PASSIVE ABILITY TO SHOW
			CurrentAbility.AdditionalAbilities.AddItem('IcarusPanicPassive');
		}
	}
		
	if (default.bPI_ICONS_RULERPANIC_MODENEMIES_ICARUS)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('IcarusPanic');
		if (CurrentAbility != none )
		{
			// CurrentAbility.AbilityTargetConditions.UnitTypeCondition.IncludeTypes.AddItem('Archon');
			// From ~ CharTemplate.CharacterGroupName
			/* Currently Archons include
				Vanilla Archon
				ABA Torcher/Prime	ABA Valkyrie		ABA Sentinel
				CX Archon Shamen	CX Archon Warrior
			*/

			// FIX TO INCLUDE MODDED ARCHON TYPES- no modded enemies using new types that are not already Archons
			//UnitConditionModded = new class'X2Condition_UnitType';
			//UnitConditionModded.IncludeTypes.AddItem('ModdedArchons');
			//CurrentAbility.AbilityTargetConditions.AddItem(UnitConditionModded);

		}
	}

	// change the Vault Passive to be Icon Coloured 
	CurrentAbility = AllAbilities.FindAbilityTemplate('VaultAbilityPassive');
	if (CurrentAbility != none )
	{
		CurrentAbility.AbilitySourceName = 'eAbilitySource_Item';
	}

	CurrentAbility = AllAbilities.FindAbilityTemplate('VaultAbility');
	if (CurrentAbility != none )
	{
		CurrentAbility.AbilitySourceName = 'eAbilitySource_Item';
	}

	// NEW PASSIVE ICON FOR	::	HIVE ARMOUR WALLCLIMB
	// ABILITY GRANTED		::	WALLCLIMB ABILITY (MOVED FROM _BONUS TO _PASSIVE, TO BETTER ALIGN WITH ICARUS VAULT ALSO BEING THERE)

	if (default.bPI_ICONS_RULER_HIVECLIMB_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('QueenArmorWallClimb');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_DLC2Images.UIPerk_icarusvault";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_PersistentTraversalChange(TempEffect) != none )
				{
					PTCEffect = X2Effect_PersistentTraversalChange(TempEffect);
					PTCEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('QueenArmorWallClimb',10), RustyLocDescCheck('QueenArmorWallClimb',10), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}
	//////////////////////////////////////////////////////////////////////////////////////////
	//	PASSIVE AMMO/UTILITY ITEMS ICONS OR WEAPON ATTACHMENTS
	//////////////////////////////////////////////////////////////////////////////////////////

	// YOU SERIOUSLY EXPECT THE PASSIVES TO NOT BE DISPLAYED IN THE WEAPON/AMMO FLYOVER?
	// ANY AMMO PASSIVES WOULD GO HERE, BUT I KNOW OF NONE THAT EXIST

	//////////////////////////////////////////////////////////////////////////////////////////
	//	PASSIVE ACCESSORY/UTILITY ITEMS ICONS
	//		For any accesory/utility item that grants a damage immunity
	//		Find the original ability, cx the icon, add/cx immunities
	//		Set the Immunity to show with a Passive Icon on tactical HUD
	//		Items in ((Double Brackets)) are MOD added items
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// NEW PASSIVE ICON FOR	::	MIND SHIELD 
	// IMMUNITIES GRANTED	::	STUN, DISORIENT, KNOCKOUT, DAZE, PANIC, MENTAL EFFECTS
	if (default.bPI_ICONS_MINDSHIELD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('MindShield');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_mindshield";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('MindShield'), RustyLocDescCheck('MindShield'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX ARCHONS ADVANCED MIND SHIELD ))
	// IMMUNITIES GRANTED	::	STUN, DISORIENT, KNOCKOUT, DAZE, PANIC, MENTAL EFFECTS	(AND 2HP REGEN, MAX 8HP)
	if (default.bPI_ICONS_MINDSHIELDADV_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('AdvancedMindShieldBonus');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_mindshield";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mentalfortress";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('AdvancedMindShieldBonus'), RustyLocDescCheck('AdvancedMindShieldBonus'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					// The following lines stops duplicate abilities, not required here only 1 mindshield per soldier
					//DamageImmunity.DuplicateResponse = eDupe_Refresh;
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	:: MEDIKITS
	// IMMUNITES GRANTED	:: POISON
	if (default.bPI_ICONS_MEDIKIT)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('MedikitBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					//DamageImmunity.ImmuneTypes.AddItem('Poison'); base game adds this 
					//DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('MedikitBonus'), RustyLocDescCheck('MedikitBonus'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	:: NANO MEDIKITS
	// IMMUNITES GRANTED	:: POISON, ((CHRYSSALID POISON))
	if (default.bPI_ICONS_MEDIKITNANO)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('NanoMedikitBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					//DamageImmunity.ImmuneTypes.AddItem('Poison'); base game adds this
					if (default.bAddBonusToNanoMedikit)
					{
						DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
					}
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('NanoMedikitBonus'), RustyLocDescCheck('NanoMedikitBonus'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					// The following lines stops duplicate abilities on medikit upgrades, required as new medikits ADD the old medikits abilities
					DamageImmunity.DuplicateResponse = eDupe_Refresh;
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	:: (( CX BIO DIVISION 2.0 BIO MEDIKITS ))
	// IMMUNITES GRANTED	:: POISON, ((CHRYSSALID POISON)), ELERIUM POISON
	if (default.bPI_ICONS_MEDIKITBIO_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('BioMedikitBonus');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					if (default.bAddBonusToBioMedikit)
					{
						DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
					}
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('BioMedikitBonus',8), RustyLocDescCheck('BioMedikitBonus',8), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					// The following lines stops duplicate abilities on medikit upgrades, required as new medikits ADD the old medikits abilities
					DamageImmunity.DuplicateResponse = eDupe_Refresh;
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR ::	(( CX BIO DIVISION 2.0 BIO DAMAGE CONTROL CHIP ))
	// IMMUNITIES GRANTED	::	ARMOUR PIP/GENERATION
	if (default.bPI_ICONS_BIOPCS_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('BioDamageControl');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_extrapadding";	//default image
			//also possible; Texture2D'UILIB_BioDivision.PCS_BB_PerkIcon' ? which doesn't get used ?
			//changed image to same image as (ABA/Elites) vest that does 'the same thing'
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_damage_control";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_BonusArmor(TempEffect) != none )
				{
					DamageControlEffect = X2Effect_BonusArmor(TempEffect);
					DamageControlEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('BioDamageControl'), RustyLocDescCheck('BioDamageControl'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					// The following lines stops duplicate abilities on Armour Regen, required as I added a passive to show this ability from the start of tactical
					DamageControlEffect.DuplicateResponse = eDupe_Refresh;
				}
			}

			//create a passive icon from the start of the mission, not just after taking damage?
			CurrentAbility.AdditionalAbilities.AddItem('BioDamageControlPassive');
		}
	}

	// NEW PASSIVE ICON FOR	::	(( CX SPECTRE REVAMP REFRACTION FIELD IMMUNITIES ))
	// IMMUNITIES GRANTED	::	PANIC (AND CONCEAL CHARGES)
	if (default.bPI_ICONS_REFRACTION_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('RefractionFieldImmunities');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Item';
			CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_refractionfield";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('RefractionFieldImmunities',9), RustyLocDescCheck('RefractionFieldImmunities',9), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( METAL OVER FLESH SHIELDS ))
	// IMMUNITIES GRANTED	::	UMM,ER... SHIELDS
	if (default.bPI_ICONS_MOFSHIELDS_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('SPARKShields');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_EnergyShield(TempEffect) != none )
				{
					ShieldedEffect = X2Effect_EnergyShield(TempEffect);
					ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('SPARKShields'), RustyLocDescCheck('SPARKShields'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					//The following lines stops duplicate abilities on shield upgrades, required as hardener adds a shield too
					ShieldedEffect.DuplicateResponse = eDupe_Refresh;
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( METAL OVER FLESH SHIELDS ))
	// IMMUNITIES GRANTED	::	UMM,ER... SHIELDS HARDENER, 
	if (default.bPI_ICONS_MOFSHIELDS_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('ShieldHardener');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_BonusArmor(TempEffect) != none )
				{
					ShieldHardEffect = X2Effect_BonusArmor(TempEffect);
					ShieldHardEffect.SetDisplayInfo(ePerkBuff_Bonus, RustyLocNameCheck('ShieldHardener'), RustyLocDescCheck('ShieldHardener'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}

				if ( X2Effect_EnergyShield(TempEffect) != none )
				{
					ShieldedEffect = X2Effect_EnergyShield(TempEffect);
					ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('ShieldHardener'), RustyLocDescCheck('ShieldHardener'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					//The following lines stops duplicate abilities on shield upgrades, required as hardener adds a shield too
					ShieldedEffect.DuplicateResponse = eDupe_Refresh;
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( METAL OVER FLESH SHIELDS HARDENER ))
	// IMMUNITIES GRANTED	::	UMM,ER... SHIELDS HARDENED
	if (default.bPI_ICONS_MOFSHIELDS_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('HardenerShield');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_EnergyShield(TempEffect) != none )
				{
					ShieldedEffect = X2Effect_EnergyShield(TempEffect);
					ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('HardenerShield'), RustyLocDescCheck('HardenerShield'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					//The following lines stops duplicate abilities on shield upgrades, required as hardener adds a shield too
					ShieldedEffect.DuplicateResponse = eDupe_Refresh;
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( GTS TRAINABLE SPARKS REGEN ))
	// IMMUNITIES GRANTED	::	UMM,ER... REGEN
	if (default.bPI_ICONS_GTSSPARKREGEN_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('SparkRegeneration');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest"; //.. It just got confusing with the added vest icons
			CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_chosenrevive";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_Regeneration(TempEffect) != none )
				{
					RegenerationEffect = X2Effect_Regeneration(TempEffect);
					RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('SparkRegeneration'), RustyLocDescCheck('SparkRegeneration'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}
	}

	// NEW PASSIVE ICON FOR	::	(( ARMOUR AND VEST CONFIG ABILITIES ))
	// IMMUNITIES GRANTED	::	UMM,ER... REGEN AND IMMUNITIES
	if (default.bPI_ICONS_ARMORANDVESTCONFIG)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_RegenM1');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest"; //.. It just got confusing with the added vest icons
			CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_chosenrevive";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_Regeneration(TempEffect) != none )
				{
					RegenerationEffect = X2Effect_Regeneration(TempEffect);
					RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_RegenM1',13), RustyLocDescCheck('Chrm_RegenM1',13), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_RegenM2');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest"; //.. It just got confusing with the added vest icons
			CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_chosenrevive";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_Regeneration(TempEffect) != none )
				{
					RegenerationEffect = X2Effect_Regeneration(TempEffect);
					RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_RegenM2',14), RustyLocDescCheck('Chrm_RegenM2',14), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_RegenM3');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest"; //.. It just got confusing with the added vest icons
			CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_chosenrevive";
			foreach CurrentAbility.AbilityTargetEffects ( TempEffect )
			{
				if ( X2Effect_Regeneration(TempEffect) != none )
				{
					RegenerationEffect = X2Effect_Regeneration(TempEffect);
					RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_RegenM3',15), RustyLocDescCheck('Chrm_RegenM3',15), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		//Chrm_AcidImmunity, Chrm_FireImmunity, Chrm_PoisonImmunity, Chrm_FrostImmunity, Chrm_MentalImmunity.
		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_AcidImmunity');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_AcidImmunity',16), RustyLocDescCheck('Chrm_AcidImmunity',16), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_FireImmunity');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_FireImmunity',17), RustyLocDescCheck('Chrm_FireImmunity',17), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_PoisonImmunity');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_PoisonImmunity',18), RustyLocDescCheck('Chrm_PoisonImmunity',18), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_FrostImmunity');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_FrostImmunity',19), RustyLocDescCheck('Chrm_FrostImmunity',19), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('Chrm_MentalImmunity');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_DamageImmunity(TempEffect) != none )
				{
					DamageImmunity = X2Effect_DamageImmunity(TempEffect);
					DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('Chrm_MentalImmunity',20), RustyLocDescCheck('Chrm_MentalImmunity',20), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
				}
			}
		}

	}

	// NEW PASSIVE ICON FOR	::	(( WALKER SERVOS ))
	// IMMUNITES GRANTED	::	JUMP
	if (default.bPI_ICONS_WALKERSERVOS_MOD)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('WalkerServosJump');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_DLC2Images.UIPerk_icarusvault";
			CurrentAbility.AdditionalAbilities.AddItem('VaultAbilityPassive');
		}
	}

	// NO PASSIVE ICON FOR	::	FUSE ITEM?		GRANTED STUFF	:: N/A						AB_TEMPLATE_NAME	::	ExplosiveDeviceDetonate
	// NO PASSIVE ICON FOR	::	BATTLE SCANNER	GRANTED STUFF	:: N/A						AB_TEMPLATE_NAME	::	BattleScanner
	// NO PASSIVE ICON FOR	::	AMP BOOSTER		GRANTED STUFF	:: PSI OFFENSE				AB_TEMPLATE_NAME	::	AmpBoosterAbility
	// NO PASSIVE ICON FOR	::	NEUROWHIP		GRANTED STUFF	:: PSI OFFENSE				AB_TEMPLATE_NAME	::	Neurowhip
	// NO PASSIVE ICON FOR	::	NEURODAMP		GRANTED STUFF	:: WILL DAMP				AB_TEMPLATE_NAME	::	NeuralDampingAbility
	// NO PASSIVE ICON FOR	::	COMBATSTIMS		GRANTED STUFF	:: MOBILITY INCREASE		AB_TEMPLATE_NAME	::	CombatStims

	// NO PASSIVE ICON FOR	::	MIMIC BEACON	GRANTED STUFF	:: N/A
	//								AB_TEMPLATE_NAME	::	MimicBeaconThrow, MimicBeacon_BuildVisualization

	// NO PASSIVE ICON FOR	::	REFRACT FIELD	GRANTED STUFF	:: N/A						AB_TEMPLATE_NAME	::	RefractionFieldAbility
	//		TEMPLATE ACTUALLY IN RANGER TEMPLATE SET NOT ITEM GRANTED ABILITY SET, CONCEAL
	//		LIKELY OVERWRITTEN BY CX SPECTRE REVAMP ANYWAY, SEE ABOVE

	//////////////////////////////////////////////////////////////////////////////////////////
	// SKULLMINE ABILITY ICON IS NOW A SKULLJACK
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// NO PASSIVE ICON FOR	::	SKULLJACK		GRANTED STUFF	:: MELEE ATT, HACK BONUS	
	//		AB_TEMPLATE_NAME	::	SKULLMINEAbility, FinalizeSKULLMINE, CancelSKULLMINE
	//		AB_TEMPLATE_NAME	::	SKULLJACKAbility, FinaliseSKULLJACK, CancelSKULLJACK
	//		AB_TEMPLATE_NAME	::	SKULLJACK_BuildInterruptGameState, SKULLJACK_BuildGameState, SKULLJACK_BuildVisualization
	
	if (default.bPI_ICONS_SKULLMINE)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('SKULLMINEAbility');
		if (CurrentAbility != none )
		{
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_skulljack";
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// LOW VISIBILITY (BLINDED) ICON FIX
	// COMMENTED OUT ADVENT AVENGERS ICON, FOUND ONE BETTER SUITED
	//////////////////////////////////////////////////////////////////////////////////////////

	if (default.bPI_ICONS_LOWVIS)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('LowVisibility');
		if (CurrentAbility != none )
		{
			//CurrentAbility.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_mountainmist";
			CurrentAbility.IconImage = "img:///UILibrary_PerkIcons.UIPerk_observer";
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// SUSTAINING SPHERE ITEM IS A PASSIVE ITEM BONUS, NOT A PSIONIC BONUS (COLOURS)
	// GETS OVERRIDDEN BY CX PRIEST REVAMP MAYBE BUT NOT IN MY GAME :)
	//////////////////////////////////////////////////////////////////////////////////////////

	if (default.bPI_ICONS_SUSTAINSPHERE)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('SustainingSphereAbility');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Item';
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_SustainingSphere(TempEffect) != none )
				{
					SustainEffect = X2Effect_SustainingSphere(TempEffect);
       				SustainEffect.SetDisplayInfo(ePerkBuff_Passive, RustyLocNameCheck('SustainingSphereAbility'), RustyLocDescCheck('SustainingSphereAbility'), CurrentAbility.IconImage,true,,CurrentAbility.AbilitySourceName);
					// The following lines stops duplicate abilities (if there are any) from showing this multiple times
					SustainEffect.DuplicateResponse = eDupe_Refresh;
				}
			}
		}

		//just for good measure, change this to be icon coloured too
		CurrentAbility = AllAbilities.FindAbilityTemplate('SustainingSphereTriggeredAbility');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Item';
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// MELEE RESISTANCE IS A PERK NOT AN ITEM (COLOURS)
	//////////////////////////////////////////////////////////////////////////////////////////

	if (default.bPI_ICONS_MELEERES)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('MeleeResistance');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Perk';
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// ADVENT PRIESTS UNDER MIND CONTROL HOLY WARRIOR PSIONICS FIX (COLOURS)
	//	((NO CONCEALMENT BREAK))
	//	GETS OVERRIDDEN BY CX PRIEST REVAMP ??
	//////////////////////////////////////////////////////////////////////////////////////////

	if (default.bPI_ICONS_HOLYWARRIOR)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('HolyWarriorM1');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Psionic';
			if (default.bAddBonusToHolyWarrior)
			{
				CurrentAbility.ConcealmentRule = eConceal_Always;
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('HolyWarriorM2');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Psionic';
			if (default.bAddBonusToHolyWarrior)
			{
				CurrentAbility.ConcealmentRule = eConceal_Always;
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('HolyWarriorM3');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Psionic';
			if (default.bAddBonusToHolyWarrior)
			{
				CurrentAbility.ConcealmentRule = eConceal_Always;
			}
		}

		CurrentAbility = AllAbilities.FindAbilityTemplate('HolyWarriorMP');
		if (CurrentAbility != none )
		{
			CurrentAbility.AbilitySourceName = 'eAbilitySource_Psionic';
			if (default.bAddBonusToHolyWarrior)
			{
				CurrentAbility.ConcealmentRule = eConceal_Always;
			}
		}
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	// HELLWEAVE VEST DEALS FIRE DAMAGE (4-5 DAMAGE, EXCEPT 1 LESS IF TARGET HAS ARMOR)
	//////////////////////////////////////////////////////////////////////////////////////////

	// NO CHANGE TO ScorchCircuits DEFAULT ABILITY ACTIVATION (RECIEVED MELEE DAMAGE)
	// NO CHANGE TO ScorchCircuits_VisualizationMerge

	if (default.bPI_DAMAGECHANGE_HELLWEAVE)
	{
		CurrentAbility = AllAbilities.FindAbilityTemplate('ScorchCircuitsDamage');
		if (CurrentAbility != none )
		{
			foreach CurrentAbility.AbilityTargetEffects( TempEffect )
			{
				if ( X2Effect_ApplyWeaponDamage(TempEffect) != none )
				{
					WeaponDamageEffect = X2Effect_ApplyWeaponDamage(TempEffect);
						WeaponDamageEffect.EffectDamageValue.Damage  = default.iPI_HELLWEAVE_BASE;
						WeaponDamageEffect.EffectDamageValue.PlusOne = default.iPI_HELLWEAVE_PLUS;
						WeaponDamageEffect.EffectDamageValue.Spread  = default.iPI_HELLWEAVE_SPREAD;
						WeaponDamageEffect.EffectDamageValue.Pierce  = default.iPI_HELLWEAVE_PIERCE;
					WeaponDamageEffect.DamageTypes.RemoveItem('Electrical');
					WeaponDamageEffect.DamageTypes.AddItem(default.nPI_HELLWEAVE_TYPE);
				}
			}
		}
	}

} //END static event OnPostTemplatesCreated()

//*******************************************************************************************
//	HELPER FUNCTIONS
//*******************************************************************************************

//*******************************************************************************************
// CHECK SOURCE MOD FOR LOCALISATIONS AND USE THEM OR BACKUPS
//*******************************************************************************************
static function string RustyLocNameCheck(name Template, int i = 0)
{
	local X2AbilityTemplateManager		AllAbilities;			//holder for all abilities
	local X2AbilityTemplate				CurrentAbility;			//current thing to focus on
	local string						sName;					//string to pass out

	//Grab the distinct template managers(lists) to search through
	AllAbilities     = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    CurrentAbility = AllAbilities.FindAbilityTemplate(Template);

    if (CurrentAbility.LocFriendlyName == "")
    {
        sName = default.RustyLocName[i];
    }
    else
    {
        sName = CurrentAbility.LocFriendlyName;
    }

    return sName;
}

static function string RustyLocDescCheck(name Template, int i = 0)
{
	local X2AbilityTemplateManager		AllAbilities;			//holder for all abilities
	local X2AbilityTemplate				CurrentAbility;			//current thing to focus on
	local string						sDesc;					//string to pass out

	//Grab the distinct template managers(lists) to search through
	AllAbilities     = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    CurrentAbility = AllAbilities.FindAbilityTemplate(Template);

    if (CurrentAbility.GetMyLongDescription() == "")
    {
        sDesc = default.RustyLocDesc[i];
    }
    else
    {
        sDesc = CurrentAbility.GetMyLongDescription();
    }

    return sDesc;
}

//*******************************************************************************************
// HELPFUL FUNCTION PARAMETER REMINDERS
//
// BuildPersistantEffect (int NumTurns, bInfinite, bRemoveWhenTargetDies, bIgnorePlayerCheckOnTick, opGameRuleStateChange = TacGameStart)
// SetDisplayInfo(EPerkBuffCategory, strName, strDesc, strIconLabel, bDisplayInUI=true, strStatusIcon = "", opAbilitySource = eAbilitySource_Standard)
// bDisplayInUI defaults to false in defaultproperties of X2AbilityTemplate and/or X2Effect_PersistantEffect
// 
// CurrentAbility.AdditionalAbilities.AddItem('TemplateName');
//		
// DuplicateResponse = eDupe_Allow (both can exist), eDupe_Refresh (game decides strongest updates), eDupe_Ignore (game keeps original/first)
// 
// eAbility/ePerkBuff colours				ePerkBuffCategories
// eAbilitySource_Passive	= Blue			ePerkBuff_Passive	Lower Left Corner
// eAbilitySource_Item		= Blue		
// eAbilitySource_Perk		= Yellow
// eAbilitySource_Standard	= Yellow		
// eAbilitySource_Psionic	= Purple
// eAbilitySource_Commander = Green			ePerkBuff_Bonus		^ green in mini-pop out
// eAbilitySource_Debuff	= Red			ePerkBuff_Penalty	v red in mini-pop out
// 
// commander/green is primarily used for bondmate abilities
// debuff/red is primarily used for negative traits
//
//*******************************************************************************************
// List of Damage Types to be Immune from, taken from X2Item_DefaultDamageType, [X2Item_DLC_Day60DamageTypes]
// ((And Bio Division 2.0  X2Item_EleriumPoisoningDamageType ))
//
//	Poison		ParthenogenicPoison					((EleriumPoisoning))
//	Explosion	NoFireExplosion		BlazingPinions	KnockbackDamage
//	Acid		Electrical			Fire			Frost			Psi
//	Melee		ViperCrush			Falling			Bleeding		<Blind>		
//	Stun		Disorient			Panic			Unconscious		[Mental]
//
// The mental condition is immunity to Chosen Daze Attacks - not Mind/Mental
// <Blind> This is an effect and needs a damage type added to be able to be immune to it
// In other words you can't be 'naturally' immune to Blindness on it's own... ?!?
//
// Additional Damage Types found in XComGameData_WeaponData (Normal Shots)
//	Projectile_Conventional		Projectile_MagAdvent
//	Projectile_MagXCom			Projectile_BeamAlien
//	Projectile_BeamXCom			Projectile_BeamAvatar
