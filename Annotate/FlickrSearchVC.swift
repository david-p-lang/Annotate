//
//  ViewController.swift
//  Annotate
//
//  Created by David Lang on 7/1/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit
import CoreData

class FlickrSearchVC: UIViewController {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextfield: UITextField!
    var tagResultController:NSFetchedResultsController<Tag>!
    var flickrSearchResult: FlickrSearchResult?
    var currentTag:Tag!
    var tagString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchStoredTags(nil)
        
    }
    
    fileprivate func fetchStoredTags(_ compoundPredicate: NSCompoundPredicate?) {
        let fetchRequest:NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = []
        if compoundPredicate != nil {
            fetchRequest.predicate = compoundPredicate
        }
        tagResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try tagResultController.performFetch()
            print("tagresultcontroller count", tagResultController.fetchedObjects?.count)
        } catch let error as NSError {
            displayAlert(error)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Segues.flickrSearchSegue:
            let vC = segue.destination as! ImageBatchVC
            vC.flickrSearchResult = flickrSearchResult
            vC.tagString = searchTextfield.text!
            vC.currentTag = currentTag
        default:
            break
        }
    }

    @IBAction func searchFlicker(_ sender: Any) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Tag", in: DataController.shared.mainContext) else {return}
        let tag = Tag(entity: entity, insertInto: DataController.shared.mainContext)
        tag.name = searchTextfield.text
        tagString = tag.name!
        try? DataController.shared.mainContext.save()
        
        storedTagWith(name: tag.name!)
        
        Flickr.requestImageResources(tag: searchTextfield.text!, pageNumber: 0) { (flickrSearchResult, error) in
            guard error == nil, let flickrSearchResult = flickrSearchResult else {
                print("RIRL error", error)
                return
            }
            self.flickrSearchResult = flickrSearchResult
            print(self.flickrSearchResult?.photos?.photo)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: Constants.Segues.flickrSearchSegue, sender: self)
                
            }
        }
        
    }
    
    func storedTagWith(name: String) -> Tag? {
        let request:NSFetchRequest<Tag> = Tag.fetchRequest()
        let coordinatePredicates = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "name == %@", tagString)
            ])
        request.predicate = coordinatePredicates
        
        do {
            let tag = try DataController.shared.mainContext.fetch(request).first
            print("tag from fetch request ",tag)
            currentTag = tag
            return tag
        } catch {
            return nil
        }
    }
}

