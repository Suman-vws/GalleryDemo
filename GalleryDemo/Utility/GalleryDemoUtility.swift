//
//  GalleryDemoUtility.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit


//MARK: // - - - - Constans - - - - //

//json paring keys
let imagesDataKey = "hits"
let imageIdKey = "id"
let imageTitleKey = "tags"
let imagePreviewUrlKey = "previewURL"
let imageOriginalUrlKey = "largeImageURL"
let imageSizeKey = "imageSize"

//DB Entities

let ImageDBEntity = "ImageDB"

//Folder Save Path
let thumImageFolderPath = "Thumbnails"
let originalImageFolderPath = "Large_Images"


//MARK: Get Reuse-Identifier for UITableViewCell Or, UIcolletionViewCel
protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}


//MARK: Get Nib Name

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

//MARK: Get Nib Name

protocol NibLoadableViewController: class {
    static var nibName: String { get }
}

extension NibLoadableViewController where Self: UIViewController {
    
    static var nibName: String {
        return String(describing: self)
    }
}

protocol StoryboardViewController: class {
    static var storyBoardIdentifier: String { get }
}

extension StoryboardViewController where Self: UIViewController {
    
    static var storyBoardIdentifier: String {
        return String(describing: self)
    }
}



class GalleryDemoUtility {
    
    enum CurrentDeviceType : Int {
           
           case unspecified = 0
           
           case iPhone  = 1
           case iPad  = 2
       }
    
    static func checkDeviceType() -> CurrentDeviceType{
        
        switch UIDevice.current.userInterfaceIdiom {
            
            case .phone:    // It's an iPhone
                return CurrentDeviceType.iPhone
                
            case .pad:   // It's an iPad
                return CurrentDeviceType.iPad
                
            case .unspecified: // Uh, oh! What could it be?
                return CurrentDeviceType.unspecified
                
            case .tv:
                break
            case .carPlay:
                break
            @unknown default:
                break
        }
        
        return CurrentDeviceType.unspecified
    }
    
    class func isDeviceIpad()->Bool{
        
        return checkDeviceType() == .iPad ? true : false
    }
    
    class func isDeviceIphone()->Bool{
        
        return checkDeviceType() == .iPhone ? true : false
    }
    
    class func getImageFileFromSavePath(folderPath : String, fileName : String) -> Data?{
        
        let filePathUrl = FileManager.documentDirectoryURL.appendingPathComponent("GalleryDemo/\(folderPath)/\(fileName)")
        
        if FileManager.default.fileExists(atPath: filePathUrl.path) {
            do {
                let imageData = try Data(contentsOf: filePathUrl)
                return imageData
            }
            catch {
                print(error.localizedDescription);
            }
        }
        
        return nil
    }
    
    //TODO: Change Method params as required
    class func saveImageFileInDocumentDirectory(_ imageData : Data, folderPath : String, fileName : String){
                
        let filePathUrl = FileManager.documentDirectoryURL.appendingPathComponent("GalleryDemo/\(folderPath)/\(fileName)")
        
        if !FileManager.default.fileExists(atPath: filePathUrl.path) {
            do {
                try FileManager.default.createDirectory(atPath: filePathUrl.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                
                do {
                    
                    try imageData.write(to: filePathUrl, options: .atomic)
                }
                catch {
                    print(error.localizedDescription);
                }
                
            } catch {
                NSLog("Couldn't write data")
            }
        }
    }
  
}


extension FileManager {
    
    static var documentDirectoryURL: URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectoryURL
    }
    
}
