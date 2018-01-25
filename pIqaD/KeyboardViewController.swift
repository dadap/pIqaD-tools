//
//  KeyboardViewController.swift
//  pIqaD
//
//  Created by Daniel Dadap on 1/15/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    var keyboard: UIStackView = UIStackView()

    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }

    func initKeyboard() {
        keyboard = makeKeyboard()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initKeyboard()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initKeyboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(keyboard)

        let viewsDictionary = ["keyRows":keyboard]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[keyRows]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[keyRows]-4-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)
    }

    @IBAction func switchKey(sender: UIButton, forEvent event: UIEvent) {
        if #available(iOSApplicationExtension 10.0, *) {
            handleInputModeList(from: sender, with: event)
        } else {
            advanceToNextInputMode()
        }
    }

    @IBAction func keyUp(sender: KeyboardButton) {
        let name = sender.currentTitle

        if (name == KeyboardButton.backspaceName) {
            (textDocumentProxy as UIKeyInput).deleteBackward()
        } else if (name == KeyboardButton.spaceName) {
            (textDocumentProxy as UIKeyInput).insertText(" ")
        } else if (name == KeyboardButton.enterName) {
            (textDocumentProxy as UIKeyInput).insertText("\n")
        } else {
            (textDocumentProxy as UIKeyInput).insertText(name!)
        }

        sender.popIn()
    }

    @IBAction func keyDown(sender: KeyboardButton) {
        sender.popOut()
    }

    @IBAction func slideIn(sender: KeyboardButton) {
        sender.popOut()
    }

    @IBAction func slideOut(sender: KeyboardButton) {
        sender.popIn()
    }

    func makeKeyboard() -> UIStackView {
        let keyboard = UIStackView()

        keyboard.axis = .vertical
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        keyboard.spacing = 4

        for nameRow in KeyboardButton.keyNames {
            let row = makeRow(names: nameRow)
            row.axis = .horizontal
            if ((row.arrangedSubviews[0] as! KeyboardButton).isPrintable()) {
                row.distribution = .fillEqually
            } else {
                row.distribution = .fillProportionally
            }
            row.alignment = .fill
            row.translatesAutoresizingMaskIntoConstraints = false
            row.spacing = 4
            row.sizeToFit()
            keyboard.addArrangedSubview(row)
        }

        keyboard.sizeToFit()

        return keyboard
    }

    func makeRow(names: [String]) -> UIStackView {
        var keys = [KeyboardButton]()

        for name in names {
            let key = KeyboardButton(label: name)
            key.titleLabel?.font = UIFont(name: "Klingonpiqadhasta", size: 26)
            key.setTitleColor(KeyboardButton.labelColor, for: .normal)
            key.backgroundColor = KeyboardButton.bgColor
            key.layer.cornerRadius = 6

            if (name == KeyboardButton.switchName) {
                key.addTarget(self, action: #selector(switchKey(sender:forEvent:)), for: .allTouchEvents)
                nextKeyboardButton = key

                if #available(iOSApplicationExtension 11.0, *) {
                    if needsInputModeSwitchKey {
                        keys.append(key)
                    }
                } else {
                    keys.append(key)
                }
            } else {
                if (name == KeyboardButton.enterName) {
                    key.backgroundColor = KeyboardButton.labelColor
                    key.setTitleColor(KeyboardButton.bgColor, for: .normal)
                }
                key.addTarget(self, action: #selector(keyUp(sender:)), for: .touchUpInside)
                key.addTarget(self, action: #selector(keyDown(sender:)), for: .touchDown)
                key.addTarget(self, action: #selector(slideIn(sender:)), for: .touchDragEnter)
                key.addTarget(self, action: #selector(slideOut(sender:)), for: .touchDragExit)

                keys.append(key)
            }
        }

        return UIStackView(arrangedSubviews: keys)
    }

    class KeyboardButton: UIButton {
        static let bgColor = UIColor.lightGray
        static let labelColor = UIColor.red

        static let backspaceName = "⇦"
        static let switchName = ""
        static let spaceName = ""
        static let enterName = ""

        static let keyNames = [["", "", "", "", "", "", "", "", "", ""],
                               ["", "", "", "", "", "", "", "", "", ""],
                               ["", "", "", "", "", "", "", "", "", ""],
                               ["", "", "", "", "", "", "", "", "", backspaceName],
                               [switchName, spaceName, enterName]
        ]

        init(label: String) {
            super.init(frame: .zero)

            self.setTitle(label, for: [])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) not implemented")
        }

        func isPrintable() -> Bool {
            return self.currentTitle?.count == 1 && self.currentTitle != KeyboardButton.backspaceName
        }

        func popOut() {
            backgroundColor = .white

            if (isPrintable()) {
                UIView.animate(withDuration: 0.04, animations: {
                    self.transform = CGAffineTransform(a: 1.25, b: 0, c: 0, d: 1.25, tx: 0, ty: -39)
                })
            }
        }

        func popIn() {
            if (currentTitle == KeyboardButton.enterName) {
                backgroundColor = KeyboardButton.labelColor
            } else {
                backgroundColor = KeyboardButton.bgColor
            }

            if (isPrintable()) {
                UIView.animate(withDuration: 0.04, animations: {
                    self.transform = .identity
                })
            }
        }
    }
}
