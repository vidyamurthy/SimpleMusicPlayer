//
//  ViewController.swift
//  SampleMusicPlayer
//
//  Created by Vidya Murthy on 05/04/17.
//  Copyright © 2017 Vidya Murthy. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tileImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    var audioPlayer = AVAudioPlayer()
    var isPlayingAudio = false
    var timer: Timer!
    var tracks: [String] = ["BadriKiDulhania", "Belageddu", "Bulleya", "KatheyondaHelide", "NeenireSaniha", "Sahiba", "ThirbokiJeevana", "UffYehNoor", "Cold", "SomethingJustLikeThis"]
    var currentTrack : Int = -1
    var trackInfo: [String: AnyObject] = [:]
    
    //To keep track of the UI
    enum PlayerState {
        case Play
        case Pause
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialise all values to default
        timeSlider.value = 0.0
        tileImageView.image = UIImage(named: "defaultImage")
        backgroundImageView.image = UIImage(named: "defaultImage")
        songLabel.text = ""
        artistLabel.text = ""
        albumLabel.text = ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playOrPauseAudio(_ sender: Any) {
        
        if (isPlayingAudio) {
            //Pause
            audioPlayer.pause()
            updatePlayButtonFor(playerState: .Pause)
            isPlayingAudio = false
        }
        else {
            //Play
            //Check if it is the very first call
            if currentTrack == -1 {
                let index = getRandomTrackIndex()
                preparePlayerFor(trackIndex: index)
            }
            //If not, continue playing the existing track
            else {
                audioPlayer.play()
                updatePlayButtonFor(playerState: .Play)
                isPlayingAudio = true
            }
        }
    }

    @IBAction func timeSliderValueChanged(_ sender: Any) {
        //Stop and seek the audio track; update the UI if needed
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(timeSlider.value)
        audioPlayer.play()
        updatePlayButtonFor(playerState: .Play)
    }
    
    //Update the slider and elapsed time values
    func updateTimeValues() {
        timeSlider.value = Float(audioPlayer.currentTime)
        elapsedTimeLabel.text = getDisplayValuefor(time: Int(audioPlayer.currentTime))
    }
    
    //Refresh the player for each track
    func preparePlayerFor(trackIndex: Int) {
        currentTrack = trackIndex
        //Get the track URL
        let trackPath = Bundle.main.path(forResource: "\(tracks[trackIndex])", ofType: ".mp3")
        do {
            //Initialise the values of the player
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: trackPath!))
            timeSlider.maximumValue = Float(audioPlayer.duration)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.updateTimeValues()
            })
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            //Update all the UI values
            self.updatePlayButtonFor(playerState: .Play)
            self.getTrackInfoFor(url: URL(fileURLWithPath: trackPath!))
            audioPlayer.play()
            isPlayingAudio = true
        }
        catch {
            print("Unable to load the track file")
        }
    }
    
    //Chenge the button image to play / pause as required based on the enum value
    func updatePlayButtonFor(playerState: PlayerState) {
        switch playerState {
        case .Play: playPauseButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
            break
        case .Pause: playPauseButton.setImage(UIImage(named: "playIcon"), for: .normal)
            break
        }
    }
    
    //Returns appropriate string value to display for time
    func getDisplayValuefor(time: Int) -> String {
        let minutes = time / 60
        let seconds = time - minutes * 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //Returns a random track index
    func getRandomTrackIndex() -> Int {
        return Int(arc4random_uniform(UInt32(tracks.count)))
    }
    
    //Returns the metadata for a specific track
    func getTrackInfoFor(url: URL) {
        var title = ""
        var artist = ""
        var album = ""
        var image : UIImage? = nil
        
        let trackItem = AVPlayerItem(url: url)
        let metadataList : [AVMetadataItem] = trackItem.asset.metadata
        //Check for basic metadata in the list
        for item in metadataList {
            if item.commonKey != nil && item.value != nil {
                if item.commonKey  == "title" {
                    title = item.stringValue!
                }
                if item.commonKey  == "albumName" {
                    album = item.stringValue!
                }
                if item.commonKey   == "artist" {
                    artist = item.stringValue!
                }
                if item.commonKey  == "artwork" {
                    if let artwork = UIImage(data: item.value as! Data) {
                        image = artwork
                    }
                }
            }
        }
        songLabel.text = title
        artistLabel.text = artist
        albumLabel.text = album
        totalTimeLabel.text = getDisplayValuefor(time: Int(audioPlayer.duration))
        
        if image != nil {
            tileImageView.image = image
            backgroundImageView.image = image
        }
        else {
            tileImageView.image = UIImage(named: "defaultImage")
            backgroundImageView.image = UIImage(named: "defaultImage")
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        preparePlayerFor(trackIndex: getRandomTrackIndex())
    }
}
