module CardSet exposing (..)
import List.Extra

type Set
    = Set_Core
    | Set_KingsOfTheSea
    | Set_PrincesOfTheSun
    | Set_LordsOfWinter
    | Set_KingsOfTheStorm
    | Set_QueenOfDragons
    | Set_LionsOfTheRock

    | Set_TheWarOfTheFiveKings
    | Set_AncientEnemies
    | Set_SacredBonds
    | Set_EpicBattles
    | Set_BattleOfRubyFord
    | Set_CallingTheBanners

    | Set_ASongOfSummer
    | Set_TheWindsOfWinter
    | Set_AChangeOfSeasons
    | Set_TheRavensSong
    | Set_RefugeesOfWar
    | Set_ScatteredArmies

    | Set_CityOfSecrets
    | Set_ATimeOfTrials
    | Set_TheTowerOfTheHand
    | Set_TalesFromTheRedKeep
    | Set_SecretsAndSpies
    | Set_TheBattleOfBlackwaterBay

    | Set_WolvesOfTheNorth
    | Set_BeyondTheWall
    | Set_ASwordInTheDarkness
    | Set_TheWildlingHorde
    | Set_AKingInTheNorth
    | Set_ReturnOfTheOthers
    
    | Set_IllyriosGift
    | Set_RitualsOfRhllor
    | Set_MountainsOfTheMoon
    | Set_ASongOfSilence
    | Set_OfSnakesAndSand
    | Set_DreadfortBetrayal

    | Set_GatesOfTheCitadel
    | Set_ForgingTheChain
    | Set_CalledByTheConclave
    | Set_TheIlseOfRavens
    | Set_MaskOfTheArchmaester
    | Set_HereToServe

    | Set_TourneyForTheHand
    | Set_TheGrandMelee
    | Set_OnDangerousGrounds
    | Set_WhereLoyaltyLies
    | Set_TrialByCombat
    | Set_APoisonedSpear

    | Set_ValarMorghulis
    | Set_ValarDohaeris
    | Set_ChasingDragons
    | Set_AHarshMistress
    | Set_TheHouseOfBlackAndWhite
    | Set_ARollOfTheDice

    | Set_ReachOfTheKraken
    | Set_TheGrandFleet
    | Set_ThePiratesOfLys
    | Set_ATurnOfTheTide
    | Set_TheCaptainsCommand
    | Set_AJourneysEnd
    
    | Set_TheBannersGather
    | Set_FireAndIce
    | Set_TheKingsguard
    | Set_TheHornThatWakes
    | Set_ForgottenFellowship
    | Set_AHiddenAgenda

    | Set_SpoilsOfWar
    | Set_TheChampionsPurse
    | Set_FireMadeFlesh
    | Set_AncestralHome
    | Set_ThePrizeOfTheNorth
    | Set_ADireMessage

    | Set_SecretsAndSchemes
    | Set_ADeadlyGame
    | Set_TheValemen
    | Set_ATimeForWolves
    | Set_HouseOfTalons
    | Set_TheBlueIsCalling

type alias SetData =
    { set : Set
    , index : Int
    , code_name : String
    , full_name : String
    , cycle : Maybe Cycle
    }

