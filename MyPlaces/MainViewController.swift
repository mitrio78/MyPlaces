//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Гришечко on 26.12.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    var places: Results<Place>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeOfLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)


        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {(contextualAction, view, boolValue) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeActionsConfiguration
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
            
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {return}
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    


}
