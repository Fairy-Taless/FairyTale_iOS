//
//  ImageUploadViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/15/24.
//

import Foundation
import UIKit

class ImageUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.masksToBounds = true
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
    }
    @IBAction func getImageByAlbum(_ sender: UIButton) {
        showImagePicker()
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary  // 앨범에서 이미지를 가져오기 위해
        imagePicker.mediaTypes = ["public.image"]  // 이미지만 가져오기
        imagePicker.allowsEditing = false  // 편집 허용 여부

        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImageView.image = pickedImage
            if let image = userImageView.image{
                if let imageData = image.jpegData(compressionQuality: 1.0){
                    let url = URL(string: "http://localhost:8080/faceSwap/uploadImg")!
                    HTTPClient.shared.performMultipartRequest(url: url, method: "POST", parameters: [:], data: imageData, mimeType: "image/jpeg", filename: "faceImage.jpeg", keyName: "file"){
                        data, response, error in
                        if let error = error{
                            print("Error: \(error)")
                            return
                        }
                        
                        if let data = data, let body = String(data: data, encoding: .utf8){
                            print(body)
                            do {
                                // JSON 데이터를 딕셔너리로 디코딩
                                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    // 'code' 키에 대한 값을 추출
                                    if let code = jsonDict["code"] as? String {
                                        if(code == "COMMON200"){
                                            DispatchQueue.main.async{
                                                let alert = UIAlertController(title: "이미지 업로드", message: "이미지 업로드에 성공했습니다.", preferredStyle: .alert)
                                                        
                                                self.present(alert, animated: true, completion: nil)

                                                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
                                            }
                                        }else{
                                            DispatchQueue.main.async{
                                                let alert = UIAlertController(title: "이미지 업로드", message: "이미지 업로드에 실패했습니다.", preferredStyle: .alert)
                                                
                                                self.present(alert, animated: true, completion: nil)
                                                
                                                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
                                            }
                                           
                                        }
                                    } else {
                                        print("코드 키 추출에 실패했습니다.")
                                    }
                                }
                            } catch {
                                print("JSON 변환 중 오류가 발생했습니다.: \(error)")
                            }
                        }
                    }
                }
            }
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
