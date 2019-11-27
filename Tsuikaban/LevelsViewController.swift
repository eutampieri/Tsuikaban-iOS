//
//  LevelsController.swift
//  Tsuikaban
//
//  Created by Eugenio Tampieri on 27/11/2019.
//  Copyright © 2019 Eugenio Tampieri. All rights reserved.
//

import Foundation
import UIKit

class LevelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var levels: [Level] = Array(0...16).map{Level(unlocked: $0%2 == 0, name: "Level \($0)", path: "")}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.levels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell! = self.levelsList.dequeueReusableCell(withIdentifier: "levelCell")
        if !self.levels[indexPath.row].unlocked {
            cell.selectionStyle = .none
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = .placeholderText
            } else {
                cell.textLabel?.textColor = .lightGray
            }
        }
        cell.textLabel?.text = self.levels[indexPath.row].name
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.selectionStyle == .none {
            return;
        }
        performSegue(withIdentifier: "toSpriteKitVC", sender: self.levels[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! GameViewController).level = (sender as? Level)
    }
    override func didReceiveMemoryWarning() {
        //<#code#>
    }
    
    @IBOutlet weak var levelsList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.levelsList.register(UITableViewCell.self, forCellReuseIdentifier: "levelCell")
    }
    
}
