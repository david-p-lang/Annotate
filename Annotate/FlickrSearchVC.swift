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


    @IBAction func searchFlicker(_ sender: Any) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Tag", in: DataController.shared.mainContext) else {return}
        let tag = Tag(entity: entity, insertInto: DataController.shared.mainContext)
        tag.name = searchTextfield.text
        try? DataController.shared.mainContext.save()

        
    }
}

