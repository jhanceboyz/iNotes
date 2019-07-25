
import UIKit
import CoreData
import AVFoundation

class VoiceNotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate{
    
    @IBOutlet weak var tableViewVoiceNotes: UITableView!
    
    var audioPlayer:AVAudioPlayer? = nil
    
    var notes: NSManagedObject?
    var arrMedia: NSArray = []
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var selectedIndexPath: NSIndexPath!
    
    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext
        
        // Do any additional setup after loading the view.
    }
    
    // Called when view appeared for user
    override func viewWillAppear(_ animated: Bool) {
        fetchVoiceNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action to navigate to add voice notes view controller
    @IBAction func addVoiceNotes(sender: UIBarButtonItem) {
        let newVoiceNotes: AddVoiceNotesViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddVoiceNotes") as! AddVoiceNotesViewController
        
        newVoiceNotes.notes = notes
        
        navigationController?.show(newVoiceNotes, sender: nil)
    }
    
    // Number of sections in tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMedia.count
    }
    
    // Function to set value for a single row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! NotesCell
        
        if selectedIndexPath != nil
        //&& indexPath == cell.
        {
            cell.imgPlayer.image = UIImage(named: "stop")
        }
        else {
            cell.imgPlayer.image = UIImage(named: "play")
        }
        
        //let voiceNotes = arrMedia.objectAtIndex(indexPath.row) as! NSManagedObject
        
        cell.textLabel!.text = "Voice Notes " + String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Function is called when user clicked on delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let refreshAlert = UIAlertController(title: "Alert", message: "Delete Voice Note?.", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let voice = self.arrMedia[indexPath.row] as! NSManagedObject
            
                self.managedObjectContext?.delete(voice)
            
                do {
                    try voice.managedObjectContext?.save()
                } catch {
                    print(error)
                }
            
                self.fetchVoiceNotes()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    // Function to play and stop voice notes
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Play
        
        if selectedIndexPath != nil && indexPath == selectedIndexPath as IndexPath {
            selectedIndexPath = nil
            audioPlayer?.stop()
        }
        else {
            selectedIndexPath = indexPath as NSIndexPath
            
            let media: Media = self.arrMedia[indexPath.row] as! Media
            playMusic(musicData: media.mediadata!)
        }
        
        tableViewVoiceNotes.reloadData()
    }
    
    // Function to play voice notes
    func playMusic(musicData: NSData) {
        
        do {
            try audioPlayer = AVAudioPlayer(data: musicData as Data, fileTypeHint: .none)
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .defaultToSpeaker)
            } else {
                     print("error")
                
            }
            //setCategory(AVAudioSession.Category.playback, withOptions: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        audioPlayer?.delegate = self
        
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
    }
    
    // Called when player finish playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        selectedIndexPath = nil
        tableViewVoiceNotes.reloadData()
    }
    
    // Function to fetch all voice notes from database
    func fetchVoiceNotes(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Media", in: self.managedObjectContext!)
        
        let pred = NSPredicate(format: "%K = %@ AND %K = %@", "notesid", notes!.value(forKey: "title") as! String, "mediatype", "VoiceNotes")
        
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
        
        tableViewVoiceNotes.reloadData()
    }

}






