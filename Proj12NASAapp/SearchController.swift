//
//  SearchController.swift
//  Proj12NASAapp
//
//  Created by Vernon G Martin on 5/21/17.
//  Copyright © 2017 Vernon G Martin. All rights reserved.
//

import UIKit
import MapKit

class SearchController: UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    //Sets the display on the search table to show the city and state for each item that is queried
    func getAddress(selectedItem:MKPlacemark) -> String {
        guard let city = selectedItem.locality,
            let state = selectedItem.administrativeArea else {return ""}
        let address = "\(city), \(state)"
        
        
        return address
    }

}

//MARK: - Extensions
extension SearchController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
        let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
}


extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = getAddress(selectedItem: selectedItem)
        return cell
    }
}

//Implements drop pin delegate method to drop pin on the map based on selected item
extension SearchController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
