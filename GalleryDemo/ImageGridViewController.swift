//
//  ViewController.swift
//  GalleryDemo
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class ImageGridViewController: UIViewController {

    //MARK: // - - - - Prpperties - - - - //

    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var lblNoImagesAvailable : UILabel!

    private var arrImages : [ImageModel]?

    
    //MARK: // - - - - View Life Cycle Methods - - - - //

    override func viewDidLoad() {
        
        super.viewDidLoad()
        lblNoImagesAvailable.isHidden = true
        customizeNavigationBarUI()
        customizeSearchBarUI()
        collectionView.register(ImageGridCollectionCell.self, forCellWithReuseIdentifier: ImageGridCollectionCell.defaultReuseIdentifier)
        collectionView.register(UINib.init(nibName: ImageGridCollectionCell.nibName, bundle: nil), forCellWithReuseIdentifier: ImageGridCollectionCell.defaultReuseIdentifier)
        
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [unowned self] in
            self.loadImages()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        collectionView.setContentOffset(CGPoint(x: 0.0, y: 10.0), animated: false)
    }
    
    //MARK: // - - - - Private Helpers - - - - //

    private func loadImages(){
        
        if Reachability.isConnectedToNetwork(){
            //fetch online data, perform DB Update, Fetch and reload list
            fetchOnlineImageDataAndReloadGridView { (isSuccess) in
                DispatchQueue.main.async { [unowned self] in
                    self.getLocalImagesAndReloadGridView()
                }
            }
        }else{
            
            let alert = UIAlertController(title: "Warning", message: "Internet is not available", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.show()
            getLocalImagesAndReloadGridView()
        }
    }
    
    deinit {
        
    }
    
    
    private func customizeNavigationBarUI(){
        
        self.navigationItem.title = "Photos"
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#0b7adb") // "#1e88e5"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0, weight: .bold), NSAttributedString.Key.foregroundColor : UIColor.white] as [NSAttributedString.Key : Any]
    }
    
    private func customizeSearchBarUI(){
        searchBar.tintColor = UIColor(hexString: "#0b7adb")
        searchBar.showsCancelButton = true
    }

    
    private func getLocalImagesAndReloadGridView(){
        
        let images : [ImageModel]? = CoreDataManager.sharedStore.fetchAllImages().map { (imageDB) -> ImageModel in
            let imageModel = ImageModel.generateImageModelFrom(imageDB)
            return imageModel
        }
        
        if let imageArray = images, !imageArray.isEmpty{
            arrImages = imageArray
            collectionView.reloadData()
        }
    }
    
    
    private func fetchOnlineImageDataAndReloadGridView(closure : @escaping((_ status : Bool ) -> Void)){
        
        self.view.showActivity()
        NetworkOperations.getOnlineImageData { (responseData, response, error) in
            
            DispatchQueue.main.async { [unowned self] in
                self.view.hideActivity()
            }
            
            if let _ = error{
                closure(false)
            }
            
            if let responseDict = responseData as? [String : Any], !responseDict.isEmpty{
                
                if let imageArray = responseDict[imagesDataKey] as? [Dictionary<String,Any>], !imageArray.isEmpty{
                    
                    let arrImageModel = imageArray.map({ (imageDict) -> ImageModel in
                        let imageModel = ImageModel.generateImageModelFrom(imageDict)
                        return imageModel
                    })
                    
                    CoreDataManager.sharedStore.upsertImages(arrImageModel, closure: { (status) in
                        closure(true)
                    })
                }else{
                    closure(false)
                }
                
            }else{
                closure(false)
            }
        }
    }
}


//MARK: // - - - - UICollectionViewDelegate Methods - - - - //

extension ImageGridViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    private func showNoImagesAvailableView(){
        lblNoImagesAvailable.isHidden = false
        collectionView.isHidden = true
    }
    
    private func hideNoImagesAvailableView(){
        lblNoImagesAvailable.isHidden = true
        collectionView.isHidden = false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let images = arrImages, !images.isEmpty{
            hideNoImagesAvailableView()
        }else{
            showNoImagesAvailableView()
        }
        
        return arrImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGridCollectionCell.defaultReuseIdentifier, for: indexPath) as! ImageGridCollectionCell
        
        let model = arrImages?[indexPath.row]
        cell.populateImageCellWith(model)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
        let model = arrImages?[indexPath.row]
        navigateImageDetailsViewController(model)
    }
    
    private func navigateImageDetailsViewController(_ selectedImageModel : ImageModel?){
        
        let mainStroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let imageDetailsVC = mainStroryBoard.instantiateViewController(withIdentifier: ImageDetailsViewController.storyBoardIdentifier) as! ImageDetailsViewController

        imageDetailsVC.imageModelObj = selectedImageModel
        imageDetailsVC.dismissImageDetailsCompletion = { [weak self] () in
            
            if let searchKey = self?.searchBar.text, !searchKey.isEmpty{
                self?.fetchImagesFromLocalStorageWith(searchKey)
            }else{
                self?.loadImages()
            }
        }
        
        self.navigationController?.pushViewController(imageDetailsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if GalleryDemoUtility.isDeviceIpad(){
            
            return CGSize(width: (UIScreen.main.bounds.size.width/3 - 20), height: (UIScreen.main.bounds.size.width/3 - 80))
        }else{
          
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
                return CGSize.init(width: (UIScreen.main.bounds.size.width/3 - 80), height: (UIScreen.main.bounds.size.width/3 - 100))
            }else{
                return CGSize.init(width: (UIScreen.main.bounds.size.width/2 - 20), height: (UIScreen.main.bounds.size.width/2 - 40))
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
}

extension ImageGridViewController : UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.loadImages()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchKey = searchBar.text, !searchKey.isEmpty{
            fetchImagesFromLocalStorageWith(searchKey)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearchOperations), object: nil)
        self.perform(#selector(self.performSearchOperations), with: nil, afterDelay: 0.5)
    }
    
    @objc func performSearchOperations() {
        if let searchKey = searchBar.text, !searchKey.isEmpty{
            fetchImagesFromLocalStorageWith(searchKey)
        }
    }
    
    private func fetchImagesFromLocalStorageWith(_ searchKey : String) {
        
        let images : [ImageModel]? = CoreDataManager.sharedStore.fetchAllimagesMatching(searchKey).map { (imageDB) -> ImageModel in
            let imageModel = ImageModel.generateImageModelFrom(imageDB)
            return imageModel
        }
        
        arrImages = images
        collectionView.reloadData()
    }
}