set_data :  List SetData
set_data =
    [ { set= Set_Core, index = 0, code_name = "core", full_name = "Core", cycle = Nothing }
    , { set= Set_KingsOfTheSea, index = 1, code_name = "kotse", full_name = "Kings of the Sea", cycle = Nothing }
    , { set= Set_PrincesOfTheSun, index = 2, code_name = "pots", full_name = "Princes of the Sun", cycle = Nothing }
    , { set= Set_LordsOfWinter, index = 3, code_name = "low", full_name = "Lords of Winter", cycle = Nothing }
    , { set= Set_KingsOfTheStorm, index = 4, code_name = "kotst", full_name = "Kings of the Storm", cycle = Nothing }
    , { set= Set_QueenOfDragons, index = 5, code_name = "qod", full_name = "Queen of Dragons", cycle = Nothing }
    , { set= Set_LionsOfTheRock, index = 6, code_name = "lotr", full_name = "Lions of the Rock", cycle = Nothing }

    , { set = Set_TheWarOfTheFiveKings, index = 7, code_name = "twofk",  full_name = "The War of Five Kings", cycle = Just Cycle_AClashOfArms }
    , { set = Set_AncientEnemies, index = 8, code_name = "ae",  full_name = "Ancient Enemies", cycle = Just Cycle_AClashOfArms }
    , { set = Set_SacredBonds, index = 9, code_name = "sb",  full_name = "Sacred Bonds", cycle = Just Cycle_AClashOfArms }
    , { set = Set_EpicBattles, index = 10, code_name = "eb", full_name = "Epic Battles", cycle = Just Cycle_AClashOfArms }
    , { set = Set_BattleOfRubyFord, index = 11, code_name = "borf", full_name = "Battle of Ruby Ford", cycle = Just Cycle_AClashOfArms }
    , { set = Set_CallingTheBanners, index = 12, code_name = "ctb", full_name = "Calling the Banners", cycle = Just Cycle_AClashOfArms }

    , { set = Set_ASongOfSummer, index = 13, code_name = "asosu", full_name = "A Song of Summer", cycle = Just Cycle_ATimeOfRavens }
    , { set = Set_TheWindsOfWinter, index = 14, code_name = "twow", full_name = "The Winds of Winter", cycle = Just Cycle_ATimeOfRavens }
    , { set = Set_AChangeOfSeasons, index = 15, code_name = "acos", full_name = "A Change of Seasons", cycle = Just Cycle_ATimeOfRavens }
    , { set = Set_TheRavensSong, index = 16, code_name = "trs", full_name = "The Raven's Song", cycle = Just Cycle_ATimeOfRavens }
    , { set = Set_RefugeesOfWar, index = 17, code_name = "row", full_name = "Refugees of War", cycle = Just Cycle_ATimeOfRavens }
    , { set = Set_ScatteredArmies, index = 18, code_name = "sa", full_name = "Scattered Armies", cycle = Just Cycle_ATimeOfRavens }

    , { set = Set_CityOfSecrets, index = 19, code_name = "cos", full_name = "City of Secrets", cycle = Just Cycle_KingsLanding }
    , { set = Set_ATimeOfTrials, index = 20, code_name = "atot", full_name = "A Time of Trials", cycle = Just Cycle_KingsLanding }
    , { set = Set_TheTowerOfTheHand, index = 21, code_name = "ttoth", full_name = "The Tower of the Hand", cycle = Just Cycle_KingsLanding }
    , { set = Set_TalesFromTheRedKeep, index = 22, code_name = "tftrk", full_name = "Tales from the Red Keep", cycle = Just Cycle_KingsLanding }
    , { set = Set_SecretsAndSpies, index = 23, code_name = "sasp", full_name = "Secrets and Spies", cycle = Just Cycle_KingsLanding }
    , { set = Set_TheBattleOfBlackwaterBay, index = 24, code_name = "tbobb", full_name = "The Battle of Blackwater Bay", cycle = Just Cycle_KingsLanding }

    , { set = Set_WolvesOfTheNorth, index = 25, code_name = "wotn", full_name = "Wolves of the North", cycle = Just Cycle_DefendersOfTheNorth }
    , { set = Set_BeyondTheWall, index = 26, code_name = "btw", full_name = "Beyond the Wall", cycle = Just Cycle_DefendersOfTheNorth }
    , { set = Set_ASwordInTheDarkness, index = 27, code_name = "asitd", full_name = "A Sword in the Darkness", cycle = Just Cycle_DefendersOfTheNorth }
    , { set = Set_TheWildlingHorde, index = 28, code_name = "twh", full_name = "The Wildling Horde", cycle = Just Cycle_DefendersOfTheNorth }
    , { set = Set_AKingInTheNorth, index = 29, code_name = "akitn", full_name = "A King in the North", cycle = Just Cycle_DefendersOfTheNorth }
    , { set = Set_ReturnOfTheOthers, index = 30, code_name = "roto", full_name = "Return of the Others", cycle = Just Cycle_DefendersOfTheNorth }

    , { set = Set_IllyriosGift, index = 31, code_name = "ig", full_name = "Illyrio's Gift", cycle = Just Cycle_BrotherhoodWithoutBanners }
    , { set = Set_RitualsOfRhllor, index = 32, code_name = "ror", full_name = "Rituals of R'hllor", cycle = Just Cycle_BrotherhoodWithoutBanners }
    , { set = Set_MountainsOfTheMoon, index = 33, code_name = "motm", full_name = "Mountains of the Moon", cycle = Just Cycle_BrotherhoodWithoutBanners }
    , { set = Set_ASongOfSilence, index = 34, code_name = "asosi", full_name = "A Song of Silence", cycle = Just Cycle_BrotherhoodWithoutBanners }
    , { set = Set_OfSnakesAndSand, index = 35, code_name = "osas", full_name = "Of Snakes and Sand", cycle = Just Cycle_BrotherhoodWithoutBanners }
    , { set = Set_DreadfortBetrayal, index = 36, code_name = "db", full_name = "Dreadfort Betrayal", cycle = Just Cycle_BrotherhoodWithoutBanners }

    , { set = Set_GatesOfTheCitadel, index = 37, code_name = "gotc", full_name = "Gates of the Citadel", cycle = Just Cycle_SecretsOfOldtown }
    , { set = Set_ForgingTheChain, index = 38, code_name = "ftc", full_name = "Forging the Chain", cycle = Just Cycle_SecretsOfOldtown }
    , { set = Set_CalledByTheConclave, index = 39, code_name = "cbtc", full_name = "Called by the Conclave", cycle = Just Cycle_SecretsOfOldtown }
    , { set = Set_TheIlseOfRavens, index = 40, code_name = "tior", full_name = "The Isle of Ravens", cycle = Just Cycle_SecretsOfOldtown }
    , { set = Set_MaskOfTheArchmaester, index = 41, code_name = "mota", full_name = "Mask of the Archmaester", cycle = Just Cycle_SecretsOfOldtown }
    , { set = Set_HereToServe, index = 42, code_name = "hts", full_name = "Here to Serve", cycle = Just Cycle_SecretsOfOldtown }

    , { set = Set_TourneyForTheHand, index = 43, code_name = "ttfth", full_name = "The Tourney for the Hand", cycle = Just Cycle_ATaleOfChampions }
    , { set = Set_TheGrandMelee, index = 44, code_name = "tgm", full_name = "The Grand Melee", cycle = Just Cycle_ATaleOfChampions }
    , { set = Set_OnDangerousGrounds, index = 45, code_name = "odg", full_name = "On Dangerous Grounds", cycle = Just Cycle_ATaleOfChampions }
    , { set = Set_WhereLoyaltyLies, index = 46, code_name = "wll", full_name = "Where Loyalty Lies", cycle = Just Cycle_ATaleOfChampions }
    , { set = Set_TrialByCombat, index = 47, code_name = "tbc", full_name = "Trial By Combat", cycle = Just Cycle_ATaleOfChampions }
    , { set = Set_APoisonedSpear, index = 48, code_name = "aps", full_name = "A Poisoned Spear", cycle = Just Cycle_ATaleOfChampions }

    , { set = Set_ValarMorghulis, index = 49, code_name = "vm", full_name = "Valar Morghulis", cycle = Just Cycle_BeyondTheNarrowSea }
    , { set = Set_ValarDohaeris, index = 50, code_name = "vd", full_name = "Valar Dohaeris", cycle = Just Cycle_BeyondTheNarrowSea }
    , { set = Set_ChasingDragons, index = 51, code_name = "cd", full_name = "Chasing Dragons", cycle = Just Cycle_BeyondTheNarrowSea }
    , { set = Set_AHarshMistress, index = 52, code_name = "ahm", full_name = "A Harsh Mistress", cycle = Just Cycle_BeyondTheNarrowSea }
    , { set = Set_TheHouseOfBlackAndWhite, index = 53, code_name = "thobaw", full_name = "The House of Black and White", cycle = Just Cycle_BeyondTheNarrowSea }
    , { set = Set_ARollOfTheDice, index = 54, code_name = "arotd", full_name = "A Roll of the Dice", cycle = Just Cycle_BeyondTheNarrowSea }

    , { set = Set_ReachOfTheKraken, index = 55, code_name = "rotk", full_name = "Reach of the Kraken", cycle = Just Cycle_ASongOfTheSea }
    , { set = Set_TheGrandFleet, index = 56, code_name = "tgf", full_name = "The Grand Fleet", cycle = Just Cycle_ASongOfTheSea }
    , { set = Set_ThePiratesOfLys, index = 57, code_name = "tpol", full_name = "The Pirates of Lys", cycle = Just Cycle_ASongOfTheSea }
    , { set = Set_ATurnOfTheTide, index = 58, code_name = "atott", full_name = "A Turn of the Tide", cycle = Just Cycle_ASongOfTheSea }
    , { set = Set_TheCaptainsCommand, index = 59, code_name = "tcc", full_name = "The Captain's Command", cycle = Just Cycle_ASongOfTheSea }
    , { set = Set_AJourneysEnd, index = 60, code_name = "aje", full_name = "A Journey's End", cycle = Just Cycle_ASongOfTheSea }

    , { set = Set_TheBannersGather, index = 61, code_name = "tbg", full_name = "The Banners Gather", cycle = Just Cycle_Kingsroad }
    , { set = Set_FireAndIce, index = 62, code_name = "fai", full_name = "Fire and Ice", cycle = Just Cycle_Kingsroad }
    , { set = Set_TheKingsguard, index = 63, code_name = "tk", full_name = "The Kingsguard", cycle = Just Cycle_Kingsroad }
    , { set = Set_TheHornThatWakes, index = 64, code_name = "thtw", full_name = "The Horn that Wakes", cycle = Just Cycle_Kingsroad }
    , { set = Set_ForgottenFellowship, index = 65, code_name = "ff", full_name = "Forgotten Fellowship", cycle = Just Cycle_Kingsroad }
    , { set = Set_AHiddenAgenda, index = 66, code_name = "aha", full_name = "A Hidden Agenda", cycle = Just Cycle_Kingsroad }

    , { set = Set_SpoilsOfWar, index = 67, code_name = "sow", full_name = "Spoils of War", cycle = Just Cycle_ConquestAndDefiance }
    , { set = Set_TheChampionsPurse, index = 68, code_name = "tcp", full_name = "The Champion's Purse", cycle = Just Cycle_ConquestAndDefiance }
    , { set = Set_FireMadeFlesh, index = 69, code_name = "fmf", full_name = "Fire Made Flesh", cycle = Just Cycle_ConquestAndDefiance }
    , { set = Set_AncestralHome, index = 70, code_name = "ah", full_name = "Ancestral Home", cycle = Just Cycle_ConquestAndDefiance }
    , { set = Set_ThePrizeOfTheNorth, index = 71, code_name = "tpotn", full_name = "The Prize of the North", cycle = Just Cycle_ConquestAndDefiance }
    , { set = Set_ADireMessage, index = 72, code_name = "adm", full_name = "A Dire Message", cycle = Just Cycle_ConquestAndDefiance }

    , { set = Set_SecretsAndSchemes, index = 73, code_name = "sasc", full_name = "Secrets and Schemes", cycle = Just Cycle_Wardens }
    , { set = Set_ADeadlyGame, index = 74, code_name = "adg", full_name = "A Deadly Game", cycle = Just Cycle_Wardens }
    , { set = Set_TheValemen, index = 75, code_name = "tv", full_name = "The Valemen", cycle = Just Cycle_Wardens }
    , { set = Set_ATimeForWolves, index = 76, code_name = "atow", full_name = "A Time for Wolves", cycle = Just Cycle_Wardens }
    , { set = Set_HouseOfTalons, index = 77, code_name = "hot", full_name = "House of Talons", cycle = Just Cycle_Wardens }
    , { set = Set_TheBlueIsCalling, index = 78, code_name = "tbic", full_name = "The Blue is Calling", cycle = Just Cycle_Wardens }
    ]

