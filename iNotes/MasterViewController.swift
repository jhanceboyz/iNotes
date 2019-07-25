
import UIKit
import CoreData

class MasterViewController: UITableViewController {

    @IBOutlet var tableviewSubject: UITableView!
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var arrSubject: NSArray = []
    var arrSubjectID: NSArray = []

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        fetchAllSubject()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MasterViewController.insertNewObject))
       

         //   UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Selector(("insertNewObject")))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    // Called when view appeared for user
    override func viewDidAppear(_ animated: Bool) {
        fetchAllSubject()
        self.tableviewSubject.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function to navigate to add subject view controller
    @objc func insertNewObject() {
        //sender: AnyObject
        let subject: SubjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "Subject") as! SubjectViewController
        
        navigationController?.show(subject, sender: nil)
    }

    // Number of sections in tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in a section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return arrSubject.count
    }

    // Function to set value for a single cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //self.configureCell(cell, atIndexPath: indexPath)
        
        let subject = arrSubject.object(at: indexPath.row) as! NSManagedObject
        
        cell.textLabel!.text = subject.value(forKey: "subjectname") as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Function is called when user clicked on delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let sub = self.arrSubject[indexPath.row] as! NSManagedObject
            
            let avaNotes: Int = checkIsNotesAvailable(subjectID: sub.value(forKey: "subjectname") as! String)
            
           // if avaNotes <= 0 {
                let refreshAlert = UIAlertController(title: "Alert", message: "Delete Subject?.", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    
                    self.managedObjectContext?.delete(sub)
                    
                    do {
                        try sub.managedObjectContext?.save()
                    } catch {
                        print(error)
                    }
                    
                    self.fetchAllSubject()
                    self.tableviewSubject.reloadData()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                present(refreshAlert, animated: true, completion: nil)
//            }
//            else {
//                let refreshAlert = UIAlertController(title: "Alert", message: "Delete Notes first!", preferredStyle: UIAlertController.Style.alert)
//
//                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//
//                }))
//
//                present(refreshAlert, animated: true, completion: nil)
//            }
        }
    }
    
    // Called when a row is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notesList: NotesViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotesList") as! NotesViewController
        
        notesList.subject = arrSubject[indexPath.row] as! NSManagedObject
        
        navigationController?.show(notesList, sender: nil)
    }

    // Function to fetch all subject from database
    func fetchAllSubject(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Subject", in: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription

        do {
            arrSubject = try self.managedObjectContext!.fetch(fetchRequest) as NSArray
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func checkIsNotesAvailable(subjectID: String) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Notes", in: self.managedObjectContext!)
        
        let pred = NSPredicate(format: "%K = %@", "subjectid", subjectID)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = pred
        
        do {
            return try self.managedObjectContext!.fetch(fetchRequest).count
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return 0
        }
    }
}

