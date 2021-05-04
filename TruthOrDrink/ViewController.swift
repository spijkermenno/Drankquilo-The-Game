//
//  ViewController.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 26/04/2021.
//

import UIKit
import GoogleMobileAds
import FirebaseAnalytics
import StoreKit

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
    var playing = false
    var randomShot = false
    var showModeSelectionVar = false
    var removeAdsProduct: SKProduct!
    
    var gameRules = savedGameRules
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if StorageHelper().retrieveUUID() == "" {
            StorageHelper().setUUID(uuid: NSUUID().uuidString)
        }
    
        inAppPurchaseHelper.shared.getProducts {(result) in
            switch result {
                case .success(let products):
                    print(products)
                    self.removeAdsProduct = products.first
                case .failure(let error):
                    print(error)
            }
        }
                
        getRandomColor()
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getRandomColor), userInfo: nil, repeats: true)
        
        pussyModeButton.layer.cornerRadius = 30
        normalModeButton.layer.cornerRadius = 30
        hardModeButton.layer.cornerRadius = 30
        
        playButton.contentHorizontalAlignment = .center
                
        adview.adUnitID = "ca-app-pub-4928043878967484/9103848063"
        adview.rootViewController = self
        adview.load(GADRequest())
        
        if removeAdsProduct != nil {
            showAlert(for: removeAdsProduct)
        }
    }
    
    func showAlert(for product: SKProduct) {
        guard let price = inAppPurchaseHelper.shared.getPriceFormatted(for: product) else { return }
        let alertController = UIAlertController(title: product.localizedTitle,
                                                message: product.localizedDescription,
                                                preferredStyle: .alert)
     
        alertController.addAction(UIAlertAction(title: "Buy now for \(price)", style: .default, handler: { (_) in
            // TODO: Initiate Purchase!
        }))
     
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setGameRules() {
        gameRules = savedGameRules
        
        for question in StorageHelper().retrieveFromLocalStorage() {
            gameRules.append(question)
        }
        
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
    
    @IBAction func tapHandler(_ sender: Any) {
        if playing {
            clickNewText(playButton)
        }
    }
    
    @IBAction func clickNewText(_ sender: UIButton) {
        playing = true
        var rand: Int!
        if level == 3 {
            rand = Int.random(in: 1..<25)
        } else {
            rand = Int.random(in: 1..<50)
        }
        if showModeSelectionVar {
            showModeSelection()
            showModeSelectionVar = false
        } else {
            if rand == 1 && !randomShot && level > 1 {
                sender.animateHidden(false)
                sender.setTitle("Iedereen gooit een atje!", for: .normal)
                
                shotsCounterLabel.animateHidden(false)
                shotsCounterLabel.text = "GEPRANKT"
                
                pussyModeButton.animateHidden(true)
                normalModeButton.animateHidden(true)
                hardModeButton.animateHidden(true)
                chooseModeLabel.animateHidden(true)
                
                closeButton.animateHidden(false)
                adview.animateHidden(false)
                orLabel.animateHidden(true)
                randomShot = true
            } else {
                randomShot = false
                if gameRules.count > 0 {
                    let id = Int.random(in: 0..<gameRules.count)
                    sender.animateHidden(false)
                    sender.setTitle(gameRules[id], for: .normal)
                    gameRules.remove(at: id)
                    
                    shotsCounterLabel.text = generateDrinks()
                    shotsCounterLabel.animateHidden(false)
                    
                    pussyModeButton.animateHidden(true)
                    normalModeButton.animateHidden(true)
                    hardModeButton.animateHidden(true)
                    chooseModeLabel.animateHidden(true)
                    
                    closeButton.animateHidden(false)
                    adview.animateHidden(false)
                    orLabel.animateHidden(false)
                } else {
                    sender.setTitle("Klaar! Opnieuw beginnen? klik hier.", for: .normal)
                    shotsCounterLabel.animateHidden(true)
                    orLabel.animateHidden(true)
                    adview.animateHidden(true)
                    showModeSelectionVar = true
                    closeButton.animateHidden(true)
                }
            }
        }
    }
    @IBAction func scrollBackGesture(_ sender: Any) {
        showModeSelection()
    }
    
    func showModeSelection() {
        playButton.animateHidden(true)
        orLabel.animateHidden(true)
        adview.animateHidden(true)
        closeButton.animateHidden(true)
        shotsCounterLabel.animateHidden(true)
        
        pussyModeButton.animateHidden(false)
        normalModeButton.animateHidden(false)
        hardModeButton.animateHidden(false)
        chooseModeLabel.animateHidden(false)
        
        playing = false
        
        setGameRules()
    }
        
    @objc func getRandomColor() {
        DispatchQueue.main.async {
            let hue = CGFloat(arc4random_uniform(361)) / 360.0
                        
            UIView.animateKeyframes(withDuration: 5, delay: 0, options: [.allowUserInteraction], animations: {
                self.view.backgroundColor = UIColor(hue: hue, saturation: 0.75, brightness: 1, alpha: 1)
            }, completion: nil)
        }
    }
}

extension UIView {
    func animateHidden(_ hidden: Bool) {
            if self.isHidden && !hidden {
                self.alpha = 0.0
                self.isHidden = false
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = hidden ? 0.0 : 1.0
            }) { (complete) in
                self.isHidden = hidden
            }
        
    }
}
