//
//  HypeListViewController.swift
//  Hype
//
//  Created by Benjamin Tincher on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    @IBAction func createHypeButtonTapped(_ sender: Any) {
        presentCreateHypeAlert()
    }
    
    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to see new Hypes!")
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresher)
    }
    
    func updateViews() {
        tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    @objc func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            case .success(let response):
                print(response)
                self.updateViews()
            case .failure(_):
                print("there was a fetch error on function: \(#function)")
            }
        }
    }
    
    func presentCreateHypeAlert() {
        let alertController = UIAlertController(title: "Get Hyped!", message: "What is Hype may never die!", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "What is Hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Post Your Hype", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            
            HypeController.shared.createHype(with: text) { (result) in
                switch result {
                case .success(let response):
                    print(response)
                    self.updateViews()
                case .failure(_):
                    print("There was an error getting Hyped :(")
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true)
    }

}   //  End of Class

extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = "\(hype.timestamp)"
        
        return cell
    }
}   //  End of Extension
