//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Дмитрий Гришечко on 05.01.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
}

