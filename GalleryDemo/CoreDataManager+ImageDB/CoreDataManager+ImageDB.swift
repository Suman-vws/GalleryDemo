//
//  CoreDataManager+ImageDB.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataManager {
    
    private func setValueForImageDB(from imageModelObj : ImageModel, imageDBObject : ImageDB) {

        imageDBObject.appId = "imageGallery_Demo" //static idetifier
        imageDBObject.imageId = imageModelObj.imageId
        imageDBObject.title = imageModelObj.title
        imageDBObject.size = imageModelObj.size
        imageDBObject.strPreviewUrl = imageModelObj.strThumbUrl
        imageDBObject.strOriginalUrl = imageModelObj.strOriginalUrl
        imageDBObject.thumbnailSavepath = imageModelObj.thumbnailSavePath
        imageDBObject.originalSavePath = imageModelObj.originalImageSavePath
    }
    
    
    private func upsertImageDetails(_ imageModelObj : ImageModel, imageContext : NSManagedObjectContext) {
        
        var imageDb : ImageDB?
        
//        let imageContext = CoreDataManager.sharedStore.fetchPrivateContext()
        let imagePredicate : NSPredicate = NSPredicate(format: "imageId = %@", imageModelObj.imageId)
        
        let resultArr : NSArray = self.fetchManageObjectForEnity(enityName: ImageDBEntity as NSString,predicate: imagePredicate , currentContex: imageContext)
        
        if resultArr.count > 0 {
            imageDb = resultArr.firstObject as? ImageDB
        }else{
            let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ImageDBEntity , in: imageContext)!
            imageDb = ImageDB(entity: entity, insertInto: imageContext)
        }
        
        setValueForImageDB(from: imageModelObj, imageDBObject: imageDb!)
    }
    
    func upsertImages(_ imageList : [ImageModel], closure : @escaping((_ status : Bool ) -> Void)) -> Void{
        
        let imageContext = fetchMainContext()
        imageContext.perform { [unowned self] in
            for imageModel in imageList {
              self.upsertImageDetails(imageModel, imageContext: imageContext)
            }
            imageContext.saveContextToStore({ _ in
                closure(true)
            })
        }
    }

    
    func fetchAllImages() -> [ImageDB?] {
        
        let moc: NSManagedObjectContext = fetchMainContext()
        let applicationId = "imageGallery_Demo"

        let imagePredicate : NSPredicate = NSPredicate(format: "appId = %@", applicationId)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)

        return self.fetchManageObjectForEnity(enityName: ImageDBEntity as NSString, predicate: imagePredicate, descriptorArray: [sortDescriptor], currentContex: moc) as! [ImageDB]
    }
    
    
    func fetchAllimagesMatching(_ searchKey : String) -> [ImageDB?] {
        
        let searchContext: NSManagedObjectContext = fetchMainContext()
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Any name CONTAINS[cd] %@",token];
        let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchKey)
        return self.fetchManageObjectForEnity(enityName: ImageDBEntity as NSString, predicate: searchPredicate, currentContex: searchContext) as! [ImageDB]
    }
}
