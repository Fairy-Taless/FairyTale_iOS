//
//  FairytaleModalViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/16/24.
//

import Foundation
import UIKit

class FairytaleModalViewController: UIViewController{
    var fairytale: Fairytale?
    var previewImage: UIImage?
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalImageView: UIImageView!
    @IBOutlet weak var modalTitleLabel: UILabel!
    @IBOutlet weak var faceSwapSwitch: UISwitch!
    @IBOutlet weak var voiceCloningSwitch: UISwitch!
    
    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        modalView.layer.cornerRadius = 10
        
        if let snapshot = self.navigationController?.view.snapshotView(afterScreenUpdates: false) {
                self.view.insertSubview(snapshot, at: 0)
            }
        
        let darkView = UIView(frame: self.view.bounds)
            darkView.backgroundColor = .black
            darkView.alpha = 0.5
        darkView.isUserInteractionEnabled = false

            self.view.addSubview(darkView)
        
        modalView.layer.zPosition = 100
        
        
        modalImageView.image = previewImage
        if let name = fairytale?.name{
            modalTitleLabel.text = "\(name) 이야기를 읽으시겠습니까?"
        }
        modalImageView.layer.cornerRadius = 20
    }
    
    @IBAction func cancle(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "storyPage"){
            if let desVC = segue.destination as? StoryViewController{
                desVC.fairytale = fairytale
            }
        }
    }
}
