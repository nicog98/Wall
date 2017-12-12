//
//  MusicWallCollectionViewCell.swift
//  Wall
//
//  Collection View Cell to hold a song, and play/pause that song when selected
//
//  APIs Used:
//      AVAudioPlayer 2 - Stores a queue of songs and plays/pauses them upon tap
//
//  Created by Nicolai Garcia on 11/30/17.
//  Copyright © 2017 Nicolai Garcia. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVKit

class MusicWallCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
    
    func play() {
        if !player.isPlaying {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                player.play()
            } catch {
                print("Could not set audio session category")
            }
        } else {
            player.pause()
        }
    }
    
    var player = AVAudioPlayer()
    
    @IBOutlet weak var imageView: UIImageView!
    
    var song: AVPlayerItem?
    
    func fetchSong(songURL: URL) {
        do {
            try player = AVAudioPlayer(contentsOf: songURL)
        } catch {
            print("Could not play song with url: \(songURL)")
        }
    }
    
}
