

import UIKit
import MapKit
import CoreData
import MobileCoreServices
import CoreLocation

class AddNotesViewController: UIViewController, CLLocationManagerDelegate {
    
    var subject: NSManagedObject!
    var note: NSManagedObject!
    var strSubject: String?
    
    var location = CLLocationCoordinate2D()
    var managedObjectContext: NSManagedObjectContext? = nil
    var latitude: Double = 0
    var longitude: Double = 0
    
    typealias CompletionBlock = (_ error: NSError?, _ response : AnyObject?) -> Void
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDatetime: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    
    var locationManager: CLLocationManager!
    
    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtNotes.layer.cornerRadius = 5
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        //self.getUserCurrentLocation()
        //self.addCordinates()
        
    }
    
    func addCordinates(){
        note.setValue(latitude, forKey: "latitudes")
        note.setValue(longitude, forKey: "longitudes")
    }
    
    
    // Called when view appeared for user
    override func viewWillAppear(_ animated: Bool) {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        fetchNote()
        
        if ((strSubject?.isEmpty) == nil) {
            
            let date = NSDate()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            
            formatter.timeStyle  = .short
            //formatter.stringFromDate(date)
            
            txtDatetime.text = formatter.string(from: date as Date)
            
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
            
            // First focus on control
            txtTitle.becomeFirstResponder()
        }
    }
    
    // Remove keyboard
    @objc func dismissKeyboard() {
        print("sohail bhai")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Cancel action to Add Notes
    @IBAction func cancelAddNotes(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    // Save action for new notes
    @IBAction func saveNotes(sender: UIBarButtonItem) {
        if validateFields() {
            saveNotes()
        
            navigationController?.popViewController(animated: true)
        }
    }
    
    // Action to go to picture view controller
    @IBAction func onClickPictures(sender: UIButton) {
        if validateFields() {
            let notes: NSManagedObject = saveNotes()!
        
            let pictures: PictureViewController = self.storyboard?.instantiateViewController(withIdentifier: "Pictures") as! PictureViewController
        
            pictures.notes = notes
        
            navigationController?.show(pictures, sender: nil)
        }
    }
    
    // Action to go to Voice Notes view controller
    @IBAction func onClickVoiceNotes(sender: UIButton) {
        if validateFields() {
            let notes: NSManagedObject = saveNotes()!
        
            let voiceNotes: VoiceNotesViewController = self.storyboard?.instantiateViewController(withIdentifier: "VoiceNotes") as! VoiceNotesViewController
        
            voiceNotes.notes = notes
        
            navigationController?.show(voiceNotes, sender: nil)
        }
    }
    
    
    // Method to get current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (CLLocationManager.locationServicesEnabled())
        {
            let location = locations.last! as CLLocation
           // let location = locations.last
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            self.locationManager.stopUpdatingLocation()
            getAddressFromLocation(location: location, completionBlock: { (error, response) -> Void in
                self.txtLocation.text = response as? String
            })
        }
    }
    
    // Function to build location string
    func getAddressFromLocation(location : CLLocation ,completionBlock : @escaping CompletionBlock){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            var address = ""
            
            if let placeArray = placemarks as [CLPlacemark]! {
                
                // Place details
                if let placeMark: CLPlacemark = placeArray[0] {
                    if let city = placeMark.addressDictionary?["City"] as? String
                    {
                        address = "\(city)"
                    }
                    
                    if let state = placeMark.addressDictionary?["State"] as? String
                    {
                        address = "\(address), \(state)"
                    }
                    
                    if let country = placeMark.addressDictionary?["Country"] as? NSString
                    {
                        address = "\(address), \(country)"
                    }
                }
            }
            completionBlock(nil,address as AnyObject)
        }
    }
    
    // Function to Save new or Update old notes
    func saveNotes() -> NSManagedObject?{
        if ((strSubject?.isEmpty) == nil) {
            let entityDescription = NSEntityDescription.entity(forEntityName: "Notes", in: self.managedObjectContext!)
            let newNotes = NSManagedObject(entity: entityDescription!, insertInto: self.managedObjectContext)
        
            newNotes.setValue(txtTitle.text, forKey: "title")
            newNotes.setValue(txtDatetime.text, forKey: "datetime")
            newNotes.setValue(txtLocation.text, forKey: "location")
            newNotes.setValue(txtNotes.text, forKey: "notes")
            newNotes.setValue(subject.value(forKey: "subjectname"), forKey: "subjectid")
            
            strSubject = subject.value(forKey: "subjectname") as? String
            note = newNotes
        
            do {
                try newNotes.managedObjectContext?.save()
                return newNotes
            } catch {
                print(error)
                return nil
            }
        } else {
            note.setValue(txtTitle.text, forKey: "title")
            note.setValue(txtDatetime.text, forKey: "datetime")
            note.setValue(txtLocation.text, forKey: "location")
            note.setValue(txtNotes.text, forKey: "notes")
            note.setValue(strSubject, forKey: "subjectid")
        }
        
        do {
            try note.managedObjectContext?.save()
            return note
        } catch {
            print(error)
            return nil
        }
    }
    
    // Function to fetch current notes data
    func fetchNote(){
        if let editNote = note {
            txtTitle.text = editNote.value(forKey: "title") as? String
            txtDatetime.text = editNote.value(forKey: "datetime") as? String
            txtLocation.text = editNote.value(forKey: "location") as? String
            txtNotes.text = editNote.value(forKey: "notes") as? String
            strSubject = editNote.value(forKey: "subjectid") as? String
            
            txtTitle.isEnabled = false
        }
    }
    
    func getUserCurrentLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last
//        latitude = location?.coordinate.latitude ?? 0
//        longitude = location?.coordinate.longitude ?? 0
//        self.locationManager.stopUpdatingLocation()
//    }
    
    
    
    
    @IBAction func showOnMap(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
       // vc?.managedObject = notesList.object(at: buttonTag) as! NSManagedObject
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    // Function to validate fields before save
    func validateFields() -> Bool{
        var errorMsg = String()
        var flag: Bool = true
        
        if txtTitle.text == "" {
            errorMsg = "Please enter Title"
            flag = false
        }
        else if txtNotes.text == "" {
            errorMsg = "Please enter Note description"
            flag = false
        }
        
        if !flag {
            let refreshAlert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
        
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            }))
        
            present(refreshAlert, animated: true, completion: nil)
        }
        
        return flag
    }
}







