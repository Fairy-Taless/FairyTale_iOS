//
//  SignupViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/9/24.
//
import UIKit
import Foundation

class SignupViewController: UIViewController{
    
    @IBOutlet weak var signupLabel: UILabel!
    
    @IBOutlet weak var genderFemaleButton: UIButton!
    @IBOutlet weak var genderMaleButton: UIButton!
    @IBOutlet weak var userNameErrorLabel: UILabel!
    @IBOutlet weak var loginIdErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginIdTextField: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var passwordCheckLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordCheckTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loginIdLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupErrorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        signupLabel?.font = UIFont(name: "Jua-Regular", size: 24)
        userNameErrorLabel?.isHidden = true
        loginIdErrorLabel?.isHidden = true
        signupErrorLabel?.isHidden = true
        signupLabel?.textColor = .tintColor
        signupButton.layer.cornerRadius = 10
        genderFemaleButton.layer.cornerRadius = 5
        genderMaleButton.layer.cornerRadius = 5
        passwordTextField.isSecureTextEntry = true
        passwordCheckTextField.isSecureTextEntry = true
    }
    
    
    
    @IBAction func loginIdCheck(_ sender: UIButton) {
        if loginIdTextField.text == "" {
            loginIdErrorLabel.text = "사용할 수 없는 아이디 입니다."
            loginIdErrorLabel.textColor = .systemRed
            loginIdErrorLabel.isHidden = false
        }
        else{
            loginIdErrorLabel.text = "사용할 수 있는 아이디 입니다."
            loginIdErrorLabel.textColor = .systemGreen
            loginIdErrorLabel.isHidden = false
        }
    }
    
    @IBAction func userNameCheck(_ sender: UIButton) {
        if userNameTextField.text == "" {
            userNameErrorLabel.text = "사용할 수 없는 닉네임 입니다."
            userNameErrorLabel.textColor = .systemRed
            userNameErrorLabel.isHidden = false
        }
        else{
            userNameErrorLabel.text = "사용할 수 있는 닉네임 입니다."
            userNameErrorLabel.textColor = .systemGreen
            userNameErrorLabel.isHidden = false
        }
    }
    
    
    @IBAction func selectGender(_ sender: UIButton) {
        genderMaleButton.isSelected = false
        
        genderMaleButton.backgroundColor = .white
        genderMaleButton.tintColor = .tintColor
        
        genderFemaleButton.isSelected = false
        genderFemaleButton.tintColor = .tintColor
        genderFemaleButton.backgroundColor = .white
        
        sender.isSelected = true
        sender.backgroundColor = .systemBlue
        sender.tintColor = .white
    }
    
    @IBAction func signup(_ sender: UIButton) {
        if(genderMaleButton.isSelected || genderFemaleButton.isSelected){
            let gender = genderMaleButton.isSelected ? "MALE" : "FEMALE"
            self.signupRequest(loginIdTextField.text!, passwordTextField.text!, userNameTextField.text!, gender)
        }else{
            signupErrorLabel.text = "성별을 선택해주세요."
            signupErrorLabel.textColor = .systemRed
            signupErrorLabel.isHidden = false
        }
    }
}


extension SignupViewController{
    func signupRequest(_ loginId: String, _ password: String, _ userName: String, _ gender: String) {
        let data = ["loginId": loginId, "password": password, "username": userName, "gender": gender]
        
        guard let body = try? JSONSerialization.data(withJSONObject: data) else{
            print("바디 직렬화에 실패했습니다.")
            self.signupErrorLabel.text = "회원가입에 실패했습니다."
            self.signupErrorLabel.textColor = .systemRed
            self.signupErrorLabel.isHidden = false
            return
        }
        
        let url = URL(string: "http://localhost:8080/api/user/signup")!
        HTTPClient.shared.performRequest(url: url, method: "POST", body: body){
            data, response, error in
            if let error = error{
                DispatchQueue.main.async{
                    self.signupErrorLabel.text = "회원가입에 실패했습니다."
                    self.signupErrorLabel.textColor = .systemRed
                    self.signupErrorLabel.isHidden = false
                }
                return
            }
            if let data = data, let body = String(data: data, encoding: .utf8){
                print(body)
                do{
                    if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                        if let code = jsonDict["code"] as? String{
                            if(code == "COMMON200"){
                                DispatchQueue.main.async{
                                    self.performSegue(withIdentifier: "signupPopup", sender: self)
                                }
                            }
                            else{
                                DispatchQueue.main.async{
                                    self.signupErrorLabel.text = "회원가입에 실패했습니다."
                                    self.signupErrorLabel.textColor = .systemRed
                                    self.signupErrorLabel.isHidden = false
                                }
                            }
                        }
                    }
                } catch {
                    print("Json 역직렬화 중 오류가 발생했습니다. Error = \(error)")
                }
            }
        }
    }
}
