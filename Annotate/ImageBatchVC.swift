//
//  ImageBatchVC.swift
//  Annotate
//
//  Created by David Lang on 7/3/19.
//  Copyright © 2019 David Lang. All rights reserved.
//


// https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=e79e37db8c17fb8f7b009ea28a20cb4c&tags=bees&format=rest

import UIKit
import CoreData
import Kingfisher

class ImageBatchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var flickrSearchResult: FlickrSearchResult?
    var imagerUrls: [URL]?
    var photoResultsController:NSFetchedResultsController<Photo>!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var pages = 0
    var urlCount = 0
    var tag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Flickr.requestImageResources(tag: "bee", pageNumber: 0) { (flickrSearchResult, error) in
            guard error == nil, let flickrSearchResult = flickrSearchResult else {
                print("RIRL error", error)
                return
            }
            self.flickrSearchResult = flickrSearchResult
            DispatchQueue.main.async {
                self.urlCount = 5
                self.collectionView.reloadData()

            }
            //self.collectionView.reloadData()
        }
    }
    
    func requestImageResourceLocations(completion: @escaping ((FlickrSearchResult?, Error?) -> Void)) {
        let success = 200...299
        let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=e79e37db8c17fb8f7b009ea28a20cb4c&tags=bees&format=json&")
        let task = Flickr.buildDataTask(url: url!) { (data, response, error) in
            guard error == nil, let data = data else {
                completion(nil, error!)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, success.contains(statusCode) else {
                completion(nil, ConnectionError.connectionFailure)
                return
            }
            let flickrSearchDecoder = JSONDecoder()
            do {
                let flickrResponseData = try flickrSearchDecoder.decode(FlickrSearchResult.self, from: data as! Data)
                completion(flickrResponseData, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getFlickrPhotos()
        //buildFetchRequest()

    }
    
    func getFlickrPhotos() {
        guard let flickerUrls = flickrSearchResult?.photos?.photo else {return}
        for flickrUrl in flickerUrls {
           if let url = Flickr.buildImageUrlString(flickrUrl) {
            imagerUrls?.append(url)
                guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: DataController.shared.mainContext) else {return}
                let photo = Photo(entity: entity, insertInto: DataController.shared.mainContext)
                photo.url = url.absoluteString
//                currentPin.addToPhoto(photo)
                try? DataController.shared.mainContext.save()
            }
        }
    }
    func buildFetchRequest() {
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "tag == %@", tag)
        photoResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataController.shared.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        photoResultsController!.delegate = self
        do {
            try photoResultsController!.performFetch()
            print(photoResultsController.fetchedObjects)
        } catch {
            displayAlert(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageBatchCell
        cell.imageView.kf.setImage(with: imagerUrls![indexPath.row])
        return cell
    }
}

extension ImageBatchVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            guard let newIndexPath = newIndexPath else {return}
            collectionView.insertItems(at: [newIndexPath])
        } else if type == .update {
            guard let indexPath = indexPath else {return}
            collectionView.reloadItems(at: [indexPath])
        } else if type == .delete {
            guard let indexPath = indexPath else {return}
            collectionView.deleteItems(at: [indexPath])
        }
    }
}

extension UIViewController {
    func displayAlert(_ error: Error) {
        let alertInfo = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .actionSheet)
        alertInfo.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertInfo, animated: true, completion: nil)
    }
}
