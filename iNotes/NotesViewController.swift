

import UIKit
import CoreData

class NotesViewController: UITableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableviewNotes: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var arrNotes: NSArray = []
    
    var subject: NSManagedObject!
    
    // Action to add new notes
    @IBAction func addNewNote(sender: UIBarButtonItem) {
        let notes: AddNotesViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNotes") as! AddNotesViewController
        
        notes.subject = subject
        
        navigationController?.show(notes, sender: nil)
    }
    
    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        searchBar.delegate = self
        
        self.tableviewNotes.contentOffset = CGPoint.init(x: 0, y: 50)
        //contentOffset = CGPoint(0,50);
        //CGPointMake(0, 50);
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipe.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipe)
    }
    
    // Called when view appeared for user
    override func viewWillAppear(_ animated: Bool) {
        fetchNotes(search: searchBar.text, filter: nil, asc: nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Remove keyboard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Number of sections in tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    // Number of rows in a section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return arrNotes.count
    }
    
    // Function to set value for a single cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        let notes = arrNotes.object(at: indexPath.row) as! NSManagedObject
        cell.textLabel!.text = notes.value(forKey: "title") as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        //dateStyle =   .Medium
        dateFormatter.timeStyle = .short
        let date = dateFormatter.date(from: notes.value(forKey: "datetime") as! String)
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateStyle = .medium
        newDateFormatter.timeStyle = .none
        
        cell.detailTextLabel?.text = newDateFormatter.string(from: date!)
        
        return cell
    }
    
//    override func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
//
//        let notes = arrNotes.object(at: indexPath.row) as! NSManagedObject
//
//        cell.textLabel!.text = notes.value(forKey: "title") as? String
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        //dateStyle =   .Medium
//        dateFormatter.timeStyle = .short
//        let date = dateFormatter.dateFromString(notes.valueForKey("datetime") as! String)
//
//        let newDateFormatter = NSDateFormatter()
//        newDateFormatter.dateStyle = .MediumStyle
//        newDateFormatter.timeStyle = .NoStyle
//
//        cell.detailTextLabel?.text = newDateFormatter.stringFromDate(date!)
//
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    // Function is called when user clicked on delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        let refreshAlert = UIAlertController(title: "Alert", message: "Delete Note?.", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let sub = self.arrNotes[indexPath.row] as! NSManagedObject
                self.managedObjectContext?.delete(sub)
                
                do {
                    try self.subject.managedObjectContext?.save()
                } catch {
                    print(error)
                }
                
                self.fetchNotes(search: self.searchBar.text, filter: nil, asc: nil)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    // Called when a row is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addEditNote: AddNotesViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNotes") as! AddNotesViewController
        
        addEditNote.note = arrNotes[indexPath.row] as? NSManagedObject
        
        navigationController?.show(addEditNote, sender: nil)
    }

    
    // Function to fetch all notes from database
    func fetchNotes(search: String?, filter: String?, asc: Bool?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Notes", in: self.managedObjectContext!)
        
        var pred: NSPredicate!
        
        if !(search!.isEmpty) {
            pred = NSPredicate(format: "%K = %@ AND (title CONTAINS[c] %@ OR notes CONTAINS[c] %@)", "subjectid", subject.value(forKey: "subjectname") as! String, search!, search!)
        }
        else {
            pred = NSPredicate(format: "%K = %@", "subjectid", subject.value(forKey: "subjectname") as! String)
        }
        
        var sortDescriptor = NSSortDescriptor()
        
        if filter != nil {
            sortDescriptor = NSSortDescriptor(key: filter, ascending: asc!)
            let sortDescriptors = [sortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = pred
     
        do {
            arrNotes = try self.managedObjectContext!.fetch(fetchRequest) as NSArray
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        tableviewNotes.reloadData()
    }

    
    // Delegate called when search bar is edited
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchNotes(search: searchText, filter: nil, asc: nil)
        //tableviewNotes.reloadData()
    }
    
    // Action to show the sheet for sorting options
    @IBAction func btnSortClicked(sender: UIBarButtonItem) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add first option action
        let sortTitleAsc: UIAlertAction = UIAlertAction(title: "Title ↑", style: .default) { action -> Void in
            self.fetchNotes(search: self.searchBar.text, filter: "title", asc: true)
        }
        actionSheetController.addAction(sortTitleAsc)
        
        //Create and add second option action
        let sortTitleDesc: UIAlertAction = UIAlertAction(title: "Title ↓", style: .default) { action -> Void in
            self.fetchNotes(search: self.searchBar.text, filter: "title", asc: false)

        }
        actionSheetController.addAction(sortTitleDesc)

        //Create and add third option action
        let sortDateAsc: UIAlertAction = UIAlertAction(title: "Date ↑", style: .default) { action -> Void in
            self.fetchNotes(search: self.searchBar.text, filter: "datetime", asc: true)

        }
        actionSheetController.addAction(sortDateAsc)

        //Create and add fourth option action
        let sortDateDesc: UIAlertAction = UIAlertAction(title: "Date ↓", style: .default) { action -> Void in
            self.fetchNotes(search: self.searchBar.text, filter: "datetime", asc: false)

        }
        actionSheetController.addAction(sortDateDesc)

        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}
