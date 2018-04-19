
import UIKit
import CoreData

class tableviewTableViewController: UITableViewController, UISearchBarDelegate{
    
    @IBOutlet weak var outletSearch: UISearchBar!
    @IBOutlet var tview: UITableView!
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    var arrTitles: NSArray = []
    var arrDetails: NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tview.backgroundColor = UIColor (red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
//        outletSearch.hidden = true
        outletSearch.placeholder = "Search here"
 
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//
//        var leftAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "")
//        // 2
//        var leftSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "")
//        // 3
//        self.navigationItem.setLeftBarButtonItems([leftAddBarButtonItem,leftSearchBarButtonItem], animated: true)
//
        
//        let leftSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "search:")
//        self.navigationItem.setLeftBarButtonItems([self.editButtonItem(), leftSearchBarButtonItem], animated: true)
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let rightSortBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Sort", style: UIBarButtonItemStyle.Plain, target: self, action: "sorting:")
        
        let rightAddBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "createNotes:")
        self.navigationItem.setRightBarButtonItems([ rightAddBarButtonItem,rightSortBarButtonItem], animated:true)
        
        outletSearch.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchAllNotes("")
        tview.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tview.contentOffset = CGPointMake(0, -20)
    }
    
    func createNotes(sender: AnyObject) {
        let notes: newnote = self.storyboard?.instantiateViewControllerWithIdentifier("newnote") as! newnote
        
        navigationController?.showViewController(notes, sender: nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let view2 = segue.destinationViewController as! newnote
//     
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return arrTitles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let subject = arrTitles.objectAtIndex(indexPath.row) as! NSManagedObject
        
        cell.textLabel!.text = subject.valueForKey("title") as? String
        
        return cell
        
        }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let note = arrTitles[indexPath.row]
        
        
        let notes: newnote = self.storyboard?.instantiateViewControllerWithIdentifier("newnote") as! newnote
        
        notes.notes = note as! NSManagedObject
        
        //print(note.valueForKey("title"))
        
        navigationController?.showViewController(notes, sender: nil)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let note = self.arrTitles[indexPath.row] as! NSManagedObject
            
            self.managedObjectContext?.deleteObject(note)
            
            do {
                try note.managedObjectContext?.save()
            } catch {
                print(error)
            }
            
            self.fetchAllNotes("")
            self.tview.reloadData()
        }
    }
    
    func fetchAllNotes(filter: String){
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("Notes", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        
        if !filter.isEmpty {
            let pred = NSPredicate(format: "title CONTAINS[c] %@ OR details CONTAINS[c] %@", filter, filter)
            fetchRequest.predicate = pred
        }
        
        do {
            arrTitles = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            
            
//            for var i:Int=0; i<arrTitles.count; i++ {
//                print(arrTitles[i].valueForKey("title"))
//                
//            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        do {
            arrDetails = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            
//            for var j:Int=0; j<arrDetails.count; j++ {
//                print(arrDetails[j].valueForKey("details"))
//                
//            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        tview.reloadData()
    }
    func sorting(sender: AnyObject) { // should probably be called sort and not filter
        //var sortDescriptor:NSSortDescriptor = nil
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let sortTitleAsc: UIAlertAction = UIAlertAction(title: "Title Ascending", style: .Default) { action -> Void in
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            self.sortNotes(sortDescriptor)
        }
        actionSheetController.addAction(sortTitleAsc)
        
        let sortTitleDesc: UIAlertAction = UIAlertAction(title: "Title Descending", style: .Default) { action -> Void in
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
            self.sortNotes(sortDescriptor)
        }
        actionSheetController.addAction(sortTitleDesc)
        
        let sortDateAsc: UIAlertAction = UIAlertAction(title: "Date Ascending", style: .Default) { action -> Void in
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            self.sortNotes(sortDescriptor)
        }
        actionSheetController.addAction(sortDateAsc)
        
        let sortDateDesc: UIAlertAction = UIAlertAction(title: "Date Descending", style: .Default) { action -> Void in
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            self.sortNotes(sortDescriptor)
        }
        actionSheetController.addAction(sortDateDesc)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        
        
//        let fetchRequest = NSFetchRequest(entityName: "Notes")
//        
//
//        
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        do {
//           let arrTitless = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
//            
//            
//            //            for var i:Int=0; i<arrTitles.count; i++ {
//            //                print(arrTitles[i].valueForKey("title"))
//            //
//            //            }
//            
//            arrTitles = arrTitless
//            
//        } catch {
//            let fetchError = error as NSError
//            print(fetchError)
//        }
//
//        self.tview.reloadData()
    }

    func sortNotes(sortDescriptor: NSSortDescriptor){
        let fetchRequest = NSFetchRequest(entityName: "Notes")
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let arrTitless = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            
            arrTitles = arrTitless
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        self.tview.reloadData()
    }
    
    func search(sender: AnyObject){
        outletSearch.hidden = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fetchAllNotes(searchText);
    }
}
