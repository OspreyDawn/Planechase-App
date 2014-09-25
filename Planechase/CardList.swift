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
    var standardCards = [Card]()
    var phenomCards = [Card]()
    var drawnCards = [Card]()
    
    var phenomOn = true
    var standardPosition = 0
    var probability = 0
    var currentViewedCard = 0

    init (phenom: Int = 0) {

        // Initialise the Card Deck, shuffle it, then draw the first card.
        phenomProbability = phenom
        
        // Initialise Index Array of Cards
        load(cardList, Card.CardType.Standard)
        load(phenomList, Card.CardType.Phenom)
        
        currentDeck = standardCards
        
        shuffle()
    }
    
    var phenomProbability: Int {
        get { return probability }
        set { if newValue == 1 {phenomOn = false}
            probability = newValue
        }
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
        
        let isPhenom = numberGenerator(self.phenomProbability) == 0
        var nextCard = currentDeck[standardPosition++]

        if phenomOn && isPhenom && standardPosition > 1 {
            nextCard = phenomCards[numberGenerator(phenomCards.count)]
        }
        
        drawnCards.append(nextCard)
        currentViewedCard = drawnCards.count - 1
        return (isPhenom, nextCard)
    }
    
    // Shuffle the card deck, reseting the drawn cards, and dealling a new card.
    func shuffle () {
        drawnCards = [] // empty the drawn cards
        standardPosition = 0
        currentViewedCard = 0
        
        let count = currentDeck.count
        assert(0 <= count) // Count should alsways be positive.
        for index in 0 ..< count {
            // Random int from 0 to index-1
            let randomNumber = Int(arc4random_uniform(UInt32(count)))
            
            // Swap two array elements
            let tmp = currentDeck[index]
            currentDeck[index] = currentDeck[randomNumber]
            currentDeck[randomNumber] = tmp
        }
        
        drawNewCard()
    }
}

func numberGenerator(chance: Int) -> Int {
    
    var randomNumber = Int(arc4random_uniform(UInt32(chance)))
    
    return randomNumber
    
}
