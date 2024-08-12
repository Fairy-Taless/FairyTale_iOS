//
//  VoiceUploadViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/15/24.
//

import Foundation
import UIKit
import AVFoundation

class VoiceUploadViewController: UIViewController, AVAudioRecorderDelegate{
    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder?
    var recoding = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        promptView.layer.cornerRadius = 10
        promptView.layer.masksToBounds = true
        
        promptView.layer.borderWidth = 2
        promptView.layer.borderColor = UIColor.systemBlue.cgColor
        
        promptLabel.font = UIFont(name: "Jua-Regular", size: 19)
        recordButton.imageView?.contentMode = .scaleAspectFill
        
        // 음성 녹음 설정
        setupRecorder()
        
        // 버튼 이미지 변경
        if let originalImage = UIImage(named: "record_black"),
           let resizedImage = originalImage.resized(to: recordButton.frame.size) {
            recordButton.setImage(resizedImage, for: .normal)
        }
    }
    
    //음성 녹음 설정
    func setupRecorder() {
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("voiceAudio.m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // m4a
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.prepareToRecord()
            } catch {
                print("오디오 녹음 설정에 실패했습니다. \(error)")
            }
        }
    
    
    // 음성 녹음
    @IBAction func recordVoice(_ sender: UIButton) {
        if(recoding){
            if let originalImage = UIImage(named: "record_black"),
               let resizedImage = originalImage.resized(to: recordButton.frame.size) {
                recordButton.setImage(resizedImage, for: .normal)
            }
            audioRecorder?.record()
            
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("voiceAudio.m4a")
            
            do {
                let fileData = try Data(contentsOf: audioFilename)
                
                let url = URL(string: "http://localhost:8080/api/voice")!
                HTTPClient.shared.performMultipartRequest(url: url, method: "POST", parameters: [:], data: fileData, mimeType: "audio/mp4", filename: "voiceAudio.m4a", keyName: "sample"){
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
                                            let alert = UIAlertController(title: "음성 업로드", message: "음성 업로드에 성공했습니다.", preferredStyle: .alert)
                                                    
                                            self.present(alert, animated: true, completion: nil)

                                            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
                                        }
                                    }else{
                                        DispatchQueue.main.async{
                                            let alert = UIAlertController(title: "음성 업로드", message: "음성 업로드에 성공했습니다.", preferredStyle: .alert)
                                            
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
            } catch {
                print("음성 파일을 불러오는데 실패했습니다.: \(error)")
            }
            
            
        }
        else{
            if let originalImage = UIImage(named: "record_red"),
               let resizedImage = originalImage.resized(to: recordButton.frame.size) {
                recordButton.setImage(resizedImage, for: .normal)
            }
            audioRecorder?.stop()
            
        }
        recoding = !recoding
    }
    
}

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
