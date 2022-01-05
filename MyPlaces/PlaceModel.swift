//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Дмитрий Гришечко on 04.01.2022.
//

import UIKit


struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var restaurantImage: String?
    var image: UIImage?
    
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка",
    ]
    
    static func getPlaces () -> [Place]{
        
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Уфа", type: "Ресторан", restaurantImage: place, image: nil))
        }
        
        return places
        
    }
}
