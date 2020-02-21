//
//  FavoritesVC.swift
//  iOSDemo
//
//  Created by KevinLin on 2020/2/19.
//  Copyright © 2020 UnProKevinLin. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class FavoritesVC: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var photoMO:[PhotoMO] = []
    
    var fetchResultController: NSFetchedResultsController<PhotoMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let width = (view.bounds.width - 10) / 2
        let height = CGFloat(180)
        layout?.itemSize = CGSize(width: width, height: height)
    }
    
    func getCoreData(){
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
                        simpleHint()
                        print("photoMO.count: 0")
                    }else{
                        print("photoMO.count: \(photoMO.count)")
                    }
                    collectionView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCoreData()
    }
    
    @objc func likePhoto(sender: IndexPathButton){
        let indexPath = sender.indexPath
        DispatchQueue.main.async(execute: { () -> Void in
            //從資料儲存區刪除一列
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let deletePhoto = self.fetchResultController.object(at: indexPath)
                context.delete(deletePhoto)
                
                appDelegate.saveContext()
            }
            
            self.getCoreData()
            
            if(self.photoMO.count == 0){
                print("photoMO.count: 0")
            }
        })
    }

    func simpleHint() {
        let alertController = UIAlertController( title: "提示", message: "目前沒有收藏的照片", preferredStyle: .alert)
        
        let okAction = UIAlertAction( title: "確認", style: .default, handler: { (action: UIAlertAction!) -> Void in
            print("按下確認後 ...")
        })
        alertController.addAction(okAction)
        
        self.present( alertController, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoMO.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageAndTitleCell
        let row = indexPath.row
        
        if(row > (photoMO.count - 1)){
            return cell
        }
        
        let photo = photoMO[row]
        
        cell.title.text = photo.title
        
        
        if(photo.like == false){
            cell.likeButton.setTitle("♡", for: .normal)
            cell.likeButton.setTitleColor(UIColor.black, for: .normal)
        }else{
            cell.likeButton.setTitle("♥️", for: .normal)
            cell.likeButton.setTitleColor(UIColor.red, for: .normal)
        }
        cell.likeButton.tag = row
        cell.likeButton.indexPath = indexPath
        cell.likeButton.addTarget(self, action: #selector(likePhoto), for: .touchUpInside)
        
        if(photo.image != nil){
            guard let image = UIImage(data: photo.image! as Data) else {
                cell.imageView.image = nil
                return cell
            }
            cell.imageView.image = image
        }else{
            guard let url = URL(string: photo.imageUrl ?? "") else {
                cell.imageView.image = nil
                return cell
            }
            NetworkUtility.downloadImage(url: url) { (image) in
                if let image = image  {
                    cell.imageView.image = image
                    collectionView.reloadItems(at: [indexPath])
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
