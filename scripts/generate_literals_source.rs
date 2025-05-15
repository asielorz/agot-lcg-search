---cargo
[package]
name = "generate_literals_source"
version = "0.1.0"
edition = "2024"
[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
---

use serde::Deserialize;
use std::fmt::{Debug, Write};
use std::collections::HashMap;

#[derive(Deserialize, Clone)]
struct Card {
    id: String,
    full_image_url: String,
    preview_image_url: String,
    name: String,
    card_type: String,
    set: String,
    number: i32,
    quantity: i32,
    limit: i32,
    legality_joust: String,
    legality_melee: String,
    illustrator: String,
    house: Vec<String>,
    legal_in_houses: Vec<String>,
    unique: bool,
    rules_text: Option<String>,
    flavor_text: Option<String>,
    erratas: Vec<Errata>,
    duplicate_id : Option<String>,

    // Character
    cost: Option<i32>,
    icons: Vec<String>,
    crest: Vec<String>,
    traits: Vec<String>,
    strength: Option<i32>,

    // Plot
    income: Option<i32>,
    initiative: Option<i32>,
    claim: Option<i32>,

    // Others
    influence: Option<i32>,
}

#[derive(Deserialize, Clone, Copy)]
struct Errata {
    line: i32,
    start: i32,
    end: i32,
}

#[derive(Deserialize, Clone)]
struct Faq {
    cards_mentioned : Vec<String>,
    text : String,
}

fn main() {
    let args = std::env::args().collect::<Vec<_>>();

    if args.len() != 5 {
        panic!(
            "Incorrect number of arguments. Arguments are: cards.json faqs.json Cards.elm Faqs.elm"
        );
    }

    let cards_json = std::fs::read_to_string(&args[1]).unwrap();
    let cards: Vec<Card> = serde_json::from_str(&cards_json).unwrap();

    let faqs_json = std::fs::read_to_string(&args[2]).unwrap();
    let faqs: Vec<Faq> = serde_json::from_str(&faqs_json).unwrap();

    std::fs::create_dir_all("./generated").unwrap();

    let cards_elm_source = print_cards_elm_file(&cards);
    std::fs::write(&args[3], &cards_elm_source).unwrap();

    let faqs_elm_source = print_faqs_elm_file(&faqs);
    std::fs::write(&args[4], &faqs_elm_source).unwrap();
}

fn print_cards_elm_file(cards: &[Card]) -> String {
    let set_name_to_source : HashMap<&str, &str> = HashMap::from([
        ("Core", "Set_Core"),
        ("Kings of the Sea", "Set_KingsOfTheSea"),
        ("Princes of the Sun", "Set_PrincesOfTheSun"),
        ("Lords of Winter", "Set_LordsOfWinter"),
        ("Kings of the Storm", "Set_KingsOfTheStorm"),
        ("Queen of Dragons", "Set_QueenOfDragons"),
        ("Lions of the Rock", "Set_LionsOfTheRock"),

        ("The War of Five Kings", "Set_TheWarOfTheFiveKings"),
        ("Ancient Enemies", "Set_AncientEnemies"),
        ("Sacred Bonds", "Set_SacredBonds"),
        ("Epic Battles", "Set_EpicBattles"),
        ("Battle of Ruby Ford", "Set_BattleOfRubyFord"),
        ("Calling the Banners", "Set_CallingTheBanners"),

        ("A Song of Summer", "Set_ASongOfSummer"),
        ("The Winds of Winter", "Set_TheWindsOfWinter"),
        ("A Change of Seasons", "Set_AChangeOfSeasons"),
        ("The Raven's Song", "Set_TheRavensSong"),
        ("Refugees of War", "Set_RefugeesOfWar"),
        ("Scattered Armies", "Set_ScatteredArmies"),

        ("City of Secrets", "Set_CityOfSecrets"),
        ("A Time of Trials", "Set_ATimeOfTrials"),
        ("The Tower of the Hand", "Set_TheTowerOfTheHand"),
        ("Tales from the Red Keep", "Set_TalesFromTheRedKeep"),
        ("Secrets and Spies", "Set_SecretsAndSpies"),
        ("The Battle of Blackwater Bay", "Set_TheBattleOfBlackwaterBay"),

        ("Wolves of the North", "Set_WolvesOfTheNorth"),
        ("Beyond the Wall", "Set_BeyondTheWall"),
        ("A Sword in the Darkness", "Set_ASwordInTheDarkness"),
        ("The Wildling Horde", "Set_TheWildlingHorde"),
        ("A King in the North", "Set_AKingInTheNorth"),
        ("Return of the Others", "Set_ReturnOfTheOthers"),

        ("Illyrio's Gift", "Set_IllyriosGift"),
        ("Rituals of R'hllor", "Set_RitualsOfRhllor"),
        ("Mountains of the Moon", "Set_MountainsOfTheMoon"),
        ("A Song of Silence", "Set_ASongOfSilence"),
        ("Of Snakes and Sand", "Set_OfSnakesAndSand"),
        ("Dreadfort Betrayal", "Set_DreadfortBetrayal"),

        ("Gates of the Citadel", "Set_GatesOfTheCitadel"),
        ("Forging the Chain", "Set_ForgingTheChain"),
        ("Called by the Conclave", "Set_CalledByTheConclave"),
        ("The Isle of Ravens", "Set_TheIlseOfRavens"),
        ("Mask of the Archmaester", "Set_MaskOfTheArchmaester"),
        ("Here to Serve", "Set_HereToServe"),

        ("The Tourney for the Hand", "Set_TourneyForTheHand"),
        ("The Grand Melee", "Set_TheGrandMelee"),
        ("On Dangerous Grounds", "Set_OnDangerousGrounds"),
        ("Where Loyalty Lies", "Set_WhereLoyaltyLies"),
        ("Trial By Combat", "Set_TrialByCombat"),
        ("A Poisoned Spear", "Set_APoisonedSpear"),

        ("Valar Morghulis", "Set_ValarMorghulis"),
        ("Valar Dohaeris", "Set_ValarDohaeris"),
        ("Chasing Dragons", "Set_ChasingDragons"),
        ("A Harsh Mistress", "Set_AHarshMistress"),
        ("The House of Black and White", "Set_TheHouseOfBlackAndWhite"),
        ("A Roll of the Dice", "Set_ARollOfTheDice"),

        ("Reach of the Kraken", "Set_ReachOfTheKraken"),
        ("The Grand Fleet", "Set_TheGrandFleet"),
        ("The Pirates of Lys", "Set_ThePiratesOfLys"),
        ("A Turn of the Tide", "Set_ATurnOfTheTide"),
        ("The Captain's Command", "Set_TheCaptainsCommand"),
        ("A Journey's End", "Set_AJourneysEnd"),

        ("The Banners Gather", "Set_TheBannersGather"),
        ("Fire and Ice", "Set_FireAndIce"),
        ("The Kingsguard", "Set_TheKingsguard"),
        ("The Horn that Wakes", "Set_TheHornThatWakes"),
        ("Forgotten Fellowship", "Set_ForgottenFellowship"),
        ("A Hidden Agenda", "Set_AHiddenAgenda"),

        ("Spoils of War", "Set_SpoilsOfWar"),
        ("The Champion's Purse", "Set_TheChampionsPurse"),
        ("Fire Made Flesh", "Set_FireMadeFlesh"),
        ("Ancestral Home", "Set_AncestralHome"),
        ("The Prize of the North", "Set_ThePrizeOfTheNorth"),
        ("A Dire Message", "Set_ADireMessage"),

        ("Secrets and Schemes", "Set_SecretsAndSchemes"),
        ("A Deadly Game", "Set_ADeadlyGame"),
        ("The Valemen", "Set_TheValemen"),
        ("A Time for Wolves", "Set_ATimeForWolves"),
        ("House of Talons", "Set_HouseOfTalons"),
        ("The Blue is Calling", "Set_TheBlueIsCalling"),
    ]);

    let icon_to_source : HashMap<&str, &str> = HashMap::from([
        ("Military", "Icon_Military { naval = False }"),
        ("Military (Naval)", "Icon_Military { naval = True }"),
        ("Intrigue", "Icon_Intrigue { naval = False }"),
        ("Intrigue (Naval)", "Icon_Intrigue { naval = True }"),
        ("Power", "Icon_Power { naval = False }"),
        ("Power (Naval)", "Icon_Power { naval = True }"),
    ]);

    let mut result = String::with_capacity(1024 * 16);
    result += "module Cards exposing (all_cards)\n\nimport Card exposing (..)\nimport CardSet exposing (..)\n\nall_cards : List Card\nall_cards =\n";

    if cards.is_empty() {
        result += "    []\n";
        return result;
    }

    let mut separator = '[';

    for card in cards {
        _ = writeln!(result, "  {} {{ id = \"{}\"", separator, card.id);
        _ = writeln!(result, "    , name = {:?}", card.name);
        _ = writeln!(result, "    , card_type = CardType_{}", card.card_type);
        _ = writeln!(result, "    , set = {}", set_name_to_source.get(card.set.as_str()).unwrap());
        _ = writeln!(result, "    , number = {}", card.number);
        _ = writeln!(result, "    , quantity = {}", card.quantity);
        _ = writeln!(result, "    , limit = {}", card.limit);
        _ = writeln!(result, "    , legality_joust = Legality_{}", card.legality_joust);
        _ = writeln!(result, "    , legality_melee = Legality_{}", card.legality_melee);
        _ = writeln!(result, "    , illustrator = \"{}\"", card.illustrator);
        _ = writeln!(result, "    , house = {}", enum_array_to_elm_code("House", &card.house));
        _ = writeln!(result, "    , legal_in_houses = {}", enum_array_to_elm_code("House", &card.legal_in_houses));
        _ = writeln!(result, "    , unique = {}", if card.unique { "True" } else { "False" });
        _ = writeln!(result, "    , rules_text = {}", option_to_elm_code(&card.rules_text));
        _ = writeln!(result, "    , flavor_text = {}", option_to_elm_code(&card.flavor_text));
        _ = writeln!(result, "    , cost = {}", option_to_elm_code(&card.cost));
        _ = writeln!(result, "    , icons = {}", icons_array_to_elm_code(&card.icons, &icon_to_source));
        _ = writeln!(result, "    , crest = {}", enum_array_to_elm_code("Crest", &card.crest));
        _ = writeln!(result, "    , traits = [ {} ]", card.traits.iter().map(|t| format!("{:?}", t)).collect::<Vec<_>>().join(", "));
        _ = writeln!(result, "    , strength = {}", option_to_elm_code(&card.strength));
        _ = writeln!(result, "    , income = {}", option_to_elm_code(&card.income));
        _ = writeln!(result, "    , initiative = {}", option_to_elm_code(&card.initiative));
        _ = writeln!(result, "    , claim = {}", option_to_elm_code(&card.claim));
        _ = writeln!(result, "    , influence = {}", option_to_elm_code(&card.influence));
        _ = writeln!(result, "    , erratas = {}", erratas_to_elm_code(&card.erratas));
        _ = writeln!(result, "    , duplicate_id = {}", option_to_elm_code(&card.duplicate_id));
        _ = writeln!(result, "    }}");

        separator = ',';
    }

    _ = writeln!(result, "    ]");

    result
}

fn option_to_elm_code<T: Debug>(opt: &Option<T>) -> String {
    match opt {
        Some(value) => format!("Just {:?}", value),
        None => "Nothing".to_string(),
    }
}

fn enum_array_to_elm_code(enum_name: &str, enum_array: &[String]) -> String {
    if enum_array.is_empty() {
        "[]".into()
    } else {
        format!("[ {} ]", enum_array.iter().map(|h| format!("{}_{}", enum_name, h)).collect::<Vec<_>>().join(", "))
    }
}

fn icons_array_to_elm_code(array: &[String], map : &HashMap<&str, &str>) -> String {
    if array.is_empty() {
        "[]".into()
    } else {
        format!("[ {} ]", array.iter().map(|i| *map.get(i.as_str()).unwrap()).collect::<Vec<_>>().join(", "))
    }
}

fn erratas_to_elm_code(erratas : &[Errata]) -> String {
    if erratas.is_empty() {
        "[]".into()
    } else if erratas.len() == 1 {
        format!("[ {{ line = {}, start = {}, end = {} }} ]", erratas[0].line, erratas[0].start, erratas[0].end)
    } else {
        let mut result = String::from("\n");

        let mut separator = '[';
        for errata in erratas {
            _ = writeln!(result, "      {} {{ line = {}, start = {}, end = {} }}", separator, errata.line, errata.start, errata.end);
            separator = ',';
        }
        _ = write!(result, "      ]");

        result
    }
}

fn print_faqs_elm_file(faqs : &[Faq]) -> String {
    let mut result = String::with_capacity(1024 * 16);
    result += "module Faqs exposing (all_faqs)\n\nimport Card exposing (..)\n\nall_faqs : List Faq\nall_faqs =\n";

    if faqs.is_empty() {
        result += "    []\n";
        return result;
    }

    let mut separator = '[';

    for faq in faqs {
        _ = writeln!(result, "  {} {{ cards_mentioned = [ {} ]", separator, faq.cards_mentioned.iter().map(|t| format!("{:?}", t)).collect::<Vec<_>>().join(", "));
        _ = writeln!(result, "    , text = {:?}", faq.text);
        _ = writeln!(result, "    }}");

        separator = ',';
    }
    
    _ = writeln!(result, "    ]");

    result
}
