//
//  BreweryTableViewController.swift
//  Brauhaus Finder
//
//  Created by Rebekah Sippert on 8/8/17.
//
//

import UIKit

class BreweryTableViewController : UITableViewController {
    
    var state: String = ""
    var breweries: [Brewery] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "\(state) Breweries"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BreweryCell")
        
        BreweryDB.loadBreweries(state: state) {
            breweries, error in
            
            if error != nil {
                print("Error occurred loading breweries: \(error.debugDescription)")
            }
            
            self.breweries = breweries
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return breweries.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreweryCell", for: indexPath)
        cell.textLabel?.text = breweries[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let breweryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BreweryDetailVC") as? BreweryDetailViewController {
            breweryDetailVC.brewery = breweries[indexPath.row]
            self.navigationController?.pushViewController(breweryDetailVC, animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
