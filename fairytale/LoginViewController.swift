//
//  ViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/3/24.
//
import TextFieldEffects
import UIKit

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class LoginViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var loginIdTextField: HoshiTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        logoImageView.layer.cornerRadius = 10
        
        loginButton.layer.cornerRadius = 10
        passwordTextField.isSecureTextEntry = true
        

        subTitleLabel.font = UIFont(name: "Jua-Regular", size: 17)
        // Do any additional setup after loading the view.
    }


    @IBAction func login(_ sender: UIButton) {
        let loginId = loginIdTextField.text
        let password = passwordTextField.text
        let data = ["loginId": loginId, "password": password]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: data) else{
            print("바디 직렬화에 실패했습니다.")
            return
        }
        
        let url = URL(string: "http://localhost:8080/login")!
        HTTPClient.shared.performRequest(url: url, method: "POST", body: httpBody) { data, response, error in
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
                            if(code == "COMMON400"){
                                // UI변경
                                DispatchQueue.main.async {
                                    // 예: 에러 메시지를 라벨에 표시
                                    self.errorLabel.text = "아이디와 비밀번호를 다시 확인해주세요."
                                }
                            }else{
                                if let httpResponse = response as? HTTPURLResponse {
                                        let headers = httpResponse.allHeaderFields
                                        
                                        if let jwtToken = headers["Authorization"] as? String {
                                            UserDefaults.standard.set(jwtToken, forKey: "jwtToken")
                                            UserDefaults.standard.synchronize()
                                    }
                                }else{
                                    print("JWT token 헤더 추출에 실패했습니다.")
                                    return;
                                }
                                
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "mainPage", sender: self)
                                }
                            }
                        } else {
                            print("알 수 없는 코드키 입니다.")
                        }
                    }
                } catch {
                    print("JSON 변환 도중 오류가 발생했습니다. : \(error)")
                }
            }
        }
    }
}

