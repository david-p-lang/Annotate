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
    var tagString = ""
    var currentTag:Tag!
    var photoToAnnotate:Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        print("current tag", currentTag)
    }

    override func viewWillAppear(_ animated: Bool) {
        getFlickrPhotos()
        buildFetchRequest()

    }
    
    func getFlickrPhotos() {
        guard let flickerUrls = flickrSearchResult?.photos?.photo else {return}
        for flickrUrl in flickerUrls {
           if let url = Flickr.buildImageUrlString(flickrUrl) {
            imagerUrls?.append(url)
                guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: DataController.shared.mainContext) else {return}
                let photo = Photo(entity: entity, insertInto: DataController.shared.mainContext)
                photo.url = url.absoluteString
                photo.name = currentTag.name
                currentTag.addToPhoto(photo)
                try? DataController.shared.mainContext.save()
            }
        }
    }
    func buildFetchRequest() {
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "name == %@", currentTag.name!)
        print("tag string", tagString)
        photoResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DataController.shared.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        photoResultsController!.delegate = self
        do {
            try photoResultsController!.performFetch()
            print("photoresult cnt", photoResultsController.fetchedObjects!.count)
        } catch {
            displayAlert(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = photoResultsController?.sections?[section].numberOfObjects ?? 0
        print("collection view count" , number)
        if number == 0 && (flickrSearchResult?.photos?.photo.count) == 0 {
            self.collectionView.setEmptyMessage("No Images")
        } else {
            self.collectionView.restore()
        }
        return number
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageBatchCell

        print("cell formation")
        guard let photo = photoResultsController?.object(at: indexPath) else {return cell}
        guard let photoUrl = photo.url else {return cell}
        guard let photoData = photo.data else {
            
            print(")//Photo's data is nil so download", photo)
            Flickr.requestImage(urlString: photoUrl) { (image, error) in
                guard error == nil, let image = image else {
                    self.displayAlert(error ?? ConnectionError.connectionFailure)
                    return
                }
                DispatchQueue.main.async {
                    guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
                    photo.data = imageData
                    do {
                        try DataController.shared.mainContext.save()
                    } catch {
                        self.displayAlert(error)
                    }
                    cell.imageView.image = image
                    cell.photo = photo
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                }
            }
            return cell
        }
        print("//Load from stored data", photo)
        cell.imageView.image = UIImage(data: photoData)
        cell.photo = photo
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Segues.editorSegue:
            let vC = segue.destination as! EditorVC
            vC.passedPhoto = photoToAnnotate
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ImageBatchCell
        photoToAnnotate = selectedCell.photo
        performSegue(withIdentifier: Constants.Segues.editorSegue, sender: self)
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

//Modified from Reply: Samman Bikram Thapa
//https://stackoverflow.com/questions/43772984/how-to-show-a-message-when-collection-view-is-empty
extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
