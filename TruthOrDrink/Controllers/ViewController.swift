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
    @IBOutlet var rulesLabel: UILabel!
    @IBOutlet var pussyLabel: UILabel!
    @IBOutlet var funLabel: UILabel!
    @IBOutlet var spicyLabel: UILabel!
    
    @IBOutlet var pussyModeButton: UIButton!
    @IBOutlet var normalModeButton: UIButton!
    @IBOutlet var hardModeButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var rulesButton: UIButton!
    @IBOutlet var removeAdsButton: UIButton!
    
    var spinnerView: UIView!
    var ai: UIActivityIndicatorView!
    
    var level = 2
    var playing = false
    var randomShot = false
    var showModeSelectionVar = false
    
    var viewModel = PurchasableViewModel()
    var showAds = true
    
    var isSpinning = false
    
    var gameRules: [String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.UUID) == "" {
            StorageHelper().saveToLocalStorage(string: NSUUID().uuidString, storageType: StorageIdentifier.UUID)
        }
        
        Analytics.setUserID(StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.UUID))
    
        getRandomColor()
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getRandomColor), userInfo: nil, repeats: true)
        
        pussyModeButton.layer.cornerRadius = 30
        normalModeButton.layer.cornerRadius = 30
        hardModeButton.layer.cornerRadius = 30
        
        playButton.contentHorizontalAlignment = .center
                
        adview.adUnitID = "ca-app-pub-4928043878967484/9103848063"
        adview.rootViewController = self
        adview.load(GADRequest())
        
        setGameRules()
    }
    
    func checkPurchaseUpgrade() -> Void {
        // check if non consumable was bought.
        
        print("are ads removed? \(viewModel.removedAds)")
        
        if !viewModel.removedAds {
            adview.adUnitID = "ca-app-pub-4928043878967484/9103848063"
            adview.rootViewController = self
            adview.load(GADRequest())
            
            adview.isHidden = false
            removeAdsButton.isHidden = false
            
            showAds = true
        } else {
            adview.isHidden = true
            removeAdsButton.isHidden = true
            showAds = false
        }
    }
    
    func setGameRules() {
        gameRules.removeAll()
        let storedQuestions: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Questions)
        let storedCommands: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Commands)

        var FullQuestionsList = questions
        var FullCommandsList = commands
        
        for question in storedQuestions {
            FullQuestionsList.append(question)
        }
        
        for command in storedCommands {
            FullCommandsList.append(command)
        }
        
        for _ in 1...20 {
            gameRules.append(FullQuestionsList.removeRandom()!)
        }
        
        for _ in 1...5 {
            gameRules.append(FullCommandsList.removeRandom()!)
        }
        
        Analytics.logEvent("reset_gamerules", parameters: ["error": false])
    }
    
    @IBAction func rulesButtonTap(_ sender: UIButton) {
        if let url = URL(string: "https://ondergrondseontwikkeling.nl/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func returnButtonTap(_ sender: UIButton) {
        showModeSelection()
        Analytics.logEvent("return_to_selection", parameters: ["error": false])
    }
    
    @IBAction func pussyModeButtonTap(_ sender: UIButton) {
        level = 1
        setGameRules()
        clickNewText(playButton)
        Analytics.logEvent("gamemode_select", parameters: ["type": "pussymode"])
    }
    
    @IBAction func normalModeButtonTap(_ sender: UIButton) {
        level = 2
        setGameRules()
        clickNewText(playButton)
        Analytics.logEvent("gamemode_select", parameters: ["type": "normalmode"])
    }
    
    @IBAction func hardModeButtonTap(_ sender: UIButton) {
        level = 3
        setGameRules()
        clickNewText(playButton)
        Analytics.logEvent("gamemode_select", parameters: ["type": "diehardmode"])
    }
    
    @IBAction func removeAdsTap(_ sender: Any) {
        //
        
        openPurchaseRequest(self)
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
                drinkLiteral = "1 mega-punt"
            } else if type == 2 {
                // sips
                amount = Int.random(in: 1..<4)
                drinkLiteral = "\(String(describing: amount!)) punten"
            }
        
        case 3: // DieHard Mode
            // 4 to 8 sips, 2 to 4 shots
            
            if type == 1 {
                // shots
                amount = Int.random(in: 2..<5)
                if amount == 1 {
                    drinkLiteral = "\(String(describing: amount!)) mega-punt"
                } else {
                    drinkLiteral = "\(String(describing: amount!)) mega-punten"
                }
            } else if type == 2 {
                // sips
                amount = Int.random(in: 4..<11)
                drinkLiteral = "\(String(describing: amount!)) punten"
            }
        
        default: // Normal mode
            // 2 to 6 sips, 1 or 2 shots
            
            if type == 1 {
                // shots
                amount = Int.random(in: 1..<3)
                if amount == 1 {
                    drinkLiteral = "\(String(describing: amount!)) mega-punt"
                } else {
                    drinkLiteral = "\(String(describing: amount!)) mega-punten"
                }
            } else if type == 2 {
                // sips
                amount = Int.random(in: 2..<7)
                drinkLiteral = "\(String(describing: amount!)) punten"
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
    
    func gameRunning() {
        pussyModeButton.animateHidden(true)
        normalModeButton.animateHidden(true)
        rulesButton.animateHidden(true)
        hardModeButton.animateHidden(true)
        chooseModeLabel.animateHidden(true)
        rulesLabel.animateHidden(true)
        closeButton.animateHidden(false)
        orLabel.animateHidden(false)
        
        pussyLabel.animateHidden(true)
        funLabel.animateHidden(true)
        spicyLabel.animateHidden(true)
                
        if self.viewModel.removedAds {
            removeAdsButton.animateHidden(true)
            adview.animateHidden(true)
        } else {
            removeAdsButton.animateHidden(false)
            adview.animateHidden(false)
        }
    }
    
    func gameEnded() {
        showModeSelectionVar = true

        shotsCounterLabel.animateHidden(true)
        orLabel.animateHidden(true)
        adview.animateHidden(true)
        closeButton.animateHidden(true)
        rulesButton.animateHidden(true)
        rulesLabel.animateHidden(true)
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
                sender.setTitle("Iedereen doet een atje!", for: .normal)
                
                shotsCounterLabel.animateHidden(false)
                shotsCounterLabel.text = "GEPRANKT"
                
                Analytics.logEvent("pranked", parameters: ["type": "atje"])
                
                gameRunning()
                
                randomShot = true
            } else {
                randomShot = false
                if gameRules.count > 0 {
                    sender.animateHidden(false)
                    
                    let play = gameRules.removeRandom()!
                    
                    if play.contains("?") {
                        orLabel.text = "of antwoord de volgende vraag"
                    } else {
                        orLabel.text = "of voer deze opdracht uit"
                    }
                    
                    sender.setTitle(play, for: .normal)
                    
                    shotsCounterLabel.text = generateDrinks()
                    shotsCounterLabel.animateHidden(false)
                    
                    gameRunning()
                } else {
                    sender.setTitle("Klaar! Opnieuw beginnen? klik hier.", for: .normal)
                    Analytics.logEvent("finished_game", parameters: ["error": false])
                    gameEnded()
                }
            }
        }
    }
    @IBAction func scrollBackGesture(_ sender: Any) {
        showModeSelection()
        Analytics.logEvent("scroll_back", parameters: ["error": false])

    }
    
    func showModeSelection() {
        playButton.animateHidden(true)
        orLabel.animateHidden(true)
        closeButton.animateHidden(true)
        shotsCounterLabel.animateHidden(true)
        
        pussyModeButton.animateHidden(false)
        normalModeButton.animateHidden(false)
        hardModeButton.animateHidden(false)
        chooseModeLabel.animateHidden(false)
        
        pussyLabel.animateHidden(false)
        funLabel.animateHidden(false)
        spicyLabel.animateHidden(false)
        
        playing = false
        
        setGameRules()
    }
    
    func openPurchaseRequest(_ context: Any) -> Void {
        IAPManager.shared.getProducts { (result) in
            switch result {
            case .success(let products):
                let product = products.first!
                
                let alert = UIAlertController(title: "Advertenties?!", message: "Wil je advertenties verwijderen en de ontwikkelaar steunen? \n\n Dit kan voor maar \(IAPManager.shared.getPriceFormatted(for: product)!).", preferredStyle: .alert)
                
                alert.addAction(
                    UIAlertAction(
                        title: "Sluiten",
                        style: .destructive,
                        handler: {(alert: UIAlertAction!) in
                            return
                        }
                    )
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "Aankoop herstellen",
                        style: .destructive,
                        handler: {(alert: UIAlertAction!) in
                            print("restore button")
                            self.viewModel.restorePurchases(self)
                        }
                    )
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "Verwijder advertenties",
                        style: .cancel,
                        handler: {(alert: UIAlertAction!) in
                            // starting transaction
                            if !self.viewModel.purchase(product: product, context: self) {
                                self.showSingleAlert(withMessage: "In-App aankopen zijn niet toegestaan op dit apparaat.")
                            } else {
                                self.checkPurchaseUpgrade()
                            }
                        }
                    )
                )
                
                DispatchQueue.main.async {
                    if let ctx = context as? ViewController {
                        ctx.present(alert, animated: true)
                    }
                }
            case .failure(let error):
                print("IAP ERROR")
                DispatchQueue.main.async {
                    self.showIAPRelatedError(error)
                }
            }
        }
    }
        
    func showSingleAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Tranquilo", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

