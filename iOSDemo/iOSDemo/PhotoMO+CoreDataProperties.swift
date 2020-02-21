//
//  PhotoMO+CoreDataProperties.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/19.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoMO> {
        return NSFetchRequest<PhotoMO>(entityName: "PhotoMO")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var like: Bool

}
