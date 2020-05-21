//
//  ImageDetailsViewController.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController, StoryboardViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var activityIndicatorVw : UIActivityIndicatorView!

    var dismissImageDetailsCompletion : (() -> Void)?
    var imageModelObj : ImageModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorVw.hidesWhenStopped = true
        customizeNavigationBar()
        
        if let data = GalleryDemoUtility.getImageFileFromSavePath(folderPath: originalImageFolderPath, fileName: (self.imageModelObj?.imageId)!) {
            
            if let image =  UIImage(data: data){
                imageView.image = image
            }else{
                imageView.image = UIImage(named: "default_image")
            }
        }else{
            if let url = URL(string: imageModelObj!.strOriginalUrl){
                downloadImage(from: url, imageView: imageView)
            }
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        
        if parent == nil {
            dismissImageDetailsCompletion?()
        }
    }
    
    deinit {
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func customizeNavigationBar(){
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = (imageModelObj?.title)! + " (" + (imageModelObj?.size)! + " )"
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
                GalleryDemoUtility.saveImageFileInDocumentDirectory(data, folderPath: originalImageFolderPath, fileName: (self?.imageModelObj?.imageId)!)
                
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
