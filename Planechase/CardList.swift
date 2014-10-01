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
    "celestine reef",
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
    "horizon boughs",
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
    "mirrored depths",
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
    "tazeem",
    "tember city",
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

class Card {
    
    enum CardType { case Standard, Phenom }
    
    let name: String
    let type: CardType
    
    let image: String
    let backgroundImage: String
    
    var included = true
    
    init ( _ cname: String, _ ctype: CardType ) {
        name = cname
        type = ctype
        image = name + ".hq"
        backgroundImage = name + ".crop.hq"
    }
}

class CardDeck {
    
    var currentDeck = [Card]()
    var currentPhenomCards = [Card]()
    var standardCards = [Card]()
    var phenomCards = [Card]()
    var drawnCards = [Card]()
    
    var standardPosition = 0
    var phenomPosition = 0
    var phenomProbability = 5
    var currentViewedCard = 0

    init () {

        // Initialise the Card Deck, shuffle it, then draw the first card.
        
        // Initialise Index Array of Cards
        load(cardList, Card.CardType.Standard)
        load(phenomList, Card.CardType.Phenom)
        
        currentDeck = standardCards
        currentPhenomCards = phenomCards
        
        shuffle()
    }

    // Position onto the last drawn, or 'current' card
    var currentCard: Card {
        assert(!drawnCards.isEmpty)
        currentViewedCard = drawnCards.count-1 // set to the last drawn card
        return drawnCards[currentViewedCard]
    }
    
    // Move to the next drawn card.
    var nextCard: Card {
        assert(!drawnCards.isEmpty)
        if currentViewedCard < drawnCards.count-1 { currentViewedCard++ }
            
        return drawnCards[currentViewedCard]
    }

    // Move to the previous drawn card
    var previousCard: Card {
        assert(!drawnCards.isEmpty)
        if 0 < currentViewedCard { currentViewedCard-- }
            
        return drawnCards[currentViewedCard]
    }
    
    // Load the cards from an array of card string names
    func load ( names: [String], _ cardType: Card.CardType ) {
        // Initialise Index Array to size of Cards
        for string in names {
            switch cardType {
            case .Standard:
                standardCards.append(Card(string, cardType))
            case .Phenom:
                phenomCards.append(Card(string, cardType))
            default:
                assert(false) // We should never get here!
            }
        }
    }
    
    // Draw a new card from the standard deck or draw a Phenom card
    func drawNewCard () -> (newCard: Bool, card:Card)? {
        if currentDeck.count < standardPosition {
            return nil
        }
        
        if drawnCards.count == currentDeck.count {
            drawnCards = []
            standardPosition = 0
            phenomPosition = 0
            currentViewedCard = 0
            phenomPosition = 0
        }
        
        let isPhenom = numberGenerator(phenomProbability) == 0
        var nextCard = currentDeck[standardPosition++]
        
        if isPhenom && standardPosition > 1 && phenomPosition <= currentPhenomCards.count-1 {
            nextCard = currentPhenomCards[phenomPosition++]
        }
        
        drawnCards.append(nextCard)
        currentViewedCard = drawnCards.count - 1
        return (isPhenom, nextCard)
    }
    
    // Shuffle the card deck, reseting the drawn cards, and dealling a new card.
    func shuffle () {
        drawnCards = [] // empty the drawn cards
        currentDeck = [] // empty the current deck
        currentPhenomCards = [] // empty the current phenom card list
        standardPosition = 0
        currentViewedCard = 0
        phenomPosition = 0
        
        for index in 0 ..< standardCards.count {
            
            if standardCards[index].included == true {
                currentDeck.append(standardCards[index])
            }
            
        }
        
        for index in 0 ..< phenomCards.count {
            
            if phenomCards[index].included == true {
                currentPhenomCards.append(phenomCards[index])
            }
            
        }
        
        let standardCount = currentDeck.count
        let phenomCount = currentPhenomCards.count
        assert(0 <= standardCount)
        assert(0 <= phenomCount)// Count should alsways be positive.
        
        for index in 0 ..< standardCount {
            // Random int from 0 to index-1
            let randomNumber = Int(arc4random_uniform(UInt32(standardCount)))
            
            // Swap two array elements
            let tmp = currentDeck[index]
            currentDeck[index] = currentDeck[randomNumber]
            currentDeck[randomNumber] = tmp
        }
        
        for index in 0 ..< phenomCount {
            // Random int from 0 to index-1
            let randomNumber = Int(arc4random_uniform(UInt32(phenomCount)))
            
            // Swap two array elements
            let tmp = currentPhenomCards[index]
            currentPhenomCards[index] = currentPhenomCards[randomNumber]
            currentPhenomCards[randomNumber] = tmp
        }
        
        drawNewCard()
    }
}

func numberGenerator(chance: Int) -> Int {
    
    var randomNumber = Int(arc4random_uniform(UInt32(chance)))
    
    return randomNumber
    
}
