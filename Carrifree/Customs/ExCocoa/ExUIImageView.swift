//
//  ExUIImageView.swift
//  CarrifreeDriver
//
//  Created by plattics-kwon on 2021/06/29.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension UIImageView {
    func loadImage(url: URL?, completion: (() -> Void)? = nil) {
        guard let url = url else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            completion?()
        }.resume()
    }
    
    func loadImage(url: String, completion: (() -> Void)? = nil) {
        AF.request(url).responseImage { response in
//            debugPrint(response)
//            print(response.request)
//            print(response.response)
//            debugPrint(response.resulta)

            if case .success(let image) = response.result {
                self.image = image
                completion?()
//                print("image downloaded: \(image)")
            } else {
                // alamofire는 다운로드되는 이미지를 받아오지 못하기때문에
                // 이미지가 비어있으면 기본 방식의 이미지 로드를 시도함
                self.loadImage(url: URL(string: url)) {
                    completion?()
                }
            }
        }
    }
}
