

import UIKit
import CoreData

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var notes: NSManagedObject? = nil
    var arrMedia: NSArray = []
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var imgPick: UIImage?
    

    
    @IBOutlet weak var collectionView: UICollectionView!

    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext

        // Do any additional setup after loading the view.
        
    
    }
    
    // Called when view appeared for user
    override func viewWillAppear(_ animated: Bool) {
        fetchAllPhotos()
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of sections in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Number of sections in collection view-- swift 2.x
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
    
    
    // Number of items in a section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMedia.count
    }
    
    // Function to set value for a single cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        
        let media = arrMedia.object(at: indexPath.row) as! NSManagedObject
        
        let imgData: NSData = media.value(forKey: "mediadata") as! NSData
        
        let img:UIImage = UIImage(data: imgData as Data)!
        
        cell.imgPhoto.image = img
        
        return cell
    }
    
    // Called when a cell is clicked
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullImage: FillImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullSizeImage") as! FillImageViewController
        
        //fullImage.media = arrMedia[indexPath.row] as! NSManagedObject
        fullImage.arrMedia = arrMedia
        fullImage.notes = notes
        fullImage.index = indexPath.row
        
        navigationController?.show(fullImage, sender: nil)
    }
    
    // Action to open camera in app
    @IBAction func btnCamera(sender: UIBarButtonItem) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Action to open photo library in app
    @IBAction func btnGallery(sender: UIBarButtonItem) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // Delegate called when image is captured from camera or photo library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { () -> Void in }
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        imgPick = image
        insertPhoto()
    }

    // Delegate called when image is captured from camera or photo library---swift 2.x
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//
//        imgPick = image
//
//        picker.dismiss(animated: true) { () -> Void in }
//
//        insertPhoto()
//    }
    
    
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true) { () -> Void in
//
//        }
//    }
    
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
            //print(arrMedia)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        collectionView.reloadData()
    }
    
    // Function to insert photo into database
    func insertPhoto(){
        let entityDescription = NSEntityDescription.entity(forEntityName: "Media", in: self.managedObjectContext!)
        let newMedia = NSManagedObject(entity: entityDescription!, insertInto: self.managedObjectContext)
        
        let imageData = imgPick!.pngData()

        newMedia.setValue("Image", forKey: "mediatype")
        newMedia.setValue(imageData, forKey: "mediadata")
        newMedia.setValue(notes!.value(forKey: "title"), forKey: "notesid")
        
        //let error:NSErrorPointer = nil
        
        do {
            try newMedia.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
    
    // Delegate to set collection view layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.size.width-20) / 3
        return CGSize(width: width, height: width)
            // CGSizeMake(width, width)
    }
    
    @IBAction func btnSlideShow(sender: UIBarButtonItem) {
        let fullImage: FillImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullSizeImage") as! FillImageViewController
        
        fullImage.arrMedia = arrMedia
        fullImage.notes = notes
        fullImage.index = 0
        fullImage.isSlideShow = true
        
        navigationController?.show(fullImage, sender: nil)
    }
}
