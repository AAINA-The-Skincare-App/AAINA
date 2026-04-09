//
//  ResultViewController.swift
//  ScanCard
//
//  Created by GEU on 18/03/26.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    
    var ingredients: [String] = []
    var step: String = ""
    
    private let routineManager = RoutineManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        analyzeIngredients()
        
        navigationItem.hidesBackButton = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func scanNewTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "result_to_scan", sender: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

private extension ResultViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        resultLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        resultLabel.textAlignment = .center
        
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        
        tableView.dataSource = self
        
        scanButton.setTitle("New Scan", for: .normal)
        scanButton.setTitle("New Scan", for: .highlighted)
    }
}

private extension ResultViewController {
    
    func analyzeIngredients() {
        
        let routineIngredients = routineManager.getRoutineIngredients(for: step)
        let conflicts = routineManager.getConflictingPairs()
        
        let matched = ingredients.filter { routineIngredients.contains($0) }
        
        var conflictMessage: String?
        
        for ingredient in ingredients {
            for pair in conflicts {
                if pair.contains(ingredient) {
                    let other = pair.first { $0 != ingredient }!
                    if routineManager.currentRoutineContains(other) {
                        conflictMessage = "\(ingredient) conflicts with \(other)"
                        break
                    }
                }
            }
        }
        
        if !matched.isEmpty {
            resultLabel.text = "Suitable for your routine"
            detailLabel.text = "This product matches your \(step) step"
        }
        else if let conflict = conflictMessage {
            resultLabel.text = "Not suitable"
            detailLabel.text = conflict
        }
        else {
            resultLabel.text = "Not recommended"
            detailLabel.text = "Ingredients do not match your routine"
        }
    }
}

extension ResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = ingredients[indexPath.row]
        return cell
    }
}