extension ViewController: ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool) {
        isSpinning = !shouldShow
        toggleSpinner(onView: view)
    }
    
    func willStartLongProcess() {
        print("Long process start")
        isSpinning = false
        toggleSpinner(onView: view)
    }
    
    func didFinishLongProcess() {
        print("Long process end")
        isSpinning = true
        toggleSpinner(onView: view)
    }
    
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        removeAdsButton.isHidden = true
        
        print(error.localizedDescription)
        
        showSingleAlert(withMessage: message)
    }
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "There are no purchased items to restore.")
    }
    
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "All previous In-App Purchases have been restored!")
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

extension Array {
    mutating func removeRandom() -> Element? {
        if let index = indices.randomElement() {
            return remove(at: index)
        }
        return nil
    }
}

var vSpinner : UIView?

extension ViewController {
    
    func toggleSpinner(onView: UIView) {
        
        print("Is spinning: \(self.isSpinning)")
        
        if self.isSpinning {
            // remove spinner
            DispatchQueue.main.async {
                vSpinner?.removeFromSuperview()
                vSpinner = nil
                self.isSpinning = false
            }
        } else {
            // place spinner
            self.spinnerView = UIView.init(frame: onView.bounds)
            self.spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            self.ai = UIActivityIndicatorView.init(style: .large)
            self.ai.startAnimating()
            self.ai.center = self.spinnerView.center
            
            DispatchQueue.main.async {
                self.spinnerView.addSubview(self.ai)
                onView.addSubview(self.spinnerView)
                self.isSpinning = true
            }
            vSpinner = self.spinnerView
        }
    }
}
