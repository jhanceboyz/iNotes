

import UIKit
import CoreData

class SubjectViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var objSubject: NSManagedObject?
    
    @IBOutlet weak var txtSubject: UITextField!

    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        txtSubject.becomeFirstResponder()
        fetchSubject()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSaveSubject() {
        
        print("mohit")
        insertSubject()
        navigationController?.popToRootViewController(animated: true)
    }
    // Action to call save new subject function
//    @IBAction func btnSaveSubject() {
//        print("mohit")
//        insertSubject()
//        navigationController?.popToRootViewController(animated: true)
//    }
    
    // Function to save new subject
    func insertSubject(){
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Subject", in: self.managedObjectContext!)
        print("pel diya")
        let newSubject = NSManagedObject(entity: entityDescription!, insertInto: self.managedObjectContext)
        print("balle")
        newSubject.setValue(txtSubject.text, forKey: "subjectname")
        print("burraaah")
        do {
            try newSubject.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
    
    // Function to set subject values in control
    func fetchSubject(){
        if let editSubject = objSubject {
            txtSubject.text = editSubject.value(forKey: "subjectname") as? String
        }
    }
}








