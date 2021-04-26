//
//  ViewController.swift
//  TruthOrDrink
//
//  Created by Menno Spijker on 26/04/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var gameRule: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.newText))
        self.view.addGestureRecognizer(gesture)
        
        getRandomColor()
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getRandomColor), userInfo: nil, repeats: true)

    }
    
    @objc func newText(sender: UITapGestureRecognizer) {
        print("lol")
        let id = Int.random(in: 0..<gameRules.count)
        gameRule.text = gameRules[id]
        gameRules.remove(at: id)
    }
        
    @objc func getRandomColor() {
        let hue = CGFloat(arc4random_uniform(361)) / 360.0
        
        UIView.animate(withDuration: 10, delay: 0.0, options:[.repeat, .autoreverse], animations: {
            self.view.backgroundColor = UIColor(hue: hue, saturation: 0.66, brightness: 1, alpha: 1)
        }, completion:nil)
    }
}

