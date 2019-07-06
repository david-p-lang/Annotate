//
//  ImageSetsVC.swift
//  Annotate
//
//  Created by David Lang on 7/1/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import UIKit
import CoreData

class CollectionsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var collections :[Collection]!
    
    var collectionsResultController:NSFetchedResultsController<Collection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    override func viewWillAppear(_ animated: Bool) {
        fetchCollections()
    }
    
    func fetchCollections()  {
        let fetchRequest:NSFetchRequest<Collection> = Collection.fetchRequest()
        //let predicate = NSPredicate
        fetchRequest.sortDescriptors = []
        collectionsResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try collectionsResultController.performFetch()
            collections = collectionsResultController.fetchedObjects
            print("collection fetch", collectionsResultController.fetchedObjects)
        } catch {
            print(error)
        }
    }
    @IBAction func addCollection(_ sender: Any) {
        print("add collection")
        let entity = NSEntityDescription.entity(forEntityName: "Collection", in: DataController.shared.mainContext)
        let newCollection = Collection(entity: entity!, insertInto: DataController.shared.mainContext)
        newCollection.name = "test"
        try? DataController.shared.mainContext.save()
        //print(collectionsResultController.fetchedObjects?.count)
        //tableView.reloadData()
    }
}

extension CollectionsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //collectionsResultController[section].
        let number = collectionsResultController?.sections?[section].numberOfObjects ?? 0
        print("collection view count" , number)
//        if number == 0 && (flickrSearchResult?.photos?.photo.count) == 0 {
//            self.collectionView.setEmptyMessage("No Images")
//        } else {
//            self.collectionView.restore()
//        }
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell
        let collectionss = collectionsResultController.fetchedObjects
        
        cell.textLabel?.text = collectionss?[indexPath.row].name as! String
        return cell
    }
    
    
}
