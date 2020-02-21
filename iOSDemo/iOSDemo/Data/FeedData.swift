//
//  FeedData.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/14.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//

import Foundation
struct Media: Decodable {
    let m: URL
}
struct Item: Decodable {
    let title: String
    let media: Media
}
struct FeedData: Decodable {
    let items: [Item]
}
struct PhotoLike {
    var like:Bool!
    init(){
        like = false
    }
}