data_of_set : Set -> SetData
data_of_set set = set_data
    |> List.Extra.find (\d -> d.set == set) 
    |> Maybe.withDefault { set= Set_Core, index = 0, code_name = "", full_name = "", cycle = Nothing } -- Never happens

set_sort_order : Set -> Int
set_sort_order set = (data_of_set set).index

type Cycle
    = Cycle_AClashOfArms
    | Cycle_ATimeOfRavens
    | Cycle_KingsLanding
    | Cycle_DefendersOfTheNorth
    | Cycle_BrotherhoodWithoutBanners
    | Cycle_SecretsOfOldtown
    | Cycle_ATaleOfChampions
    | Cycle_BeyondTheNarrowSea
    | Cycle_ASongOfTheSea
    | Cycle_Kingsroad
    | Cycle_ConquestAndDefiance
    | Cycle_Wardens

type alias CycleData =
    { cycle : Cycle
    , code_name : String
    , full_name : String
    }

cycle_data : List CycleData
cycle_data =
    [ { cycle = Cycle_AClashOfArms, code_name = "acoa", full_name = "A Clash of Arms" }
    , { cycle = Cycle_ATimeOfRavens, code_name = "ator", full_name = "A Time of Ravens" }
    , { cycle = Cycle_KingsLanding, code_name = "kl", full_name = "King's Landing" }
    , { cycle = Cycle_DefendersOfTheNorth, code_name = "dotn", full_name = "Defenders of the North" }
    , { cycle = Cycle_BrotherhoodWithoutBanners, code_name = "bwb", full_name = "Brotherhood without Banners" }
    , { cycle = Cycle_SecretsOfOldtown, code_name = "soo", full_name = "Secrets of Oldtown" }
    , { cycle = Cycle_ATaleOfChampions, code_name = "atoc", full_name = "A Tale of Champions" }
    , { cycle = Cycle_BeyondTheNarrowSea, code_name = "btns", full_name = "Beyond the Narrow Sea" }
    , { cycle = Cycle_ASongOfTheSea, code_name = "asots", full_name = "A Song of the Sea" }
    , { cycle = Cycle_Kingsroad, code_name = "kr", full_name = "Kingsroad" }
    , { cycle = Cycle_ConquestAndDefiance, code_name = "cad", full_name = "Conquest and Defiance" }
    , { cycle = Cycle_Wardens, code_name = "w", full_name = "Wardens" }
    ]

