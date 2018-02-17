//
//  ViewController.swift
//  ipIqaD
//
//  Created by Daniel Dadap on 1/15/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var fontInstalledLabel: UILabel!
    @IBOutlet weak var installFontButton: UIButton!
    @IBOutlet weak var textArea: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabels), name: .UIApplicationWillEnterForeground, object: nil)
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func updateLabels() {
        if (pIqaDFontInstalled()) {
            fontInstalledLabel.text = "  "
            installFontButton.isHidden = true

            textArea.font = UIFont(name: "pIqaD qolqoS", size: 17)
            textArea.isHidden = false

            if (keyboardInstalled()) {
                if !textArea.isEditable {
                    textArea.text = "    "
                    textArea.isEditable = true
                }
            } else {
                textArea.text = """
                      \n
                 “Settings” “General:Keyboard:Keyboards” 
                 “Add New Keyboard…” 
                 “Third-Party Keyboards” “ipIqaD” \n
                
                """
                textArea.isEditable = false
            }
        } else {
            fontInstalledLabel.text = "pIqaDmey vItu'be'. →"
            installFontButton.isHidden = false
            if (keyboardInstalled()) {
                textArea.isHidden = true
            } else {
                textArea.text = """
                    Qagh! pIqaD SeHlaw vItu'be'. pIqaD SeHlaw yIcher!\n
                    1. “Settings”Daq “General:Keyboard:Keyboards” yI'el.
                    2. “Add New Keyboard…” yIwIv.
                    3. “Third-Party Keyboards”Daq “ipIqaD” yIchel.\n
                    Qapla'.
                    """
                textArea.isEditable = false
                textArea.isHidden = false
            }
        }
    }

    func keyboardInstalled() -> Bool {
        if let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] {
            if keyboards.contains("net.dadap.ipIqaD.pIqaD") {
                return true
            }
        }

        return false
    }

    func pIqaDFontInstalled() -> Bool {
        for family: String in UIFont.familyNames {
            let font = UIFont(name: family, size: 12)
            let charset = font?.fontDescriptor.object(forKey: .characterSet) as! NSCharacterSet
            let pIqaDchars = CharacterSet(charactersIn: "")

            if charset.isSuperset(of: pIqaDchars) {
                print("\(family)\n")
                return true
            }
        }
        return false
    }

    @IBAction func installProfile(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://dadap.github.io/pIqaD-tools/input-methods/iOS/install-font.html")!)
    }
}

