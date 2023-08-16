//
//  Gyms.swift
//  WebScraper
//
//  Created by Parineet Vernekar on 15/08/2023.
//

import Foundation

enum Gyms : String, CaseIterable, Identifiable, CustomStringConvertible {
    case Milton_Keynes = "Milton Keynes"
    case Swindon = "Swindon"
    case Acton = "Acton"
    
    var id:Self{self}
    var description: String{
        switch self{
        case .Milton_Keynes:
            return "Milton Keynes"
        case .Acton:
            return "Acton"
        case .Swindon:
            return "Swindon"
        }
    }
}