data_of_cycle : Cycle -> CycleData
data_of_cycle cycle = cycle_data
    |> List.Extra.find (\d -> d.cycle == cycle) 
    |> Maybe.withDefault { cycle = Cycle_AClashOfArms, code_name = "", full_name = "" } -- Never happens

sets_in_cycle : Cycle -> List Set
sets_in_cycle cycle = case cycle of
    Cycle_AClashOfArms -> [ Set_TheWarOfTheFiveKings, Set_AncientEnemies, Set_SacredBonds, Set_EpicBattles, Set_BattleOfRubyFord, Set_CallingTheBanners ]
    Cycle_ATimeOfRavens -> [ Set_ASongOfSummer, Set_TheWindsOfWinter, Set_AChangeOfSeasons, Set_TheRavensSong, Set_RefugeesOfWar, Set_ScatteredArmies ]
    Cycle_KingsLanding -> [ Set_CityOfSecrets, Set_ATimeOfTrials, Set_TheTowerOfTheHand, Set_TalesFromTheRedKeep, Set_SecretsAndSpies, Set_TheBattleOfBlackwaterBay ]
    Cycle_DefendersOfTheNorth -> [ Set_WolvesOfTheNorth, Set_BeyondTheWall, Set_ASwordInTheDarkness, Set_TheWildlingHorde, Set_AKingInTheNorth, Set_ReturnOfTheOthers ]
    Cycle_BrotherhoodWithoutBanners -> [ Set_IllyriosGift, Set_RitualsOfRhllor, Set_MountainsOfTheMoon, Set_ASongOfSilence, Set_OfSnakesAndSand, Set_DreadfortBetrayal ]
    Cycle_SecretsOfOldtown -> [ Set_GatesOfTheCitadel, Set_ForgingTheChain, Set_CalledByTheConclave, Set_TheIlseOfRavens, Set_MaskOfTheArchmaester, Set_HereToServe ]
    Cycle_ATaleOfChampions -> [ Set_TourneyForTheHand, Set_TheGrandMelee, Set_OnDangerousGrounds, Set_WhereLoyaltyLies, Set_TrialByCombat, Set_APoisonedSpear ]
    Cycle_BeyondTheNarrowSea -> [ Set_ValarMorghulis, Set_ValarDohaeris, Set_ChasingDragons, Set_AHarshMistress, Set_TheHouseOfBlackAndWhite, Set_ARollOfTheDice ]
    Cycle_ASongOfTheSea -> [ Set_ReachOfTheKraken, Set_TheGrandFleet, Set_ThePiratesOfLys, Set_ATurnOfTheTide, Set_TheCaptainsCommand, Set_AJourneysEnd ]
    Cycle_Kingsroad -> [ Set_TheBannersGather, Set_FireAndIce, Set_TheKingsguard, Set_TheHornThatWakes, Set_ForgottenFellowship, Set_AHiddenAgenda ]
    Cycle_ConquestAndDefiance -> [ Set_SpoilsOfWar, Set_TheChampionsPurse, Set_FireMadeFlesh, Set_AncestralHome, Set_ThePrizeOfTheNorth, Set_ADireMessage]
    Cycle_Wardens -> [ Set_SecretsAndSchemes, Set_ADeadlyGame, Set_TheValemen, Set_ATimeForWolves, Set_HouseOfTalons, Set_TheBlueIsCalling ]

