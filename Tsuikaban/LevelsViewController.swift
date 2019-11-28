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
    private var levels: [Level] = { () -> [Level] in
        let docsPath = Bundle.main.resourcePath! + "/levels"
        let fileManager = FileManager.default

        do {
            let docsArray = try fileManager.contentsOfDirectory(atPath: docsPath)
            
            return docsArray
                .filter { (filename: String) -> Bool in
                    return filename.contains(".txt")
                }
                .sorted {
                    let result: Bool = (Int($0.components(separatedBy: ".")[0].replacingOccurrences(of: "level", with: "")) ?? 0) < (Int ($1.components(separatedBy: ".")[0].replacingOccurrences(of: "level", with: "")) ?? 0)
                    return result}
                .map {(s: String) -> Level in
                    Level(
                    unlocked: true,
                    name: "Level " + s.components(separatedBy: ".")[0].replacingOccurrences(of: "level", with: ""),
                    path: Bundle.main.resourcePath! + "/levels/\(s)"
                    )
            }
        } catch {
            return []
        }
    }()

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
    @IBAction func unwindToLvlsLst(_ unwindSegue: UIStoryboardSegue) {
        let _sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    @IBOutlet weak var levelsList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.levelsList.register(UITableViewCell.self, forCellReuseIdentifier: "levelCell")
    }
    
}
