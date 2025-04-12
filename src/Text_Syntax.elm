module Text_Syntax exposing (text)

text : String
text = """
# Syntax guide

Search in this page is based on a query language. The language contains many keywords to filter cards by many criteria. You can write a query in any search box.

When you use the advanced search page, the UI is actually a friendly interface for the query language. The inputs you decide to use will be translated to a query for searching.

The query language is more powerful than the advanced search UI. There are more queries you can make by typing them down than what the UI lets you. This page explains everything you can do with the search language.

## Basics

The query string gets parsed to a set of individual predicates, separated by spaces. A card is found if it matches all predicates.

So, for example, the query [`trait:knight house=b`](/search?q=trait%3Aknight%2Bhouse%3Db) will find all cards that belong to the Baratheon house AND have the Knight trait.

Quotes can be used to escape espaces, and have espaces within a predicate. For example, the query [`the viper`](/search?q=the+viper) will match all cards with the words "the" and "viper" in their name, which includes of course The Red Viper, as well the The Viper's Bannermen or Blood of the Viper. On the other, hand the query [`"the viper"`](/search?q="the%2Bviper"), with quotes, will match all cards that have "the viper" in the name, in that order, which includes The Viper's Bannermen and Blood of the Viper, but not The Red Viper.

## Searching by house

You can find cards of a house by using the `house=` keyword, followed by a house name.

Houses are represented by their initial, so house names are `s` for Stark, `l` for Lannister, `b` for Baratheon, `t` for Targaryen, `g` for Greyjoy, `m` for Martell and `n` for the neutral faction.

Fou can also use the inequality operators for making more complex searches. `!=` searches for cards that are not of the chosen house. `>=` is very useful because it searches for cards that have at least that house, and can be used with a house to find all cards that can be played in a deck of that house.

### Examples:

- All cards of the house Martell: [`house=m`](/search?q=house=m)
- All cards of exactly both Stark and Baratheon: [`house=sb`](/search?q=house=sb)
- All cards that are not neutral: [`house!=n`](/search?q=house!=n)
- All cards that can be played in a Targaryen deck: [`house>=t`](/search?q=house>=t)
"""