first_set_in_cycle : Cycle -> Set
first_set_in_cycle cycle = sets_in_cycle cycle |> List.head |> Maybe.withDefault Set_Core

last_set_in_cycle : Cycle -> Set
last_set_in_cycle cycle = sets_in_cycle cycle |> List.Extra.last |> Maybe.withDefault Set_Core

type SetOrCycle = SetOrCycle_Set Set | SetOrCycle_Cycle Cycle

set_belongs_to : SetOrCycle -> Set -> Bool
set_belongs_to set_or_cycle set_to_check = case set_or_cycle of
    SetOrCycle_Set set -> set == set_to_check
    SetOrCycle_Cycle cycle -> List.member set_to_check (sets_in_cycle cycle)

set_or_cycle_code_name : SetOrCycle -> String
set_or_cycle_code_name set_or_cycle = case set_or_cycle of
    SetOrCycle_Set set -> (data_of_set set).code_name
    SetOrCycle_Cycle cycle -> (data_of_cycle cycle).code_name

set_or_cycle_full_name : SetOrCycle -> String
set_or_cycle_full_name set_or_cycle = case set_or_cycle of
    SetOrCycle_Set set -> (data_of_set set).full_name
    SetOrCycle_Cycle cycle -> (data_of_cycle cycle).full_name

