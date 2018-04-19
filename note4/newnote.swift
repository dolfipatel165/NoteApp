

import UIKit
import CoreData
import CoreLocation
import MapKit
import MobileCoreServices
import AVFoundation

class newnote: UIViewController, CLLocationManagerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,  AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextViewDelegate    {
   
    @IBOutlet weak var clocation: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dt: UILabel!
    @IBOutlet var titles: UITextField!
    @IBOutlet var details: UITextView!
  
//    @IBOutlet weak var recordButton: UIButton!
//    @IBOutlet weak var stopButton: UIButton!
//    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var newMedia: Bool?
    var managedObjectContext: NSManagedObjectContext? = nil
    var locationManager = CLLocationManager()
    var notes: NSManagedObject!
    var lat:String = ""
    var long: String = ""
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titles.becomeFirstResponder()
        //
        
            playButton.enabled = false
            stopButton.enabled = false
            recordButton.enabled = true
        
        details.delegate = self
        details.text = "Enter your details here...."
        details.textColor = UIColor.lightGrayColor()
        
        clocation.text = ""
        
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = fileMgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let soundFileURL = dirPaths[0].URLByAppendingPathComponent("sound.caf")
        
//        print(soundFileURL.path!)
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            
            try audioRecorder = AVAudioRecorder(URL: soundFileURL,
                settings: recordSettings as! [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        //
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
            //For Getting The Location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        //It will add the + button in the top right bar
        
        let rightImageBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "image:")
        
        let rightSaveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "savenotes:")
        self.navigationItem.setRightBarButtonItems([ rightSaveBarButtonItem,rightImageBarButtonItem], animated:true)
        
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Save , target: self, action: "savenotes:")
//        self.navigationItem.rightBarButtonItem = addButton
        
        //Date format
        dt.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        //tap feture for toggle down the keyboard
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTap")
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTap)

        // Do any additional setup after loading the view.
        if notes != nil {
            titles.text = notes.valueForKey("title") as? String
            details.text = notes.valueForKey("details") as? String
            details.textColor = UIColor.blackColor()
            clocation.text = notes.valueForKey("location") as? String
            dt.text = notes.valueForKey("date") as? String
            
             //lo.text = notes.valueForKey("longitude") as? String
             //latti.text = notes.valueForKey("latitude") as? String
            if notes.valueForKey("image") != nil {
                let img = UIImage(data: notes.valueForKey("image") as! NSData)
                self.imageView.image = img
            }
            
            playButton.enabled = true
            stopButton.enabled = false
            recordButton.enabled = false
            
            if notes.valueForKey("record") != nil {
                do {
                    try audioPlayer = AVAudioPlayer(data: notes.valueForKey("record") as! NSData, fileTypeHint: .None)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: .DefaultToSpeaker)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                } catch {
                    let fetchError = error as NSError
                    print(fetchError)
                }
            }
            
            // old location
        }
        
    
        
