//
//  MainViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/14/24.
//

import Foundation
import UIKit

class MainViewController: UIViewController{

    
    @IBOutlet weak var fairytaleCollectionView: UICollectionView!
    
    @IBOutlet weak var titleView: UIView!
    var fairytales: [fairytale.Fairytale] = []
    var previewImages: [Int64: UIImage] = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationItem.hidesBackButton = true
        
    }
    
    override func viewDidLoad() {
        
        titleView.layer.cornerRadius = 5
            let url = URL(string: "http://localhost:8080/api/fairytale")!
            HTTPClient.shared.performRequest(url: url, method: "GET") { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print(body)
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(APIResponse.self, from: data)
                        
                        DispatchQueue.main.async {
                                            self.fairytales = response.result.map { result in
                                                return Fairytale(fairytaleId: result.fairytaleId, mainImageUrl: result.mainImageUrl, name: result.name)
                                            }
                                            self.fairytaleCollectionView.reloadData()
                                        }
                    } catch {
                        print("JSON 디코딩 실패: \(error)")
                    }
                }
            }
        
        fairytaleCollectionView.dataSource = self
        fairytaleCollectionView.delegate = self
        
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.fairytales.count)
        return self.fairytales.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fairytaleCell", for: indexPath) as! CustomCollectionViewCell
        let fairytale = fairytales[indexPath.item]
        cell.cellContentView.layer.cornerRadius = 5
        cell.cellContentView.layer.borderColor = UIColor.systemGray.cgColor
        cell.cellContentView.layer.borderWidth = 2
     

        let imageUrlObject = URL(string: fairytale.mainImageUrl)!
        URLSession.shared.dataTask(with: imageUrlObject) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let image = UIImage(data: data)
            else {
                print("이미지를 불러오는데 실패했습니다.")
                return
            }
            DispatchQueue.main.async{
                cell.fairytaleImageView.contentMode = .scaleAspectFill
                cell.fairytaleImageView.image = image
                self.previewImages[fairytale.fairytaleId] = image
                cell.fairytaleNameLabel.text = self.fairytales[indexPath.row].name
            }
        }.resume()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fairytaleModal", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "fairytaleModal" {
                if let indexPath = sender as? IndexPath{
                    let selectedFairytale = fairytales[indexPath.item]
                    if let destinationVC = segue.destination as? FairytaleModalViewController {
                        destinationVC.fairytale = selectedFairytale
                        destinationVC.previewImage = previewImages[selectedFairytale.fairytaleId]
                    }
                }
            }
        }


}

class CustomCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var fairytaleImageView: UIImageView!
    @IBOutlet weak var fairytaleNameLabel: UILabel!
}