set_or_cycle_icon : SetOrCycle -> String
set_or_cycle_icon set_or_cycle = case set_or_cycle of
    SetOrCycle_Cycle cycle -> "/images/sets/" ++ (data_of_cycle cycle).code_name ++ ".png"
    SetOrCycle_Set set ->
        let
            data = data_of_set set
        in
            case data.cycle of
                Nothing -> "/images/sets/" ++ data.code_name ++ ".png"
                Just cycle -> "/images/sets/" ++ (data_of_cycle cycle).code_name ++ ".png"

all_sets_and_cycles_in_order : List SetOrCycle
all_sets_and_cycles_in_order =
    let 
        core_and_expansions = 
            [ SetOrCycle_Set Set_Core
            , SetOrCycle_Set Set_KingsOfTheSea
            , SetOrCycle_Set Set_PrincesOfTheSun
            , SetOrCycle_Set Set_LordsOfWinter
            , SetOrCycle_Set Set_KingsOfTheStorm
            , SetOrCycle_Set Set_QueenOfDragons
            , SetOrCycle_Set Set_LionsOfTheRock
            ]
        cycle_sets = cycle_data
            |> List.map .cycle
            |> List.map (\c -> (SetOrCycle_Cycle c :: (sets_in_cycle c |> List.map SetOrCycle_Set)))
            |> List.concat
    in
        core_and_expansions ++ cycle_sets
