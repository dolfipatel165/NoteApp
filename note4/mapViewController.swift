

import UIKit
import CoreData
import MapKit
class mapViewController: UIViewController {

    @IBOutlet weak var First_Place: MKMapView!
    
    var latitude = ""
    var longitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //         Do any additional setup after loading the view.
        
        mapFirst_Place()
        
        
        
    }
    
    func mapFirst_Place ()
    {
        
        //Coordinates
        let fLat:CLLocationDegrees = Double(latitude)!
        let flong:CLLocationDegrees = Double(longitude)!
        
        let fCoordinates = CLLocationCoordinate2D(latitude: fLat, longitude: flong)
        
        //Span
        let fLatDelta:CLLocationDegrees = 1.0
        let fLongDelta:CLLocationDegrees = 1.0
        let fSpan = MKCoordinateSpan(latitudeDelta: fLatDelta, longitudeDelta: fLongDelta)
        
        let fRegion = MKCoordinateRegion(center: fCoordinates, span: fSpan)
        
        First_Place.setRegion(fRegion, animated: true)
        
        let fAnnotation = MKPointAnnotation()
        fAnnotation.title = "College"
        fAnnotation.subtitle = "This is my College"
        fAnnotation.coordinate = fCoordinates
        
        First_Place.addAnnotation(fAnnotation)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

    

  

}
