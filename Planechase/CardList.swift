//
//  CardList.swift
//  Planechase
//
//  Created by Max O'Brien on 20/08/14.
//  Copyright (c) 2014 Max O'Brien. All rights reserved.
//

import Foundation

var cardList = [
    
    "academy at tolaria west",
    "agyrem",
    "akoum",
    "aretopolis",
    "astral arena",
    "bant",
    "bloodhill bastion",
    "cliffside market",
    "edge of malacol",
    "eloren wilds",
    "feeding grounds",
    "fields of summer",
    "furnace layer",
    "gavony",
    "glen elendra",
    "glimmervoid basin",
    "goldmeadow",
    "grand ossuary",
    "grixis",
    "grove of the dreampods",
    "hedron fields of agadeem",
    "immersturm",
    "isle of vesuva",
    "izzet steam maze",
    "jund",
    "kessig",
    "kharasha foothills",
    "kilnspire district",
    "krosa",
    "lair of the ashen idol",
    "lethe lake",
    "llanowar",
    "minamo",
    "mount keralia",
    "murasa",
    "naar isle",
    "naya",
    "nephalia",
    "norn's dominion",
    "onakke catacomb",
    "orochi colony",
    "orzhova",
    "otaria",
    "panopticon",
    "pools of becoming",
    "prahv",
    "quicksilver sea",
    "raven's run",
    "sanctum of serra",
    "sea of sand",
    "selesnya loft gardens",
    "shiv",
    "skybreen",
    "sokenzan",
    "stairs to infinity",
    "stensia",
    "stronghold furnace",
    "takenuma",
    "talon gates",
    "the aether flues",
    "the dark barony",
    "the eon fog",
    "the fourth sphere",
    "the great forest",
    "the hippodrome",
    "the maelstrom",
    "the zephyr maze",
    "truga jungle",
    "turri island",
    "undercity reaches",
    "velis vel",
    "windriddle palaces"
    
]

var phenomList = [
    
    "chaotic aether",
    "morphic tide",
    "mutual epiphany",
    "planewide disaster",
    "reality shaping",
    "time distortion"
    
]

func cardCount() -> Int {
    return cardList.count
}

func getCard(array: Array<String>) -> Array<String> {
    return array
}

func getCardName(idx: Int) -> String {
    
    return getCard(cardList)[idx]
}

func numberGenerator(chance: Int) -> Int {
    
    var randomNumber = Int(arc4random_uniform(UInt32(chance)))
    
    return randomNumber
    
}

func shuffleArray<T>(inout array: Array<T>) -> Array<T>
{
    for var index = array.count - 1; index > 0; index--
    {
        // Random int from 0 to index-1
        var randomNumber = Int(arc4random_uniform(UInt32(index-1)))
        
        // Swap two array elements
        // Notice '&' required as swap uses 'inout' parameters
        swap(&array[index], &array[randomNumber])
    }
    return array
}

func cardOrder(cards: Int) -> Array<Int>
{
    var order = [Int]()
    
    // Initialise Index Array to size of Cards
    for index in 0...(cards-1)
    {
        order.append(index)
    }
    // shuffle the card order
    return shuffleArray(&order)
}