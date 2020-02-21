//
//  FeaturedVC.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/15.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class FeaturedVC: UICollectionViewController, NSFetchedResultsControllerDelegate{

    var photos = [Photo]()
    var photoLike = [PhotoLike]()
    
    var photoMO:[PhotoMO] = []
    var fetchResultController: NSFetchedResultsController<PhotoMO>!
    
    var searchText = ""
    var perPage = ""
    var apiKey = ""
    var page = 0
    
    func downloadData(text: String, perPage: String, page: Int){
        let count = Int(perPage) ?? 0
        var newPhotosLike = [PhotoLike]()
        newPhotosLike.removeAll()
        for _ in 0..<count{
            let newPhotoLike = PhotoLike()
            newPhotosLike.append(newPhotoLike)
        }
        self.photoLike = newPhotosLike
        
        let str: String = "https://www.flickr.com/services/rest/"
        let queryItem1 = URLQueryItem(name: "method", value: "flickr.photos.search")
        let queryItem2 = URLQueryItem(name: "api_key", value: "\(apiKey)")//859b051eae75a311a96a2f04c7e71118
        let queryItem3 = URLQueryItem(name: "text", value: text)
        let queryItem4 = URLQueryItem(name: "per_page", value: perPage)
        let queryItem5 = URLQueryItem(name: "page", value: "\(page)")
        let queryItem6 = URLQueryItem(name: "format", value: "json")
        let queryItem7 = URLQueryItem(name: "nojsoncallback", value: "1")
        var urlCom = URLComponents(string: str)
        urlCom?.queryItems = [queryItem1,queryItem2,queryItem3,queryItem4,queryItem5,queryItem6,queryItem7]
        
        if let url = urlCom?.url{
            let request = NSMutableURLRequest(url: url)//
            request.httpMethod = "Get"
            request.timeoutInterval = 5.0
            print("urlCom:\(String(describing: urlCom))")
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response,error) in
                if error != nil{
                    
                }else{
                    if let data = data,let searchData = try? JSONDecoder().decode(SearchData.self, from: data) {
                        self.photos = searchData.photos.photo
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.searchCoreData()
                        }
                    }
                }
            })
            task.resume()
        }else{
            print("url error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchCoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "搜尋結果 \(searchText)"
        
        let backButton = UIBarButtonItem()
        backButton.title = "搜尋輸入頁"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        downloadData(text: searchText, perPage: perPage, page: 1)
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let width = (view.bounds.width - 10) / 2
        let height = CGFloat(180)
        layout?.itemSize = CGSize(width: width, height: height)
    }

    
    @objc func likePhoto(sender: IndexPathButton){
        let row = sender.tag
        let indexPath = sender.indexPath
        photoLike[row].like = !photoLike[row].like
        
        if(photoLike[row].like == true){
            var photo:PhotoMO!
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
                photo = PhotoMO(context: appDelegate.persistentContainer.viewContext)
                photo.title = self.photos[row].title
                photo.like = self.photoLike[row].like
                photo.imageUrl = self.photos[row].imageUrl.path
                NetworkUtility.downloadImage(url: self.photos[row].imageUrl) { (image) in
                    if let image = image  {
                        photo.image = UIImage.pngData(image)() as NSData?
                    }
                }
                print("Save data to context ...")
                appDelegate.saveContext()
                self.collectionView.reloadItems(at: [indexPath])
            }
        }else{
            var photo:[PhotoMO] = []
            let deletePhotoAtPhotos = self.photos[row]
            let fetchRequest: NSFetchRequest<PhotoMO> = PhotoMO.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchResultController.delegate = self
                do {
                    try fetchResultController.performFetch()
                    if let fetchedObjects = fetchResultController.fetchedObjects{
                        photo = fetchedObjects
                        
                        var deletePhoto = PhotoMO()
                        for i in 0..<photo.count{
                            let dataImageUrl = photo[i].imageUrl ?? ""
                            let deletePhotoAtPhotosImageUrl = deletePhotoAtPhotos.imageUrl.path
                            if(dataImageUrl == deletePhotoAtPhotosImageUrl){
                                deletePhoto = photo[i]
                            }
                        }
                        context.delete(deletePhoto)
                        appDelegate.saveContext()
                    }
                } catch {
                    print(error)
                }
            }
            
            if(self.photoMO.count == 0){
                print("photoMO.count: 0")
            }
            self.photoLike[row].like = false
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func searchCoreData(){
        let fetchRequest: NSFetchRequest<PhotoMO> = PhotoMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects{
                    photoMO = fetchedObjects
                    if(photoMO.count == 0){
                        print("photoMO.count: 0")
                        for i in 0..<photos.count{
                            photoLike[i].like = false
                        }
                    }else{
                        print("photoMO.count: \(photoMO.count)")
                        let photosCount = photos.count
                        for i in 0..<photosCount{
                            let urlString = photos[i].imageUrl.path
                            var find = false
                            for j in 0..<photoMO.count{
                                if(find == false){
                                    let imageUrl = photoMO[j].imageUrl ?? ""
                                    if(urlString == imageUrl){
                                        find = true
                                        photoLike[i].like = true
                                    }else{
                                        photoLike[i].like = false
                                    }
                                }
                            }
                        }
                    }
                    collectionView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (photos.count * 1000)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageAndTitleCell
        var row = indexPath.row
        while (row >= Int(perPage) ?? 0){
            row = row % (Int(perPage) ?? 0)
        }
        let photo = photos[row]
        
        cell.title.text = photo.title
        cell.imageView.image = nil
        cell.imageURL = photo.imageUrl
        
        let photoL = photoLike[row]
        if(photoL.like == false){
            cell.likeButton.setTitle("♡", for: .normal)
            cell.likeButton.setTitleColor(UIColor.black, for: .normal)
        }else{
            cell.likeButton.setTitle("♥️", for: .normal)
            cell.likeButton.setTitleColor(UIColor.red, for: .normal)
        }
        cell.likeButton.tag = row
        cell.likeButton.indexPath = indexPath
        cell.likeButton.addTarget(self, action: #selector(likePhoto), for: .touchUpInside)
        
        if(cell.imageURL != nil){
            NetworkUtility.downloadImage(url: cell.imageURL) { (image) in
                if cell.imageURL == photo.imageUrl, let image = image  {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
