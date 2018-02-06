//
//  MenuViewController.swift
//  NYTTopStories
//
//  Created by Mark Zhong on 9/14/17.
//  Copyright © 2017 Mark Zhong. All rights reserved.
//

import UIKit

protocol MenuSectorDelegate {
    func reloadTableView(sector:String)
}

class MenuViewController: UITableViewController {

    let sectors = ["home","opinion","world","national","politics","upshot","nyregion","business","technology","science","health","sports","arts","books","movies","theater","sundayreview","fashion","tmagazine","food","travel","magazine","realestate","automobiles","obituaries","insider"]
    var chooseDelegate:MenuSectorDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255.0, green: 84.0/255.0, blue: 147.0/255.0, alpha: 1.0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCellId", for: indexPath)
        cell.textLabel?.text = sectors[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sectorString = self.sectors[indexPath.row]
        chooseDelegate.reloadTableView(sector: sectorString)
        self.revealViewController().revealToggle(animated: true)
    }
   
}
