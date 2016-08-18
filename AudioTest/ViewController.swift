//
//  ViewController.swift
//  AudioTest
//
//  Created by hurryhx on 8/17/16.
//  Copyright © 2016 hurryhx. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    @IBOutlet var startButton: UIButton!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var amplitudeLabel: UILabel!
    @IBOutlet var noteNameWithSharpsLabel: UILabel!
    @IBOutlet var noteNameWithFlatsLabel: UILabel!
    @IBOutlet var pitchTestLabel: UILabel!
    @IBOutlet var audioInputPlot: AKNodeFFTPlot!
    
    @IBAction func startOrStop(sender: UIButton) {
        if (tracker.isStarted) {
            tracker.stop()
            mic.stop()
            startButton.setTitle(String("START"), forState: .Normal)
        } else {
            mic.start()
            tracker.start()
            startButton.setTitle(String("STOP"), forState: .Normal)
        }
    }
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var diceroll: Int = 0
    
    let noteFrequencies = [16.352,17.324,18.354,19.445,20.602,21.827,23.125,24.500,25.957,27.500,29.135,30.868]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","H"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B","H"]
    
    func setupPlot() {
        let plot = AKNodeFFTPlot(mic, frame:audioInputPlot.bounds, bufferSize: 1024)
        plot.plotType = .Buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.redColor()
        audioInputPlot.addSubview(plot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
        
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0 ? true : false
    }
    
    func rollNextPitch(sharp: Bool) {
        diceroll = Int(arc4random_uniform(12))
        if (sharp) {
            pitchTestLabel.text = noteNamesWithSharps[diceroll]
        } else {
            pitchTestLabel.text = noteNamesWithFlats[diceroll]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        rollNextPitch(randomBool())
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil,
            repeats: true)
    }
    
    func updateUI() {
        if tracker.amplitude > 0.11 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            
            
            var frequency = Float(tracker.frequency)
            var guardbool = false
            while frequency > Float(noteFrequencies[noteFrequencies.count-1] as NSNumber) {
                frequency = frequency / 2.0
                guardbool = true
            }
            
            while (frequency < Float(noteFrequencies[0] as NSNumber) && guardbool == false) {
                frequency = frequency * 2.0
            }
            
            var min : Float = 1000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i] as NSNumber) - frequency)
                if (distance < min) {
                    index = i
                    min = distance
                }
                
            }
            if (index == diceroll) {
                rollNextPitch(randomBool())
            }
            let octave = Int(log2f(Float(tracker.frequency)/frequency))
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            
        }
        amplitudeLabel.text = String(format: "%0.1f", tracker.amplitude)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

