//
//  NetworkUtility.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/16.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//

import UIKit

struct NetworkUtility {
    static func downloadImage(url: URL, handler: @escaping (UIImage?) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                handler(image)
            } else {
                handler(nil)
            }
        }
        task.resume()
    }
}
