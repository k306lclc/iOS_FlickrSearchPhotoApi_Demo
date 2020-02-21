//
//  ImageAndTitleCell.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/15.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//

import UIKit

class ImageAndTitleCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var imageURL: URL!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var likeButton: IndexPathButton!
}
