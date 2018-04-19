
import UIKit
import CoreData

class ViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var arrNotes: NSArray = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

