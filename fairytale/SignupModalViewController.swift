//
//  SignupModalViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/14/24.
//

import Foundation
import UIKit
class SignupModalViewController: UIViewController {
    @IBOutlet weak var signupTextLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        popupView.layer.cornerRadius = 10
        
        if let snapshot = self.navigationController?.view.snapshotView(afterScreenUpdates: false) {
                self.view.insertSubview(snapshot, at: 0)
            }
        
        let darkView = UIView(frame: self.view.bounds)
            darkView.backgroundColor = .black
            darkView.alpha = 0.5
        darkView.isUserInteractionEnabled = false

            self.view.addSubview(darkView)
        
        popupView.layer.zPosition = 100
    }
    
    @IBAction func popToLogin(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
