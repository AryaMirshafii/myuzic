//
//  MainViewController.swift
//  Myuzic
//
//  Created by Arya Mirshafii on 3/31/18.
//  Copyright © 2018 aryaMirshafii. All rights reserved.
//

import SideMenu
import MediaPlayer
import Alamofire
struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        
        return self.sharedInstance.isReachable
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backgroundShadowImage: UIImageView!
    
    @IBOutlet weak var albumArtImage: UIImageView!
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var playlistSelectorView: UIView!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var smartShuffleButton: UIButton!
    
    @IBOutlet weak var swipeZone: UIView!
    
    
    var player = MPMusicPlayerController.applicationMusicPlayer
    var mediaItems:[MPMediaItem]!
    var volumeSlider: MPVolumeView?
    
    var timer = Timer()
    var playlistNames = [String]()
    var playlistArray = [MPMediaItemCollection]()
    var serverController = serverManager()
    
    var isSmartShuffling = false
    var userData = dataController()
    private let remoteCommandCenter = MPRemoteCommandCenter.shared()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let status = MPMediaLibrary.authorizationStatus()
        
        if(status == .authorized){
            print("I am authorized")
            if(MPMediaQuery.albums().items!.isEmpty) {
                performSegue(withIdentifier: "noSongs", sender: nil)
                return
                
            }
            
            startPlaying()
            
            self.updateUI()
            updatePlaybackUI()
            self.loadPlaylists()
            self.playlistNameLabel.text = self.playlistNames[0]
            
            
            //player.pause()
            
            
            
            
        } else {
            print("I am not authorized")
            performSegue(withIdentifier: "noPermissions", sender: nil)
            print("returning")
            
        }
        
        setupSideMenu()
        
        self.setUI()
        
        durationSlider.addTarget(self, action: #selector(setDurationValue), for: [.touchUpInside, .touchUpOutside])
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        swipeZone.addGestureRecognizer(tap)
        
        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        //swipeRight.addTarget(self, action: #selector(self.handleSwipe(_ :)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.cancelsTouchesInView = false
        
        swipeZone.addGestureRecognizer(swipeRight)
        //self.view.addGestureRecognizer(swipeRight)
        //albumArtImage.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        swipeLeft.cancelsTouchesInView = false
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.swipeZone.addGestureRecognizer(swipeLeft)
        //self.view.addGestureRecognizer(swipeLeft)
        //sw.addGestureRecognizer(swipeLeft)
        
        
        
        
        
        
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateUI), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange , object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updatePlaybackUI), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange , object: nil)
        
        
        
        self.setupPlaylistGesture()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
        longPressRecognizer.cancelsTouchesInView = false
        self.swipeZone.addGestureRecognizer(longPressRecognizer)
        
    }
    override func viewDidAppear(_ animated: Bool){
        //updateUI()
        /**
        if(mediaItems == nil){
            let status = MPMediaLibrary.authorizationStatus()
            if(status == .authorized){
                if(player.nowPlayingItem != nil) {
                    updateUI()
                    //
                }
                if(MPMediaQuery.albums().items!.isEmpty) {
                    performSegue(withIdentifier: "noSongs", sender: nil)
                    return
                    
                }
                
                startPlaying()
                
                self.updateUI()
                
                self.loadPlaylists()
                self.playlistNameLabel.text = self.playlistNames[0]
                
                
                player.pause()
                
                
                
                
            } else {
                performSegue(withIdentifier: "noPermissions", sender: nil)
                print("returning")
                
            }
            
            
            setupSideMenu()
            
            self.setUI()
            
            print("visible")
        }
        
            
            
            
            
        
        
       */
       
       
        
    }
    
    
    
    
   
    
    
    
    
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer){
        
        if(sender.state == .began){
            print("longpressed")
            
            if(player.nowPlayingItem?.albumTitle != nil){
                let albumName:String = (player.nowPlayingItem?.albumTitle!)!
                
                let albumFilter = MPMediaQuery.albums().items?.filter({ (mod) -> Bool in
                    
                    
                    return (mod.albumTitle != nil && (mod.albumTitle?.lowercased().contains(albumName.lowercased()))!)
                })
                let albumFilterCount:Int = (albumFilter?.count)!
                if(albumFilterCount > 1){
                    performSegue(withIdentifier: "showAlbumView", sender:nil)
                }
            }
        }
    }
    
    
    fileprivate func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear

        
        
    }
    
    
    
    
    
    
    
    @IBAction fileprivate func changeSwitch(_ switchControl: UISwitch) {
        SideMenuManager.default.menuFadeStatusBar = switchControl.isOn
    }
    
    
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbumView"{
            if let nextViewController = segue.destination as? albumPopoverViewController{
                
                if(player.nowPlayingItem?.albumTitle != nil){
                    let albumName:String = (player.nowPlayingItem?.albumTitle!)!
                    let _:String = (player.nowPlayingItem?.artist!)!
                    
                    let albumFilter = MPMediaQuery.albums().items?.filter({ (mod) -> Bool in
                        
                        
                        return (mod.albumTitle != nil && mod.albumTitle?.lowercased() == (albumName.lowercased()))
                    })
                    nextViewController.songs = albumFilter
                    
                }
                
                
            }
        }
    }
 
    
    
    private func startPlaying(){
        print("starting to play")
        self.mediaItems = MPMediaQuery.albums().items!
        let mediaCollection = MPMediaItemCollection(items: self.mediaItems)
        self.player.setQueue(with: mediaCollection)
        
        player.prepareToPlay()
        player.pause()
        updateDuration()
    }
    
    
    
    
    @objc func updatePlaybackUI(){
        print("Updating Playback UI")
        if(player.playbackState == .paused || player.playbackState == .stopped || player.playbackState == .interrupted){
            print("The player is paused")
            backgroundShadowImage.layer.backgroundColor = UIColor(red:0.15, green:0.65, blue:0.93, alpha:1.0).cgColor
            timer.invalidate()
        } else if(player.playbackState == .playing ){
            print("The player is not paused")
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
            backgroundShadowImage.layer.backgroundColor = UIColor.clear.cgColor
            
        }
        
        
        
        
    }
    @objc private func updateDuration(){
         
        if (player.nowPlayingItem != nil && player.nowPlayingItem?.playbackDuration != nil) {
            durationSlider.maximumValue = Float((player.nowPlayingItem?.playbackDuration)!)
            durationSlider.setValue(Float(player.currentPlaybackTime), animated: false)
            
            currentTimeLabel.text = secondsToMinutesSeconds(seconds: Int(durationSlider.value))
            timeRemainingLabel.text = secondsToMinutesSeconds(seconds: Int(durationSlider.maximumValue-durationSlider.value))
        }
        
        
    }
    
    private func secondsToMinutesSeconds (seconds : Int) -> (String) {
        let minutes = String((seconds % 3600) / 60)
        var secondsString = String((seconds % 3600) % 60)
        
        if(secondsString.characters.count == 1 && ((seconds % 3600) % 60) > 10) {
            secondsString += "0"
        }else if (secondsString.characters.count == 1 && ((seconds % 3600) % 60) < 10){
            secondsString = "0" + secondsString
        }
        return minutes + ":" + secondsString
    }
    @objc private func setDurationValue(){
        player.currentPlaybackTime = TimeInterval(durationSlider.value)
    }
    
    var counter = 0
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        counter += 1
        
        if( counter % 2 == 1){
            player.play()
            print("playing")
            //player.playbackState = .playing
            backgroundShadowImage.layer.backgroundColor = UIColor.clear.cgColor
            
        }
        if(counter % 2 == 0){
            player.pause()
            print("paused")
            //player.playbackState = .paused
            backgroundShadowImage.layer.backgroundColor = UIColor(red:0.15, green:0.65, blue:0.93, alpha:1.0).cgColor
        }
        
        
    }
    
    @objc func handleSwipe( _ gesture: UISwipeGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                self.serverTimer.invalidate()
                player.skipToPreviousItem()
                
                print("going back")
            case UISwipeGestureRecognizerDirection.left:
                self.serverTimer.invalidate()
                player.skipToNextItem()
                
                print("going forward")
                
                
                
                
            default:
                break
            }
        }
        
        
        
        
    }
    
    func setUI(){
        print("setting UI")
        self.backgroundImage.image = #imageLiteral(resourceName: "BabyBlueAmbiant")
        self.playlistSelectorView.backgroundColor = UIColor(red:0.15, green:0.65, blue:0.93, alpha:1.0)
        self.playlistSelectorView.layer.cornerRadius = playlistSelectorView.frame.height/2
        albumArtImage.layer.cornerRadius = albumArtImage.frame.height/2
        albumArtImage.clipsToBounds = true
        
        
       
        /*
        //self.backgroundShadowImage.layer.cornerRadius = backgroundShadowImage.frame.height/2
        self.backgroundShadowImage.clipsToBounds = true
        self.backgroundShadowImage.layer.shadowColor = UIColor.black.cgColor
        self.backgroundShadowImage.layer.shadowOpacity = 0.6
        self.backgroundShadowImage.layer.shadowOffset = CGSize.zero
        self.backgroundShadowImage.layer.shadowRadius = 10
        self.backgroundShadowImage.layer.shadowPath = UIBezierPath(roundedRect: self.backgroundShadowImage.bounds, cornerRadius: self.backgroundShadowImage.frame.size.width/2).cgPath
       */
        
        self.backgroundShadowImage.layer.cornerRadius = backgroundShadowImage.frame.height/2
        self.backgroundShadowImage.clipsToBounds = true
        
        self.shuffleButton.layer.shadowColor = UIColor.black.cgColor
        self.shuffleButton.layer.shadowOffset =  CGSize(width: 5, height: 5)
        self.shuffleButton.layer.shadowRadius = 3
        self.shuffleButton.layer.shadowOpacity = 0.6
        
        
        self.repeatButton.layer.shadowColor = UIColor.black.cgColor
        self.repeatButton.layer.shadowOffset =  CGSize(width: 5, height: 5)
        self.repeatButton.layer.shadowRadius = 3
        self.repeatButton.layer.shadowOpacity = 0.6
        
        
        self.durationSlider.layer.shadowColor = UIColor.black.cgColor
        self.durationSlider.layer.shadowOffset =  CGSize(width: 5, height: 5)
        self.durationSlider.layer.shadowRadius = 3
        self.durationSlider.layer.shadowOpacity = 0.6
        
        
        self.volumeSlider?.layer.shadowColor = UIColor.black.cgColor
        self.volumeSlider?.layer.shadowOffset =  CGSize(width: 5, height: 5)
        self.volumeSlider?.layer.shadowRadius = 3
        self.volumeSlider?.layer.shadowOpacity = 0.6
        
        
        
        self.artistNameLabel?.layer.shadowColor = UIColor.black.cgColor
        self.artistNameLabel?.layer.shadowOffset =  CGSize(width: 5, height: 5)
        self.artistNameLabel?.layer.shadowRadius = 3
        self.artistNameLabel?.layer.shadowOpacity = 0.6
        
        
        self.songNameLabel?.layer.shadowColor = UIColor.black.cgColor
        self.songNameLabel?.layer.shadowOffset =  CGSize(width: 5, height: 5)
        self.songNameLabel?.layer.shadowRadius = 3
        self.songNameLabel?.layer.shadowOpacity = 0.6
        
        self.durationSlider.setThumbImage(UIImage(named: "sliderBar.png"), for: .normal)
        durationSlider.maximumTrackTintColor = UIColor(red:0.15, green:0.65, blue:0.93, alpha:1.0)
        durationSlider.minimumTrackTintColor = UIColor(red:0.15, green:0.65, blue:0.93, alpha:1.0)
        
        //sets the volume slider controller
        self.volumeView.backgroundColor = UIColor.clear
        self.volumeSlider = MPVolumeView(frame: self.volumeView.bounds)
        self.volumeView.addSubview(self.volumeSlider!)
        self.volumeSlider?.setVolumeThumbImage(UIImage(named: "sliderBar.png"), for: .normal)
        self.volumeSlider?.tintColor = UIColor(red:0.15, green:0.65, blue:0.93, alpha:1.0)
        
        self.shuffleButton.setImage(#imageLiteral(resourceName: "theShuffleButton"), for: .normal)
        
        
        
        let smartShuffleUnselected = #imageLiteral(resourceName: "brain").withRenderingMode(.alwaysOriginal)
        self.smartShuffleButton.setImage(smartShuffleUnselected, for: .normal)
        
        let repeatImageUnselected = #imageLiteral(resourceName: "repeat2").withRenderingMode(.alwaysOriginal)
        self.repeatButton.setImage(repeatImageUnselected, for: .normal)
        
        print("Setting UI is complete")
        
    }
    
    @IBAction func goNext(_ sender: Any) {
        player.skipToNextItem()
        
        
        
    }
    
    
    @IBAction func previous(_ sender: Any) {
        //
        print(MPNowPlayingInfoCenter.default().nowPlayingInfo)
    }
    @objc func updateServer(timer:Timer){
        /**
         print("the current playing song is " + (player.nowPlayingItem?.title)! + " while the song given is " + String(describing: timer.userInfo!))
         if((player.nowPlayingItem?.title)! == String(describing: timer.userInfo!)){
         let adress = serverController.checkLocation()
         print(adress)
         /**
         if(dataController.checkIfLocationExists(locationID: adress)){
         print("IT already exists! Putting data")
         let objectIDToAdd = dataController.getObjectID(locationID: adress)
         serverController.put(objectID: objectIDToAdd, songtoAdd: (player.nowPlayingItem?.title)!)
         
         
         } else {
         */
         print("it doesnt exist! Posting data")
         
         
         
         var songName = self.player.nowPlayingItem?.title
         var artistname = " "
         if(self.player.nowPlayingItem?.artist != nil){
         artistname = (self.player.nowPlayingItem?.artist)!
         }
         
         
         var albumName = " "
         if(self.player.nowPlayingItem?.albumTitle != nil){
         albumName = (self.player.nowPlayingItem?.albumTitle)!
         }
         
         var numberOfPlays:Int = 0
         if(self.player.nowPlayingItem?.playCount != nil){
         numberOfPlays = (self.player.nowPlayingItem?.playCount)!
         }
         
         var genre = " "
         if(self.player.nowPlayingItem?.genre != nil){
         genre = (self.player.nowPlayingItem?.genre)!
         }
         var newBpm:Int! = 0
         // self.serverController.postData(locationID: adress, songName: songName!, bpm: String(newBpm), artistName: artistname , albumName: albumName, numberOfPlays: String(numberOfPlays), genre: genre)
         //self.serverController.post2(genre: genre, numberOfPlays: String(numberOfPlays), albumName: albumName, artistName: artistname, bpm: String(newBpm), songName: songName!, locationName: adress)
         
         
         
         
         
         //serverController.postData(locationID: adress, songtoAdd: (player.nowPlayingItem?.title)!)
         
         //serverController.saveToCoreData()
         
         DispatchQueue.global().async {
         if(self.player.nowPlayingItem != nil){
         
         let url = self.player.nowPlayingItem?.assetURL
         _ = BPMAnalyzer.core.getBpmFrom(url!, completion: {[weak self] (bpm) in
         print("The current playing song is " + (self?.player.nowPlayingItem?.title!)! + " BPM Is " + bpm)
         
         if(String(bpm[9..<10]) == "."){
         newBpm = Int(bpm[7..<9])
         } else {
         newBpm = Int(bpm[7..<10])
         }
         
         
         print("the BPMMMM isss" + String(newBpm))
         //self?.serverController.post2(genre: genre, numberOfPlays: String(numberOfPlays), albumName: albumName, artistName: artistname, bpm: String(newBpm), songName: songName!, locationName: adress)
         
         
         
         })
         
         }
         
         }
         //}
         }
         
         
         */
    }
    
    var serverTimer:Timer = Timer()
    @objc func updateUI(){
        print("UpdateUI is called")
        if(player.nowPlayingItem == nil && MPMediaLibrary.authorizationStatus() == .authorized){
            print("Updating UI from nil")
            startPlaying()
            
            
        }
        if(player.nowPlayingItem != nil){
            print("Updating UI")
            let previousTitle = (player.nowPlayingItem?.title)!
            serverTimer =  Timer.scheduledTimer(timeInterval: ((player.nowPlayingItem?.playbackDuration)! / 2), target: self, selector:#selector(updateServer(timer:)), userInfo: previousTitle, repeats:false)
            
            
            //sets the album artwork
            if(player.nowPlayingItem?.artwork != nil){
                albumArtImage.image = player.nowPlayingItem?.artwork?.image(at: albumArtImage.frame.size)
                
            } else {
                let anImage = #imageLiteral(resourceName: "noArtworkFound")
                //anImage.sizeThatFits(albumArtImage.frame.size)
                albumArtImage.image = anImage
                
            }
            
            /// sets the name of the song
            if(player.nowPlayingItem?.title != nil){
                songNameLabel.text = player.nowPlayingItem?.title!
            }
            //sets the artist label
            if(player.nowPlayingItem?.albumTitle != nil && player.nowPlayingItem?.artist != nil ){
                artistNameLabel.text = (player.nowPlayingItem?.artist!)! + " - " + (player.nowPlayingItem?.albumTitle!)!
            } else if(player.nowPlayingItem?.albumTitle != nil && player.nowPlayingItem?.artist == nil ){
                artistNameLabel.text = player.nowPlayingItem?.albumTitle!
            } else if(player.nowPlayingItem?.albumTitle == nil && player.nowPlayingItem?.artist != nil ){
                artistNameLabel.text = player.nowPlayingItem?.artist!
            }
            
            print("Past")
            /**
             if(isSmartShuffling){
             DispatchQueue.global().async {
             if(self.player.nowPlayingItem != nil){
             
             let url = self.player.nowPlayingItem?.assetURL
             _ = BPMAnalyzer.core.getBpmFrom(url!, completion: {[weak self] (bpm) in
             print("The current playing song is " + (self?.player.nowPlayingItem?.title!)! + " BPM Is " + bpm)
             })
             
             }
             
             }
             
             }
             */
            
            
            
            ///This stuff doesnt work remove!
            
            
            
            if(Connectivity.isConnectedToInternet && isSmartShuffling) {
                let songName = self.player.nowPlayingItem?.title
                var artistname = " "
                if(self.player.nowPlayingItem?.artist != nil){
                    artistname = (self.player.nowPlayingItem?.artist)!
                }
                
                
                var albumName = " "
                if(self.player.nowPlayingItem?.albumTitle != nil){
                    albumName = (self.player.nowPlayingItem?.albumTitle)!
                }
                
                var numberOfPlays:Int! = 0
                if(self.player.nowPlayingItem?.playCount != nil){
                    numberOfPlays = (self.player.nowPlayingItem?.playCount)!
                }
                
                var genre = " "
                if(self.player.nowPlayingItem?.genre != nil){
                    genre = (self.player.nowPlayingItem?.genre)!
                }
                var newBpm:Int! = 0
                let adress = serverController.checkLocation()
                var numberOfSkips:Int! = 0
                numberOfSkips = (player.nowPlayingItem?.skipCount)!
                var duration:Int! = 0
                duration =   Int((player.nowPlayingItem?.playbackDuration)!)
                var lastPlayed = player.nowPlayingItem?.lastPlayedDate
                if(lastPlayed == nil){
                    lastPlayed = Date()
                }
                
                let calendar = NSCalendar.current
                let components = calendar.component(.hour, from: lastPlayed!)
                let lastHour:Int! = components
                
                
                
                
                print("IN -1")
                
                DispatchQueue.global().async {
                    print("IN 0")
                    //self.serverController.verifyUrl() &&
                    if( self.player.nowPlayingItem != nil){
                        print("IN 1")
                        let url = self.player.nowPlayingItem?.assetURL
                        if(url != nil){
                            print("In 2")
                            _ = BPMAnalyzer.core.getBpmFrom(url!, completion: {[weak self] (bpm) in
                                print("The current playing song is " + (self?.player.nowPlayingItem?.title!)! + " BPM Is " + bpm)
                                if(bpm != nil) {
                                    if(String(bpm[9..<10]) == "."){
                                        newBpm = Int(bpm[7..<9])
                                    } else {
                                        newBpm = Int(bpm[7..<10])
                                    }
                                }
                                if(newBpm != nil) {
                                    print("the last day is" + String(describing: lastPlayed))
                                    self?.serverController.post2(genre: genre, numberOfPlays: String(numberOfPlays), albumName: albumName, artistName: artistname, bpm: String(newBpm), songName: songName!, locationName: adress, numberOfSkips: String(numberOfSkips), duration: String(duration), lastPlayed: String(lastHour))
                                }
                            })
                        }
                        
                        
                    }
                    
                }
            }
            
            print("Done Updating UI")
        }
        

    }
    
    
    private func loadPlaylists() {
        self.mediaItems = MPMediaQuery.albums().items!
        self.playlistNames += ["No Playlist Selected"]
        self.playlistArray += [MPMediaItemCollection(items: self.mediaItems)]
        let myPlaylistsQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistsQuery.collections
        
        
        for aPlaylist in playlists! {
            
            let names:String = aPlaylist.value(forProperty: MPMediaPlaylistPropertyName)! as! String
            
            if(!aPlaylist.items.isEmpty) {
                self.playlistArray += [aPlaylist]
                self.playlistNames += [names]
            }
            
            
        }
    }
    
    func setupPlaylistGesture(){
        let playlistRight = UISwipeGestureRecognizer(target: self, action: #selector(self.playlistResponse))
        
        playlistRight.direction = UISwipeGestureRecognizerDirection.right
        playlistRight.cancelsTouchesInView = false
        self.playlistSelectorView.addGestureRecognizer(playlistRight)
        //self.view.addGestureRecognizer(swipeRight)
        
        let playlistLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.playlistResponse))
        playlistLeft.cancelsTouchesInView = false
        playlistLeft.direction = UISwipeGestureRecognizerDirection.left
        self.playlistSelectorView.addGestureRecognizer(playlistLeft)
        
    }
    
    var indx = 0
    
    @objc func playlistResponse(_ gesture: UISwipeGestureRecognizer) {
        print(indx)
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                indx += 1
                
                if(indx < (playlistNames.count - 1) && indx > 0){
                    self.playlistNameLabel.text =  "" + String(stringInterpolationSegment:playlistNames[indx])
                    self.player.setQueue(with: playlistArray[indx])
                    player.play()
                } else if(indx > (playlistNames.count - 1)){
                    indx = 0
                }
                
            case UISwipeGestureRecognizerDirection.right:
                indx -= 1
                
                if(indx < (playlistNames.count - 1) && indx > 0){
                    self.playlistNameLabel.text = String(stringInterpolationSegment:playlistNames[indx])
                    self.player.setQueue(with: playlistArray[indx])
                    player.play()
                } else if(indx > (playlistNames.count - 1) || indx < 0){
                    indx = 0
                }
            default:
                break
            }
        }
    }
    
    
    
    @IBAction func smartShufflePressed(_ sender: Any) {
        isSmartShuffling = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


