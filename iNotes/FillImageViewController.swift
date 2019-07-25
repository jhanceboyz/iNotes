import UIKit
import CoreData

class FillImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imgImageView: UIImageView!
    
    var media: NSManagedObject!
    var arrMedia: NSArray = []
    var notes: NSManagedObject!
    
    var index: Int = 0
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var isSlideShow: Bool = false
    
    private var scale:CGFloat = 1
    private var previousScale:CGFloat = 1
    
    var timer: Timer!

    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        media = arrMedia[index] as? NSManagedObject
        
        let imgData: NSData = media.value(forKey: "mediadata") as! NSData
        let img:UIImage = UIImage(data: imgData as Data)!
        imgImageView.image = img
        
        let slideRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(slideRightm))
        slideRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(slideRight)
        
        let slideLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(slideLeftm))
        slideLeft.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(slideLeft)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(doPinch))
        pinchGesture.delegate = self
        imgImageView.addGestureRecognizer(pinchGesture)
        
        let slideShowButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startSlideShow))
        self.navigationItem.rightBarButtonItem = slideShowButton
        
        if isSlideShow {
            startTimer()
        
            let slideShow = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(startSlideShow))
            self.navigationItem.rightBarButtonItem = slideShow
            isSlideShow = true
        }
    }
    
    @objc func startSlideShow(){
        var slideShowButton = UIBarButtonItem()
        
        
        if !isSlideShow {
            startTimer()
            slideShowButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(startSlideShow))
            isSlideShow = true
        }
        else {
            stopTimer()
            slideShowButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startSlideShow))
            isSlideShow = false
        }
        self.navigationItem.rightBarButtonItem = slideShowButton
    }
    
    // Function when user swipes on right side
    @objc func slideRightm() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        if index >= arrMedia.count - 1 {
            index = 0
        }
        else {
            index += 1;
        }
        
        media = arrMedia[index] as? NSManagedObject
        
        let imgData: NSData = media.value(forKey: "mediadata") as! NSData
        let img:UIImage = UIImage(data: imgData as Data)!
        imgImageView.image = img
    }
    
    // Function when user swipes on left side
    @objc func slideLeftm() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        if index <= 0 {
            index = arrMedia.count - 1
        }
        else {
            index -= 1;
        }
        
        media = arrMedia[index] as? NSManagedObject
        
        let imgData: NSData = media.value(forKey: "mediadata") as! NSData
        let img:UIImage = UIImage(data: imgData as Data)!
        imgImageView.image = img
    }
    
    @objc func doPinch(gesture:UIPinchGestureRecognizer) {
        scale = gesture.scale
        transformImageView()
        if gesture.state == .ended {
            previousScale = scale * previousScale
            scale = 1
        }
    }
    
    func transformImageView() {
        let t = CGAffineTransform(scaleX: scale * previousScale, y: scale * previousScale)
        imgImageView.transform = t
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.navigationController?.popViewController(animated: true)
    }
    
    // Action to delete showed image
    @IBAction func btnDeleteImage(sender: UIBarButtonItem) {
        let refreshAlert = UIAlertController(title: "Alert", message: "Delete Image?.", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.managedObjectContext?.delete(self.media)
            
            do {
                try self.media.managedObjectContext?.save()
            } catch {
                print(error)
            }
            
            self.fetchAllPhotos()
            
            if self.arrMedia.count <= 0 {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.slideLeftm()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    // Function to fetch all photos from database
    func fetchAllPhotos(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Media", in: self.managedObjectContext!)
        
        let pred = NSPredicate(format: "%K = %@ AND %K = %@", "notesid", notes!.value(forKey: "title") as! String, "mediatype", "Image")
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = pred
        
        do {
            arrMedia = try self.managedObjectContext!.fetch(fetchRequest) as NSArray
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    // Function to start timer for slideshow
    func startTimer() {
        // start the timer
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(slideRightm), userInfo: nil, repeats: true)
    }
    
    // Function to stop timer of slideshow
    func stopTimer(){
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }

}
