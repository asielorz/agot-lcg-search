module Text_Syntax exposing (text)

text : String
text = """
# Syntax guide

Search in this page is based on a query language. The language contains many keywords to filter cards by many criteria. You can write a query in any search box.

When you use the advanced search page, the UI is actually a friendly interface for the query language. The inputs you decide to use will be translated to a query for searching.

The query language is more powerful than the advanced search UI. There are more queries you can make by typing them down than what the UI lets you. This page explains everything you can do with the search language.

## Basics

The query string gets parsed to a set of individual predicates, separated by spaces. A card is found if it matches all predicates.

So, for example, the query [`trait:knight house=b text:renown`](/search?q=trait%3Aknight%2Bhouse%3Db%2Btext%3Arenown) will find all cards that belong to the Baratheon house AND have the Knight trait AND have the word "renown" in their rules text.

Quotes can be used to escape espaces, and have espaces within a predicate. For example, the query [`the viper`](/search?q=the+viper) will match all cards with the words "the" and "viper" in their name, which includes of course The Red Viper, as well the The Viper's Bannermen or Blood of the Viper. On the other, hand the query [`"the viper"`](/search?q="the%2Bviper"), with quotes, will match all cards that have "the viper" in the name, in that order, which includes The Viper's Bannermen and Blood of the Viper, but not The Red Viper.

## Searching by house

You can find cards of a house by using the `house=` keyword, followed by a house name.

Houses are represented by their initial, so house names are `s` for Stark, `l` for Lannister, `b` for Baratheon, `t` for Targaryen, `g` for Greyjoy, `m` for Martell and `n` for the neutral faction.

You can also use the inequality operators for making more complex searches. `!=` searches for cards that are not of the chosen house. `>=` is very useful because it searches for cards that have at least that house, and can be used with a house to find all cards that can be played in a deck of that house.

### Examples:

- All cards of the house Martell: [`house=m`](/search?q=house=m)
- All cards of exactly both Stark and Baratheon: [`house=sb`](/search?q=house=sb)
- All cards that are not neutral: [`house!=n`](/search?q=house!=n)
- All cards that can be played in a Targaryen deck: [`house>=t`](/search?q=house>=t)

## Types and traits

`type:` can be used to search cards of a type. A Game of Thrones LCG has 7 types of cards. The types can be written as either abbreviations or their full name. The names of the types are the following.

- Character: [`type:c`](/search?q=type%3Ac) or [`type:character`](/search?q=type%3Acharacter)
- Location: [`type:l`](/search?q=type%3Al) or [`type:location`](/search?q=type%3Alocation)
- Attachment: [`type:at`](/search?q=type%3Aat) or [`type:attachment`](/search?q=type%3Aattachment)
- Event: [`type:e`](/search?q=type%3Ae) or [`type:event`](/search?q=type%3Aevent)
- Plot: [`type:p`](/search?q=type%3Ap) or [`type:plot`](/search?q=type%3Aplot)
- Agenda: [`type:ag`](/search?q=type%3Aag) or [`type:agenda`](/search?q=type%3Aagenda)
- House: [`type:h`](/search?q=type%3Ah) or [`type:house`](/search?q=type%3Ahouse)

Attachment and agenda use a 2 letter abbreviation instead of a 1 letter abbreviation because they both start with the letter "a".

`trait:` can be used to searcho for cards of a type. You don't need to spell out the entire trait. It is enough for the trait name to contain the letters written. Upper and lower case of letters doesn't matter either.

`unique:` can be used to search for cards that are or are not unique.

### Examples:

- All cards of the house Tully: [`trait="House Tully"`](/search?q=trait%3A"House%2BTully")
- All cards of the house Tully, but shorter to write: [`trait:tully`](/search?q=trait%3Atully)
- All The North agendas: [`trait:north type:ag`](/search?q=trait%3Anorth%2Btype%3Aag)
- All City plots: [`trait:city`](/search?q=trait%3Acity)
- All unique armies: [`unique:t trait:army`](/search?q=unique%3At%2Btrait%3Aarmy)
- All lords that are not unique: [`unique:f trait:lord`](/search?q=unique%3Af%2Btrait%3Alord)

## Rules and flavor text

Use `text:` to search for cards with that word or words in their rules text. The text searched is the official patched text after erratas. So, for example, King's Landing [Robert Baratheon](/card/kl_46) is considered to have the "limit 3 times per phase" part of his standing ability in his ruled text, even if the printed card does not.

`flavor:` can be used to search in the flavor text. The flavor text is the decorative text, usually in italic or bold, at the bottom of some cards, that does not affect gameplay.

### Examples:

- All cards that make a player draw a card: [`text:"draw a card"`](/search?q=text%3A"draw%2Ba%2Bcard")
- All cards with stalwart: [`text:stalwart`](/search?q=text%3Astalwart)
- All cards designed by the winner of a tournament: [`flavor:"designed by"`](/search?q=flavor%3A"designed%2Bby")

## Sets and cycles

It is possible to search for all cards in a set, be it the Core Set, a house expansion card like Lords of Winter or a regular chapter. It is also possible to search for cards in a cycle, which is each set of six chapters that share an icon and a theme.

Both can be achieved using the `set=` keyword. Set accepts all six comparison operators, so you can use `set!=` to search for cards that don't belong to a set or cycle. Set inequality operators can be used to search for cards that are newer or older than a set.

Sets and cycles are identified by their codenames, which are usually the acronym of their name.

### Some common codenames

- Core Set: [`core`](/search?q=set%3Dcore)
- Kings of the Sea: [`kotse`](/search?q=set%3Dkotse)
- Princes of the Sun: [`pots`](/search?q=set%3Dpots)
- Lords of Winter: [`low`](/search?q=set%3Dlow)
- Kings of the Storm: [`kotst`](/search?q=set%3Dkotst)
- Queen of Dragons: [`qod`](/search?q=set%3Dqod)
- Lions of the Rock: [`lotr`](/search?q=set%3Dlotr)
- Lions of the Rock: [`lotr`](/search?q=set%3Dlotr)
- A Clash of Arms: [`acoa`](/search?q=set%3Dacoa)
- A Time of Ravens: [`ator`](/search?q=set%3Dator)
- King's Landing: [`kl`](/search?q=set%3Dkl)
- Defenders of the North: [`dotn`](/search?q=set%3Ddotn)
- Brotherhood without Banners: [`bwb`](/search?q=set%3Dbwb)
- Secrets of Oldtown: [`soo`](/search?q=set%3Dsoo)
- A Tale of Champions: [`atoc`](/search?q=set%3Datoc)
- Beyond the Narrow Sea: [`btns`](/search?q=set%3Dbtns)
- A Song of the Sea: [`asots`](/search?q=set%3Dasots)
- Kingsroad: [`kr`](/search?q=set%3Dkr)
- Conquest and Defiance: [`cad`](/search?q=set%3Dcad)
- Wardens: [`w`](/search?q=set%3Dw)

You'll see that if you use this feature frequently you will end up learning them. You can usually figure out the codename for a set by its name.

### Examples
- All cards from A Time of Ravens up to Secrets of Oldtown: [`set>=ator set<=soo`](/search?q=set>%3Dator%2Bset<%3Dsoo)
- All cards in Brotherhood without Banners except the ones from Mountains of the Moon: [`set=bwb set!=motm`](/search?q=set%3Dbwb%2Bset!%3Dmotm)
- All cards from one of the six house expansions: [`set>=kotse set<=lotr`](/search?q=set>%3Dkotse%2Bset<%3Dlotr)

## Numbers, numbers, numbers

You can search cards by many of their numeric attributes. For example, you can search for characters by strength. For plots, you can search by income, initiative and claim. For characters, locations and attachments, you can search not only by cost, but also by the amount of extra income, initiative and influence they give.

### Examples

- All plots with claim 2 or more: [`claim>=2`](/search?q=claim>%3D2)
- All characters that give influence: [`type:c influence>0`](/search?q=type%3Ac%2Binfluence>0)
- All locations that give initiative: [`type:l initiative>0`](/search?q=type%3Al%2Binitiative>0)
- All plots that give no income: [`type:p income=0`](/search?q=type%3Ap%2Bincome%3D0)
- All cards that reduce the amount of gold a player gets: [`income<0`](/search?q=income<0)

## Card legality and formats

In A Game of Thrones LCG, some cards are restricted. A deck may only contain one card from the restricted list, with up to three copies of that card. This means that a deck that plays [Narrow Escape](/card/kotst_48) may contain up to three copies of it but may not play any other card from the restricted List.

There are also two formats in the game, melee and joust, each with its own restricted list. Joust is the 1v1 format, while melee is the format where three or more players play all against each other.

You can search for cards by legality with the `joust:` and `melee:` keywords.

### Examples

- All cards that are restricted in joust: [`joust:r`](/search?q=joust%3Ar)
- All cards that are restricted in melee: [`melee:r`](/search?q=melee%3Ar)
- All cards that are legal in both joust and melee: [`joust:l melee:l`](/search?q=joust%3Al%2Bmelee%3Al)

# Icons and crests

You can search for characters based on the icons they have with the `icon` keyword. It takes a comparison, allowing for more precise queries.

`icon>=` can be used to search for a character with at least the required icons. For example, [`icon>=mp`](/search?q=icon>%3Dmp) will find all characters with a military and a power icon, which includes characters with exactly those icons, like [Northern Cavalry Flank](/card/ator_103), but also characters with all three icons like [Cat o' the Canals](/card/ator_84) or characters with a military naval icon and then a regular power icon like A Song of the Sea [Victarion Greyjoy](/card/asots_6). On the other hand, [`icon=mp`](/search?q=icon%3Dmp) will only match characters with exactly a regular military icon and a regular power icon.

Similarly, the `creast` keyword can be used to search for characters that have a specific crest. The meaning of the operators are the same as for icons. However, for crests it is most likely that you'll want to use `crest=`

Examples:
- Characters with at least a military icon and an intrigue icon: [`icon>=mi`](/search?q=icon>%3Dmi)
- Characters with no icons: [`icon=`](/search?q=icon%3D)
- Characters with either a military icon or a power icon, but not both: [`icon<mp icon!=`](/search?q=icon%3Cmp%2Bicon!%3D)
- Characters with a war crest and other crests: [`crest>w`](/search?q=crest>w)
- Characters with a learned or a holy crest: [`crest<lh crest!=`](/search?q=crest<lh%2Bcrest!%3D)
- Characters playable in a Stark deck that have a military icon and a war crest: [`house>=s icon>=m crest>=w`](/search?q=house>%3Ds%2Bicon>%3Dm%2Bcrest>%3Dw). This is a useful thing to know if you want to play events like [Die by the Sword](/card/low_47) or [The Price of War](/card/kotse_38).
- Maesters with a learned crest: [`trait:maester crest>=l`](/search?q=trait%3Amaester%2Bcrest>%3Dl)

## Illustrator, number and quantity

You can use the keyword `illustrator:` to look for cards painted by some specific illustrator.

You can use the keyword `number` to search for the number of the card in the set.

You can use the keyword `quantity` to search by the number of the same card that came when you bought a chapter. For most cards, quantity is 3. However, before Secrets of Oldtown, chapters used to have 40 cards instead of 60, where 10 of the cards would come at 3 copies each and the other 10 at 1 copy each. The Core set also has weird quantities. Most cards come only one time, but some like [Rhaegal](/card/core_109) and [Robert Baratheon](/card/core_71) appear twice, a few locations have two or three copies and there are 5 copies of [Crossroads](/card/core_138) for some reason.

### Examples

- All cards illustrated by Cristina Vela: [`illustrator:cristina`](/search?q=illustrator%3Acristina)
- All cards in a chapter with only one copy per chapter: [`set>=acoa quantity=1`](/search?q=set>%3Dacoa%2Bquantity%3D1)

## Negated predicates

You can use `!` to negate a predicate. This is, to search for cards where that prediacte is false.

For example, due to how trait search works, searching for all characters with the "King" trait will also find all characters with the "Kingsguard" trait. However, you can find all kings by searching for all characters that have the "King" trait and don't have the "Kingsguard" trait, like this: [`type:c trait:king !trait:kingsguard`](/search?q=type%3Ac%2Btrait%3Aking%2B!trait%3Akingsguard).

### Examples:
- Limited locations that don't give gold or influence: [`type:l text:limited. !income>0 !influence>0`](/search?q=type%3Al%2Btext%3Alimited.%2B!income>0%2B!influence>0)
- Characters with the "Queen" trait: [`traits:queen !traits:queensguard`](/search?q=trait%3Aqueen%2B!trait%3Aqueensguard)
"""
