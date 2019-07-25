import UIKit
import AVFoundation
import CoreData

class AddVoiceNotesViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    
    var notes: NSManagedObject? = nil
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var timer: Timer!
    
    var timerStart: NSDate!
    
    // Called when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = app.managedObjectContext

        setupAudioRecord()
        
        btnPlay.isEnabled = false
        
        lblTimer.text = "00:00:00"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action to record or stop recording voice notes
    @IBAction func btnRecord(sender: UIButton) {
        if sender.titleLabel?.text == "Record" {
            if audioRecorder?.isRecording == false {
            
               // btnRecord.setTitle("Stop", for: .Normal)
            btnRecord.setTitle("Stop", for: .normal)
                btnPlay.isEnabled = false
                btnSave.isEnabled = false
            
                audioRecorder?.record()
                startTimer()
            }
        } else if sender.titleLabel?.text == "Stop" {
            btnRecord.setTitle("Record", for: .normal)
           
            
            btnPlay.isEnabled = true
            btnSave.isEnabled = true
            
            if audioRecorder?.isRecording == true {
                audioRecorder?.stop()
                stopTimer()
            } else {
                audioPlayer?.stop()
            }
        }
    }
    
    // Action to play recorded voice notes
    @IBAction func btnPlay(sender: UIButton) {
        if audioRecorder?.isRecording == false {
            btnRecord.isEnabled = false
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    // Action to save new Voice notes
    @IBAction func btnSaveVoiceNotes(sender: UIButton) {
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")

        let filePathVoiceNotes = soundFileURL.path
        
        let fileContentVoiceNotes = NSData(contentsOfFile: filePathVoiceNotes)
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Media", in: self.managedObjectContext!)
        let newMedia = NSManagedObject(entity: entityDescription!, insertInto: self.managedObjectContext)

        newMedia.setValue("VoiceNotes", forKey: "mediatype")
        newMedia.setValue(fileContentVoiceNotes, forKey: "mediadata")
        newMedia.setValue(notes!.value(forKey: "title"), forKey: "notesid")
        
        do {
            try newMedia.managedObjectContext?.save()
        } catch {
            print(error)
        }

        navigationController?.popViewController(animated: true)
    }
    
    // Function called when audio is played
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        btnRecord.isEnabled = true
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Audio Record Encode Error")
    }

    // Setup setting for audio recording or playing
    func setupAudioRecord() {
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            if #available(iOS 10.0, *) {
             try audioSession.setCategory(.playback, mode: .default, options: [])
            } else {
                print("error")
            }
            }
        
        catch let error as NSError {
    print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            
            try audioRecorder = AVAudioRecorder(url: soundFileURL, settings: recordSettings as! [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    // Function to start timer while recording
    func startTimer() {
        // get current system time
        self.timerStart = NSDate()
        
        // start the timer
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    // Function to stop timer
    func stopTimer(){
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    // Function to update timer in Label
    @objc func update() {
        // get the current system time
        let now = NSDate()
        
        // get the seconds since start
        let seconds = now.timeIntervalSince(self.timerStart! as Date)
        
        let time = stringFromTimeInterval(interval: seconds)
        
        lblTimer.text = time
    }
    
    // Function to fetch string from time
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
