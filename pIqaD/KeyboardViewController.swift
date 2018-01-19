//
//  KeyboardViewController.swift
//  pIqaD
//
//  Created by Daniel Dadap on 1/15/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    let backspaceName = "⇦"
    let switchName = ""
    let spaceName = ""
    let enterName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyNames = [["", "", "", "", "", "", "", "", "", ""],
                        ["", "", "", "", "", "", "", "", "", ""],
                        ["", "", "", "", "", "", "", "", "", ""],
                        ["", "", "", "", "", "", "", "", "", backspaceName],
                        [switchName, spaceName, enterName]
        ]
        let keyRows = UIStackView()
        keyRows.axis = .vertical
        keyRows.translatesAutoresizingMaskIntoConstraints = false
        
        for nameRow in keyNames {
            let keys = makeKeys(names: nameRow)
            let row = UIStackView(arrangedSubviews: keys)
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.alignment = .fill
            row.translatesAutoresizingMaskIntoConstraints = false
            row.sizeToFit()
            keyRows.addArrangedSubview(row)
        }
        
        keyRows.sizeToFit()
        self.view.addSubview(keyRows)
        
        let viewsDictionary = ["keyRows":keyRows]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyRows]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[keyRows]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)
    }
    
    func makeKeys(names: [String]) -> [UIButton] {
        var keys = [UIButton]()
        
        for name in names {
            let key = UIButton(type: .system)
            key.setTitle(name, for: [])

            if (name == switchName) {
                self.nextKeyboardButton = key
                key.addTarget(self, action: #selector(switchKey(sender:forEvent:)), for: .allTouchEvents)
            } else {
                key.addTarget(self, action: #selector(keyUp(sender:)), for: .touchUpInside)
            }
            keys.append(key)
        }
        
        return keys
    }
    
    @IBAction func switchKey(sender: UIButton, forEvent event: UIEvent) {
        handleInputModeList(from: sender, with: event)
    }
    
    @IBAction func keyUp(sender: UIButton) {
        let name = sender.title(for: .normal)
        
        if (name == backspaceName) {
            (textDocumentProxy as UIKeyInput).deleteBackward()
        } else if (name == spaceName) {
            (textDocumentProxy as UIKeyInput).insertText(" ")
        } else if (name == enterName) {
            (textDocumentProxy as UIKeyInput).insertText("\n")
        } else {
            (textDocumentProxy as UIKeyInput).insertText(name!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
