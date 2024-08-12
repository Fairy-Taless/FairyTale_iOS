//
//  StoryViewController.swift
//  fairytale
//
//  Created by 김준하 on 6/16/24.
//

import Foundation
import UIKit
import AVFoundation

class StoryViewController: UIViewController{
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var storyUIView: UIView!
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var titleView: UILabel!
    var fairytale: Fairytale?
    var result: ResultData?
    var audioPlayer: AVPlayer?
    var curPage = 1
    var images: [UIImage]?
    var selectedLabel: UILabel?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
        
    override func viewDidLoad() {
        titleView.layer.cornerRadius = 10
        storyUIView.layer.cornerRadius = 10
        storyUIView.layer.borderWidth = 3
        storyUIView.layer.borderColor = UIColor.systemGray.cgColor
        storyTitleLabel.text = fairytale?.name
        storyImageView.layer.cornerRadius = 20
        
        if let curFairytaleId = fairytale?.fairytaleId{
            let url = URL(string: "http://localhost:8080/api/fairytale/\(curFairytaleId)?change_voice=true&change_face=true")!
            HTTPClient.shared.performRequest(url: url, method: "GET") { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
            
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print(body)
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(Response.self, from: data)
                        self.result = response.result
                        
                        response.result.pages.forEach { (key: String, value: PageData) in
                            let imageUrlObject = URL(string: value.imageUrl)!
                            URLSession.shared.dataTask(with: imageUrlObject) { data, response, error in
                                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                                let data = data, error == nil,
                                let image = UIImage(data: data)
                                else {
                                    print("이미지를 불러오는데 실패했습니다.")
                                    return
                                }
                                self.images?.append(image)
                            }.resume()
                        }
                       
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                DispatchQueue.main.async{
                    self.reloadData()
                }
            }
        }
    }
    
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        completion(UIImage(data: data))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        }
    
    
    func reloadData() {
        if curPage == 1{
            leftButton.isHidden = true
        }
        else{
            leftButton.isHidden = false
        }
        
        if curPage == result?.pages.count{
            rightButton.isHidden = true
        }
        else{
            rightButton.isHidden = false
        }
        
        
        
        if let voiceData = result?.pages[String(curPage)]?.voiceList{
            addLabels(for: voiceData)
        }
        if let image = images?[curPage - 1]{
            storyImageView.image = image
        }else{
            if let curImageUrl = result?.pages[String(curPage)]?.imageUrl{
                addImage(from: curImageUrl)
            }
        }
        
    }

    
    func addLabels(for voiceList: [VoiceData]) {
        let removedSubviews = labelStackView.arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            labelStackView.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        removedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, voiceData) in voiceList.enumerated() {
            let label = UILabel()
            label.text = voiceData.content
            label.textColor = .black
            label.isUserInteractionEnabled = true
            label.tag = index
            label.font = UIFont(name: "Jua-Regular", size: 20)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setLineSpacing(lineSpacing: 5)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            labelStackView.addArrangedSubview(label)
        }
    }

        @objc func labelTapped(_ sender: UITapGestureRecognizer) {
            if let label = sender.view as? UILabel {
                selectedLabel = label
                for subview in labelStackView.arrangedSubviews {
                                if let otherLabel = subview as? UILabel {
                                    otherLabel.isUserInteractionEnabled = false
                                }
                            }
                let index = label.tag
                label.textColor = .systemBlue
                if let voiceUrl = result?.pages[String(curPage)]?.voiceList[index].audioUrl{
                    playAudio(from: voiceUrl, label: label)
                }
            }
        }
    
    func addImage(from imageUrl: String) {
            downloadImage(from: imageUrl) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.storyImageView.image = image
                }
            }
        }
    
    func playAudio(from url: String, label: UILabel) {
           guard let audioUrl = URL(string: url) else {
               print("음성 파일의 URL이 올바르지 않습니다.")
               return
           }


        let playerItem = AVPlayerItem(url: audioUrl)
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

                audioPlayer = AVPlayer(playerItem: playerItem)
                audioPlayer?.play()
       }
    
    @objc func playerDidFinishPlaying(notification: NSNotification) {
            selectedLabel?.textColor = .black
            selectedLabel = nil
            for subview in labelStackView.arrangedSubviews {
                        if let otherLabel = subview as? UILabel {
                            otherLabel.isUserInteractionEnabled = true
                        }
                    }
        }
    
    @IBAction func beforePage(_ sender: UIButton) {
        curPage -= 1
        reloadData()
    }
    
    @IBAction func nextPage(_ sender: UIButton) {
        curPage += 1
        reloadData()
    }
}

struct PageData: Codable {
    let voiceList: [VoiceData]
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case voiceList = "voice_list"
        case imageUrl = "image_url"
    }
}

struct VoiceData: Codable {
    let audioUrl: String
    let content: String
    let segmentId: Int
}

struct ResultData: Codable {
    var pages: [String: PageData]

    init(from decoder: Decoder) throws {
        struct DynamicKey: CodingKey {
            var stringValue: String
            var intValue: Int?

            init?(stringValue: String) {
                self.stringValue = stringValue
                self.intValue = nil
            }

            init?(intValue: Int) {
                self.intValue = intValue
                self.stringValue = "\(intValue)"
            }
        }
        let container = try decoder.container(keyedBy: DynamicKey.self)
        var pages = [String: PageData]()

        for key in container.allKeys {
            let pageData = try container.decode(PageData.self, forKey: key)
            pages[key.stringValue] = pageData
        }
        self.pages = pages
    }

    private enum CodingKeys: CodingKey {}
}

struct Response: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ResultData
}

extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString: NSMutableAttributedString
        if let labelAttributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        self.attributedText = attributedString
    }
}
