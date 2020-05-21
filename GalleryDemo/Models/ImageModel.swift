//
//  ImageModel.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation


struct ImageModel {
    
    var imageId : String!
    var title : String!
    var size : String!
    var strThumbUrl : String!
    var strOriginalUrl : String!
    var thumbnailSavePath : String?
    var originalImageSavePath : String?
    
    init() {
        //customize imnitialization if required
    }
    
    
    static func generateImageModelFrom(_ imageDBObj : ImageDB?) -> ImageModel{
        
        var imageModelObj = ImageModel()
        
        imageModelObj.imageId = imageDBObj?.imageId
        imageModelObj.title = imageDBObj?.title
        imageModelObj.size = imageDBObj?.size
        imageModelObj.strThumbUrl = imageDBObj?.strPreviewUrl
        imageModelObj.strOriginalUrl = imageDBObj?.strOriginalUrl
        imageModelObj.thumbnailSavePath = imageDBObj?.thumbnailSavepath
        imageModelObj.originalImageSavePath = imageDBObj?.originalSavePath
        
        return imageModelObj
        
    }
    
    static func generateImageModelFrom(_ jsonImageDict : [String : Any]) -> ImageModel{
        
        var imageModelObj = ImageModel()
        
        imageModelObj.title = jsonImageDict[imageTitleKey] as? String

        if let id = jsonImageDict[imageIdKey] as? Int64{
            imageModelObj.imageId = "\(id)"
        }

        if let size = jsonImageDict[imageSizeKey] as? Int64{
            imageModelObj.size = "\(size)"
        }
        
        imageModelObj.strThumbUrl = jsonImageDict[imagePreviewUrlKey] as? String
        imageModelObj.strOriginalUrl = jsonImageDict[imageOriginalUrlKey] as? String
        
        
        return imageModelObj
        
    }
    
}


