//
//  ImageBatchVC.swift
//  Annotate
//
//  Created by David Lang on 7/3/19.
//  Copyright © 2019 David Lang. All rights reserved.
//


// https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=e79e37db8c17fb8f7b009ea28a20cb4c&tags=bees&format=rest

import UIKit

class ImageBatchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var flickrSearchResult: FlickrSearchResult?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var pages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFlickrPhotos()
        buildFetchRequest()

    }
    
    func getFlickrPhotos() {
        guard let flickerUrls = flickrSearchResult?.photos?.photo else {return}
        for flickrUrl in flickerUrls {
//            if let url = Flickr.buildImageUrlString(flickrUrl) {
//                guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: DataController.shared.mainContext) else {return}
//                let photo = Photo(entity: entity, insertInto: DataController.shared.mainContext)
//                photo.url = url.absoluteString
//                currentPin.addToPhoto(photo)
//                try? DataController.shared.mainContext.save()
//            }
        }
    }
    
    func buildFetchRequest() {
//        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
//        fetchRequest.sortDescriptors = []
//        fetchRequest.predicate = NSPredicate(format: "pin == %@", currentPin)
//        photoResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: DataController.shared.mainContext,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        photoResultsController!.delegate = self
//        do {
//            try photoResultsController!.performFetch()
//        } catch {
//            displayAlert(error)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
