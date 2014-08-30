//
//  PlanarDie.swift
//  Planechase
//
//  Created by Max O'Brien on 23/08/14.
//  Copyright (c) 2014 Max O'Brien. All rights reserved.
//

import Foundation


func dieResult() -> String {
    
    var dieValue = String()
    var dieRoll = phenomGenerator(6)
    
    if dieRoll >= 2 {
        
        dieValue = "img-sq_pd-b_180"
        
    } else if dieRoll == 1 {
        
        dieValue = "img-sq_pd-c_180"
        
    } else if dieRoll == 0 {
        
        dieValue = "img-sq_pd-p_180"
        
    }
    
    return dieValue
}

// func dieImageSequence(number: Int) -> String {
    
    // var imageNumber = String()
    
    // imageNumber = "\(number)"
    
    // return imageNumber
    
// }