//
//  ImageDB+CoreDataProperties.swift
//  GalleryDemo
//
//  Created by SARAT CHANDRA HAZRA on 21/05/20.
//  Copyright © 2020 Admin. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageDB> {
        return NSFetchRequest<ImageDB>(entityName: "ImageDB")
    }

    @NSManaged public var originalSavePath: String?
    @NSManaged public var size: String?
    @NSManaged public var strOriginalUrl: String?
    @NSManaged public var strPreviewUrl: String?
    @NSManaged public var thumbnailSavepath: String?
    @NSManaged public var title: String?
    @NSManaged public var imageId: String?
    @NSManaged public var appId: String?

}
