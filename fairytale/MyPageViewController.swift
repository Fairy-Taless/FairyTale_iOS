//
//  MyPageViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/15/24.
//

import Foundation
import UIKit

class MyPageViewController: UIViewController{
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var imageWarningLabel: UILabel!
    @IBOutlet weak var voiceWarningLabel: UILabel!

    
    override func viewDidLoad() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationItem.hidesBackButton = true

        
        imageWarningLabel.isHidden = true
        voiceWarningLabel.isHidden = true
        
        let url = URL(string: "http://localhost:8080/api/user")!
        HTTPClient.shared.performRequest(url: url, method: "GET") { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data, let body = String(data: data, encoding: .utf8) {
                print(body)
                do {
                    // JSON 데이터를 딕셔너리로 디코딩
                    if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // 'code' 키에 대한 값을 추출
                        if let code = jsonDict["code"] as? String {
                            
                            if(code == "COMMON200"){
                                if let result = jsonDict["result"] as? [String: Any]{
                                    let imageUrl = result["imageUrl"] as? String
                                    if let imageUrlString = imageUrl{
                                        let imageUrlObject = URL(string: imageUrlString)!
                                        URLSession.shared.dataTask(with: imageUrlObject) { data, response, error in
                                                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                                                      let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                                                      let data = data, error == nil,
                                                      let image = UIImage(data: data)
                                                else {
                                                    print("이미지를 불러오는데 실패했습니다.")
                                                    return
                                                }
                                                
                                                DispatchQueue.main.async {
                                                    self.userImageView.image = image
                                                }
                                            }.resume()
                                    }
                                
                                    let userName = result["userName"] as! String
                                    let uploadedVoice = result["uploadedVoice"] as! Bool
                                    
                                    // UI변경
                                    DispatchQueue.main.async {
                                        if let imageUrl{
                                        }else{
                                            self.imageWarningLabel.isHidden = false
                                        }
                                        self.userNameLabel.text = userName
                                        if !uploadedVoice{
                                            self.imageWarningLabel.isHidden = false
                                        }
                                    }
                                }
                            } 
                        } else {
                            print("유저 정보를 불러오는데 실패했습니다.")
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
    }
}
