//
//  SignUpViewController.swift
//  Hype
//
//  Created by RYAN GREENBURG on 9/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
 // MARK: - Day 3 Changes
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        UserController.shared.createUserWith(username) { (result) in
            switch result {
            case .success(let user):
                guard let user = user else { return }
                UserController.shared.currentUser = user
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    func fetchUser() {
        UserController.shared.fetchUser { (result) in
            switch result {
            case .success(let user):
                guard let user = user else { return }
                UserController.shared.currentUser = user
                self.presentHypeListVC()
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
}
