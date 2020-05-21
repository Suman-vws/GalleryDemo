//
//  ImageGridCollectionCell.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit

class ImageGridCollectionCell : UICollectionViewCell, NibLoadableView, ReusableView {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var imageTitlelabel : UILabel!
    @IBOutlet weak var containerView : UIView!
    
    @IBOutlet weak var activityIndicatorVw : UIActivityIndicatorView!
    

    private var modelObj : ImageModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorVw.hidesWhenStopped = true
        if GalleryDemoUtility.isDeviceIpad(){
            imageTitlelabel.font = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        }
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.darkText.cgColor
        containerView.layer.cornerRadius = 4.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func populateImageCellWith(_ imageModel : ImageModel?){
        
        modelObj = imageModel
        imageTitlelabel.text = imageModel?.title
        imageTitlelabel.textAlignment = .center
        
        if let data = GalleryDemoUtility.getImageFileFromSavePath(folderPath: thumImageFolderPath, fileName: (self.modelObj?.imageId)!) {
            
            if let image =  UIImage(data: data){
                imageView.image = image
            }else{
                imageView.image = UIImage(named: "default_image")
            }
        }else{
            if let url = URL(string: imageModel!.strThumbUrl){
                downloadImage(from: url, imageView: imageView)
            }
        }
    }
    
    
    private func downloadImage(from url: URL, imageView : UIImageView) {

//        imageView.showActivity()
        activityIndicatorVw.startAnimating()
        getData(from: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async() {
//                    imageView.hideActivity()
                    self?.activityIndicatorVw.stopAnimating()
                    imageView.image = UIImage(named: "default_image")
                }
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
//                imageView.hideActivity()
                self?.activityIndicatorVw.stopAnimating()
                //writes data
                GalleryDemoUtility.saveImageFileInDocumentDirectory(data, folderPath: thumImageFolderPath, fileName: (self?.modelObj?.imageId)!)
                
                if let image =  UIImage(data: data){
                    imageView.image = image
                }else{
                    imageView.image = UIImage(named: "default_image")
                }
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
