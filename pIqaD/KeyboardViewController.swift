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
    let spaceName = ""
    let enterName = ""

    let bgColor = UIColor.lightGray
    let labelColor = UIColor.red

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

        self.view.backgroundColor = bgColor

        let viewsDictionary = ["keyRows":keyRows]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyRows]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[keyRows]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)
    }
    
    func makeKeys(names: [String]) -> [UIButton] {
        var keys = [UIButton]()
        
        for name in names {
            let key = UIButton(type: .custom)
            key.setTitle(name, for: [])
            key.titleLabel?.font = UIFont(name: "Klingonpiqadhasta", size: 24)
            key.setTitleColor(labelColor, for: .normal)
            key.backgroundColor = bgColor

            if (name == switchName) {
                self.nextKeyboardButton = key
                key.addTarget(self, action: #selector(switchKey(sender:forEvent:)), for: .allTouchEvents)
                if (self.needsInputModeSwitchKey) {
                    keys.append(key)
                }
            } else {
                if (name == enterName) {
                    key.backgroundColor = labelColor
                    key.setTitleColor(bgColor, for: .normal)
                }
                key.addTarget(self, action: #selector(keyUp(sender:)), for: .touchUpInside)
                key.addTarget(self, action: #selector(keyDown(sender:)), for: .touchDown)
                key.addTarget(self, action: #selector(slideIn(sender:)), for: .touchDragEnter)
                key.addTarget(self, action: #selector(slideOut(sender:)), for: .touchDragExit)

                keys.append(key)
            }
        }
        
        return keys
    }

    func isPrintable(key: UIButton) -> Bool {
        return key.currentTitle?.count == 1 && key.currentTitle != backspaceName
    }

    func popOut(key: UIButton) {
        key.backgroundColor = .white

        if (isPrintable(key: key)) {
            UIView.animate(withDuration: 0.04, animations: {
                key.transform = CGAffineTransform(a: 1.25, b: 0, c: 0, d: 1.25, tx: 0, ty: -39)
            })
        }
    }

    func popIn(key: UIButton) {
        if (key.currentTitle == enterName) {
            key.backgroundColor = labelColor
        } else {
            key.backgroundColor = bgColor
        }

        if (isPrintable(key: key)) {
            UIView.animate(withDuration: 0.04, animations: {
                key.transform = .identity
            })
        }
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

        popIn(key: sender)
    }

    @IBAction func keyDown(sender: UIButton) {
        popOut(key: sender)
    }

    @IBAction func slideIn(sender: UIButton) {
        popOut(key: sender)
    }

    @IBAction func slideOut(sender: UIButton) {
        popIn(key: sender)
    }
}
