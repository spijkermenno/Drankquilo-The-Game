//
//  ViewController.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 26/04/2021.
//

import UIKit
import GoogleMobileAds
import FirebaseAnalytics

class ViewController: UIViewController {
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var shotsCounterLabel: UILabel!
    @IBOutlet var orLabel: UILabel!
    @IBOutlet var chooseModeLabel: UILabel!
    @IBOutlet var adview: GADBannerView!
    
    @IBOutlet var pussyModeButton: UIButton!
    @IBOutlet var normalModeButton: UIButton!
    @IBOutlet var hardModeButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    var level = 2
    var showModeSelectionVar = false
    
    var gameRules = savedGameRules
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRandomColor()
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getRandomColor), userInfo: nil, repeats: true)
        
        pussyModeButton.layer.cornerRadius = 30
        normalModeButton.layer.cornerRadius = 30
        hardModeButton.layer.cornerRadius = 30
        
        playButton.contentHorizontalAlignment = .center
                
        adview.adUnitID = "ca-app-pub-4928043878967484/9103848063"
        adview.rootViewController = self
        adview.load(GADRequest())
    }
    
    func setGameRules() {
        gameRules = savedGameRules
        
        Analytics.logEvent("reset_gamerules", parameters: ["error": false])
    }
    @IBAction func returnButtonTap(_ sender: UIButton) {
        showModeSelection()
    }
    
    @IBAction func pussyModeButtonTap(_ sender: UIButton) {
        level = 1
        clickNewText(playButton)
        Analytics.logEvent("gamemode_select", parameters: ["type": "pussymode"])
    }
    
    @IBAction func normalModeButtonTap(_ sender: UIButton) {
        level = 2
        clickNewText(playButton)
        Analytics.logEvent("gamemode_select", parameters: ["type": "normalmode"])
    }
    
    @IBAction func hardModeButtonTap(_ sender: UIButton) {
        level = 3
        clickNewText(playButton)
        Analytics.logEvent("gamemode_select", parameters: ["type": "diehardmode"])
    }
    
    func generateDrinks() -> String {
        var drinkLiteral: String!
        var amount: Int!
        let type = Int.random(in: 1..<3) // 1 = shot, 2 = sip
        
        switch level {
        case 1: // Pussy mode
            // 1 to 3 sips, 1 shot
            
            if type == 1 {
                // shots
                amount = 1
                drinkLiteral = "1 shot"
            } else if type == 2 {
                // sips
                amount = Int.random(in: 1..<4)
                drinkLiteral = "\(String(describing: amount!)) slokken"
            }
        
        case 3: // DieHard Mode
            // 4 to 8 sips, 2 to 4 shots
            
            if type == 1 {
                // shots
                amount = Int.random(in: 2..<5)
                if amount == 1 {
                    drinkLiteral = "\(String(describing: amount!)) shot"
                } else {
                    drinkLiteral = "\(String(describing: amount!)) shots"
                }
            } else if type == 2 {
                // sips
                amount = Int.random(in: 4..<11)
                drinkLiteral = "\(String(describing: amount!)) slokken"
            }
        
        default: // Normal mode
            // 2 to 6 sips, 1 or 2 shots
            
            if type == 1 {
                // shots
                amount = Int.random(in: 1..<3)
                if amount == 1 {
                    drinkLiteral = "\(String(describing: amount!)) shot"
                } else {
                    drinkLiteral = "\(String(describing: amount!)) shots"
                }
            } else if type == 2 {
                // sips
                amount = Int.random(in: 2..<7)
                drinkLiteral = "\(String(describing: amount!)) slokken"
            }
        }
        
        Analytics.logEvent(
            "click",
            parameters: [
                "available_questions": gameRules.count,
                "amount_to_be_drank": amount!,
                "type_to_drink": type
            ]
        )
        
        return drinkLiteral
    }
    
    @IBAction func clickNewText(_ sender: UIButton) {
        if showModeSelectionVar {
            showModeSelection()
            showModeSelectionVar = false
        } else {
            if gameRules.count > 0 {
                let id = Int.random(in: 0..<gameRules.count)
                sender.isHidden = false
                sender.setTitle(gameRules[id], for: .normal)
                gameRules.remove(at: id)
                
                shotsCounterLabel.text = generateDrinks()
                shotsCounterLabel.isHidden = false
                
                pussyModeButton.isHidden = true
                normalModeButton.isHidden = true
                hardModeButton.isHidden = true
                chooseModeLabel.isHidden = true
                
                closeButton.isHidden = false
                adview.isHidden = false
                orLabel.isHidden = false
            } else {
                sender.setTitle("Klaar! Opnieuw beginnen? klik hier.", for: .normal)
                shotsCounterLabel.isHidden = true
                orLabel.isHidden = true
                adview.isHidden = true
                showModeSelectionVar = true
                closeButton.isHidden = true
            }
        }
    }
    
    func showModeSelection() {
        playButton.isHidden = true
        orLabel.isHidden = true
        adview.isHidden = true
        closeButton.isHidden = true
        shotsCounterLabel.isHidden = true
        
        pussyModeButton.isHidden = false
        normalModeButton.isHidden = false
        hardModeButton.isHidden = false
        chooseModeLabel.isHidden = false
        
        setGameRules()
    }
        
    @objc func getRandomColor() {
        DispatchQueue.main.async {
            let hue = CGFloat(arc4random_uniform(361)) / 360.0
                        
            UIView.animateKeyframes(withDuration: 5, delay: 0, options: [.allowUserInteraction], animations: {
                self.view.backgroundColor = UIColor(hue: hue, saturation: 0.66, brightness: 1, alpha: 0.9)
            }, completion: nil)
        }
    }
}

