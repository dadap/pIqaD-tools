//
//  KeyboardViewController.swift
//  pIqaD
//
//  Created by Daniel Dadap on 1/15/18.
//  Copyright © 2018 Daniel Dadap. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    var keyboard: Keyboard?

    @IBOutlet var nextKeyboardButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()

        view.addConstraint(NSLayoutConstraint(item: keyboard!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: KeyboardButton.buttonSpacing))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: keyboard, attribute: .right, multiplier: 1, constant: KeyboardButton.buttonSpacing))
        view.addConstraint(NSLayoutConstraint(item: keyboard!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: KeyboardButton.buttonSpacing))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: keyboard, attribute: .bottom, multiplier: 1, constant: KeyboardButton.buttonSpacing))
    }

    func initKeyboard() {
        keyboard = Keyboard(keyboardVC: self)
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
        var switchKey = true

        if #available(iOSApplicationExtension 11.0, *) {
            switchKey = needsInputModeSwitchKey // XXX wrong value in some older apps
        }

        keyboard!.addOrRemoveSwitchKey(needsInputModeSwitchKey: switchKey)
        view.addSubview(keyboard!)
    }

    class KeyRow: UIStackView {
        init(keyNames: [String], keyboardVC: KeyboardViewController) {
            super.init(frame: CGRect.zero)

            axis = .horizontal
            alignment = .fill
            translatesAutoresizingMaskIntoConstraints = false
            spacing = KeyboardButton.buttonSpacing

            for name in keyNames {
                let key = KeyboardButton(label: name, bgColor: Keyboard.bgForLabel(name: name), selectedColor: Keyboard.selForLabel(name: name))

                if name == Keyboard.switchName {
                    keyboardVC.nextKeyboardButton = key
                }

                addArrangedSubview(key)
            }

            if arrangedSubviews.count > 3 {
                self.distribution = .fillEqually
            } else {
                self.distribution = .fillProportionally
            }
            sizeToFit()
        }

        required init(coder: NSCoder) {
            fatalError()
        }
    }

    class Keyboard: UIStackView {
        static let backspaceName = "⌫"
        static let switchName = ""
        static let spaceName = ""
        static let enterName = ""

        static let keyNames = [["", "", "", "", "", "", "", "", "", ""],
                               ["", "", "", "", "", "", "", "", "", ""],
                               ["", "", "", "", "", "", "", "", "", ""],
                               ["", "", "", "", "", "", "", "", "", backspaceName],
                               [switchName, spaceName, enterName]
        ]

        var activeKeys = Set<KeyboardButton>()
        let keyboardVC: KeyboardViewController

        init(keyboardVC: KeyboardViewController) {
            self.keyboardVC = keyboardVC
            super.init(frame: CGRect.zero)

            isMultipleTouchEnabled = true
            axis = .vertical
            translatesAutoresizingMaskIntoConstraints = false
            spacing = KeyboardButton.rowSpacing

            for nameRow in Keyboard.keyNames {
                addArrangedSubview(KeyRow(keyNames: nameRow, keyboardVC: keyboardVC))
            }

            sizeToFit()
        }

        required init(coder: NSCoder) {
            fatalError()
        }

        func changeKeys(touches: Set<UITouch>, event: UIEvent) {
            var newActiveKeys = Set<KeyboardButton>()

            for touch in touches {
                if let key = super.hitTest(touch.location(in: self), with: event) as? KeyboardButton {
                    newActiveKeys.insert(key)
                }
            }

            let activated = newActiveKeys.subtracting(activeKeys)
            let deactivated = activeKeys.subtracting(newActiveKeys)

            for key in activated {
                key.popOut()
            }

            for key in deactivated {
                key.popIn()
            }

            activeKeys = newActiveKeys
        }

        func addOrRemoveSwitchKey(needsInputModeSwitchKey: Bool) {
            if #available(iOSApplicationExtension 11.0, *) {
                let lastRow = arrangedSubviews.last as! UIStackView
                let firstKey = lastRow.arrangedSubviews.first as! KeyboardButton

                if needsInputModeSwitchKey {
                    firstKey.isHidden = false
                } else {
                    firstKey.isHidden = true
                }
            }
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            // Don't propagate the hitTest to subviews: we want to track all touches
            // as they move between subviews.
            return self
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesBegan(touches, with: event)

            changeKeys(touches: touches, event: event!)
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesMoved(touches, with: event)

            changeKeys(touches: touches, event: event!)
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesEnded(touches, with: event)

            for touch in touches {
                if let key = super.hitTest(touch.location(in: self), with: event) as? KeyboardButton {
                    key.popIn()
                    activeKeys.remove(key)

                    let name = key.currentTitle

                    if name == Keyboard.backspaceName {
                        // TODO: Repeat key presses on long press
                        (keyboardVC.textDocumentProxy as UIKeyInput).deleteBackward()
                    } else if name == Keyboard.spaceName {
                        (keyboardVC.textDocumentProxy as UIKeyInput).insertText(" ")
                    } else if name == Keyboard.enterName {
                        (keyboardVC.textDocumentProxy as UIKeyInput).insertText("\n")
                    } else if name == Keyboard.switchName {
                        // TODO: Support handleInputModeList() in iOS 10.0 and above
                        keyboardVC.advanceToNextInputMode()
                    } else {
                        (keyboardVC.textDocumentProxy as UIKeyInput).insertText(name!)
                    }
                }
            }
        }

        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)

            for touch in touches {
                if let key = super.hitTest(touch.location(in: self), with: event) as? KeyboardButton {
                    key.popIn()
                    activeKeys.remove(key)
                }
            }
        }

        static func bgForLabel(name: String) -> UIColor {
            if name == enterName || name == switchName || name == backspaceName {
                return KeyboardButton.fnBgColor
            }

            return KeyboardButton.bgColor

        }

        static func selForLabel(name: String) -> UIColor {
            if name == spaceName || hasDigit(string: name) {
                return KeyboardButton.fnBgColor
            }

            return KeyboardButton.bgColor
        }

        static func hasDigit(string: String) -> Bool {
            let digits = CharacterSet(charactersIn: "")
            return string.rangeOfCharacter(from: digits) != nil
        }
    }

    class KeyboardButton: UIButton {
        static let bgColor = UIColor.white
        static let fnBgColor = UIColor.lightGray
        static let labelColor = UIColor.black

        static let fontName = "pIqaD qolqoS"
        static let fontSize = CGFloat(20)
        static let buttonSpacing = CGFloat(6)
        static let rowSpacing = CGFloat(9)
        static let cornerRadius = CGFloat(6)

        static let xScale = CGFloat(1.5)
        static let yScale = CGFloat(2.5)

        static let animationDuration = 0.04

        var selectedColor: UIColor = KeyboardButton.bgColor
        var deselectedColor: UIColor = KeyboardButton.bgColor

        init(label: String, bgColor: UIColor, selectedColor: UIColor) {
            super.init(frame: .zero)

            var fontSize = KeyboardButton.fontSize

            if label == Keyboard.backspaceName {
                fontSize /= 2
            } else {
                contentVerticalAlignment = .top
            }

            setTitle(label, for: [])
            titleLabel?.font = UIFont(name: KeyboardButton.fontName, size: fontSize)
            setTitleColor(KeyboardButton.labelColor, for: .normal)
            backgroundColor = bgColor
            deselectedColor = bgColor
            self.selectedColor = selectedColor
            layer.cornerRadius = KeyboardButton.cornerRadius
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 0.2
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 0, height: 1)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) not implemented")
        }

        func isPoppable() -> Bool {
            let title = self.currentTitle!
            return title.count == 1 && title != Keyboard.backspaceName && !Keyboard.hasDigit(string: title)
        }

        func popOut() {
            backgroundColor = selectedColor

            if isPoppable() {
                UIView.animate(withDuration: KeyboardButton.animationDuration, animations: {
                    self.transform = CGAffineTransform(a: KeyboardButton.xScale, b: 0, c: 0, d: KeyboardButton.yScale, tx: 0, ty: -self.layer.bounds.height/KeyboardButton.yScale)
                    self.titleEdgeInsets = UIEdgeInsetsMake(-self.layer.bounds.height/KeyboardButton.yScale/2, 0, 0, 0)
                    self.titleLabel?.transform = CGAffineTransform(scaleX: 1, y: KeyboardButton.xScale/KeyboardButton.yScale)
                })
            }
        }

        func popIn() {
            backgroundColor = deselectedColor

            if isPoppable() {
                UIView.animate(withDuration: KeyboardButton.animationDuration, animations: {
                    self.transform = .identity
                    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                    self.titleLabel?.transform = .identity
                })
            }
        }

    }
}