//        details.layer.borderColor = UIColor.blackColor().CGColor
//        details.layer.borderWidth = 1
        
        
    }
        func singleTap() {
        self.view.endEditing(true);
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if self.notes == nil {
            let a = locations[locations.count - 1]
            CLGeocoder().reverseGeocodeLocation(a){
                (myPlacements, myError) -> Void in
                if myError != nil{
                    //self.clocation.text = "Location Currently Not Available"
                }
            if let myPlacement = myPlacements?.first{
            let myAddress = "\(myPlacement.locality!)"
                if self.notes == nil {
                    self.clocation.text = myAddress
                }
                
                }
            self.lat = String(format: "%.4f",
                a.coordinate.latitude)
            self.long = String(format: "%.4f",
                a.coordinate.longitude)
            }
        //recording
        //}
        
      
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func showMap(sender: AnyObject) {
        
        let map: mapViewController = self.storyboard?.instantiateViewControllerWithIdentifier("showmap") as! mapViewController
        
        map.latitude = self.lat
        map.longitude = self.long
        
        navigationController?.showViewController(map, sender: nil)
    }
    
//    @IBAction func savenote(sender: UIButton) {
//        savenotes(sender)
//    }
    
    func savenotes(obj: AnyObject?){
        var imgData: NSData? = nil
        var fileContentVoiceNotes: NSData? = nil
        
        if notes == nil {
            // Record convert start
            let fileMgr = NSFileManager.defaultManager()
            let dirPaths = fileMgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let soundFileURL = dirPaths[0].URLByAppendingPathComponent("sound.caf")
            
            let filePathVoiceNotes = soundFileURL.path
            
            fileContentVoiceNotes = NSData(contentsOfFile: filePathVoiceNotes!)
            // Record convert end
            
            
            let entityDescription = NSEntityDescription.entityForName("Notes", inManagedObjectContext: self.managedObjectContext!)
            let newNotes = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: self.managedObjectContext)
            
            if imageView.image != nil {
                imgData = UIImagePNGRepresentation(imageView.image!)
            }
            
            newNotes.setValue(titles.text, forKey: "title")
            newNotes.setValue(details.text, forKey: "details")
            newNotes.setValue(clocation.text, forKey: "location")
            newNotes.setValue(dt.text, forKey: "date")
            
            newNotes.setValue(imgData, forKey: "image")
            newNotes.setValue(fileContentVoiceNotes, forKey: "record")
            
            
            do {
                try newNotes.managedObjectContext?.save()
            } catch {
                print(error)
            }
            
        }
        else {
            if imageView.image != nil {
                imgData = UIImagePNGRepresentation(imageView.image!)
            }
            
            notes.setValue(titles.text, forKey: "title")
            notes.setValue(details.text, forKey: "details")
            notes.setValue(clocation.text, forKey: "location")
            notes.setValue(dt.text, forKey: "date")
            notes.setValue(imgData, forKey: "image")
            notes.setValue(fileContentVoiceNotes, forKey: "record")
            
            do {
                try notes.managedObjectContext?.save()
            } catch {
                print(error)
            }
    }

        navigationController?.popViewControllerAnimated(true)
    }

    func image(obj: AnyObject) {
        
        let alertController = UIAlertController(title: "Select Image", message:
            "", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default,handler: { (tableviewTableViewController) -> Void in self.immggg()
        }))
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (tableviewTableViewController) -> Void in self.immmg()
        }))
//        alertController.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Default, handler: { (tableviewTableViewController) -> Void in self.immmgc()
//        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                   }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func immmg(){
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = true;
        }
    }
    
    func immggg(){
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = false
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            imageView.image = image
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self,
                    "image:didFinishSavingWithError:contextInfo:", nil)
            } else if mediaType.isEqualToString(kUTTypeMovie as String) {
                // Code to support video here
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let view1 = segue.destinationViewController as! mapViewController
//        //        view1.address = (notes.valueForKey("location") as? String)!
//        
//        
//        
//        func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            let a = locations[locations.count - 1]
//   
//            CLGeocoder().reverseGeocodeLocation(a){
//                (myPlacements, myError) -> Void in
//                if myError != nil{
//                    self.clocation.text = "Location Currently Not Available"
//                }
//                if let myPlacement = myPlacements?.first{
//                    
//                    self.lat = String(format: "%.4f",
//                        a.coordinate.latitude)
//                    self.long = String(format: "%.4f",
//                        a.coordinate.longitude)
//                }
//            }
//        }
//        
//        view1.latitude = self.lat
//        view1.longitude = self.long
//        
//    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        if audioRecorder?.recording == false {
            playButton.enabled = false
            stopButton.enabled = true
            audioRecorder?.record()
        }
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        
        if notes != nil {
            audioPlayer?.delegate = self
            
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        }
        else {
            if audioRecorder?.recording == false {
                stopButton.enabled = true
                recordButton.enabled = false
                
                do {
                    try audioPlayer = AVAudioPlayer(contentsOfURL: (audioRecorder?.url)!)
                    audioPlayer!.delegate = self
                    audioPlayer!.prepareToPlay()
                    audioPlayer!.play()
                } catch let error as NSError {
                    print("audioPlayer error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Audio Record Encode Error")
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if notes == nil {
        if details.textColor == UIColor.lightGrayColor() {
            details.text = ""
            details.textColor = UIColor.blackColor()
            }
        }
        if notes != nil {
            details.textColor = UIColor.blackColor()
             details.text = notes.valueForKey("details") as? String
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if details.text == "" {
            
            details.text = "Enter your details here...."
            details.textColor = UIColor.lightGrayColor()
        }
    }
    
}

