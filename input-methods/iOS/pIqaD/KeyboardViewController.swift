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

        /* XXX always display the switch key: a bug prevents it from being displayed
         on iPhone X in apps that are not display-optimized for iPhone X.
        if #available(iOSApplicationExtension 11.0, *) {
            switchKey = needsInputModeSwitchKey
        }
         */

        keyboard!.addOrRemoveSwitchKey(needsInputModeSwitchKey: switchKey)
        view.addSubview(keyboard!)
    }

    class KeyRow: UIStackView {
        let keyboardVC: KeyboardViewController!
        init(keyNames: [String], keyboardVC: KeyboardViewController) {
            self.keyboardVC = keyboardVC
            super.init(frame: CGRect.zero)

            axis = .horizontal
            alignment = .fill
            translatesAutoresizingMaskIntoConstraints = false
            spacing = KeyboardButton.buttonSpacing

            for name in keyNames {
                let isCharacter = (name.count == 1 && name != Keyboard.backspaceName) || name == Keyboard.spaceName
                let isPoppable = isCharacter && name != Keyboard.spaceName && !Keyboard.hasDigit(string: name)

                let key = KeyboardButton(label: name, isCharacter: isCharacter, isPoppable: isPoppable)

                if name == Keyboard.switchName {
                    keyboardVC.nextKeyboardButton = key
                    key.addTarget(self, action: #selector(switchKey(sender:forEvent:)), for: .allTouchEvents)
                } else if !isCharacter {
                    key.addTarget(self, action: #selector(keyDown(sender:)), for: [.touchDown, .touchDragEnter])
                    key.addTarget(self, action: #selector(keyUp(sender:)), for: .touchUpInside)
                    key.addTarget(self, action: #selector(keyOut(sender:)), for: [.touchUpOutside, .touchDragExit])
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

        @IBAction func switchKey(sender: UIButton, forEvent event: UIEvent) {
            if #available(iOSApplicationExtension 10.0, *) {
                keyboardVC.handleInputModeList(from: sender, with: event)
            } else {
                keyboardVC.advanceToNextInputMode()
            }
        }

        @IBAction func keyDown(sender: KeyboardButton) {
            sender.popOut()
        }

        @IBAction func keyOut(sender: KeyboardButton) {
            sender.popIn()
        }

        @IBAction func keyUp(sender: KeyboardButton) {
            let title = sender.title(for: .normal)

            sender.popIn()
            if title == Keyboard.backspaceName {
                // TODO: Repeat key presses on long press
                keyboardVC.textDocumentProxy.deleteBackward()
            } else if title == Keyboard.enterName {
                keyboardVC.textDocumentProxy.insertText("\n")
            }
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

        func changeKeys(with event: UIEvent?) {
            var newActiveKeys = Set<KeyboardButton>()
            let viewTouches = event?.touches(for: self as UIView)

            if viewTouches != nil {
                for touch in viewTouches! {
                    if let key = super.hitTest(touch.location(in: self), with: event) as? KeyboardButton {
                        newActiveKeys.insert(key)
                    }
                }
            }

            let activated = newActiveKeys.subtracting(activeKeys)
            let deactivated = activeKeys.subtracting(newActiveKeys)

            for key in activated {
                if key.isCharacter {
                    key.popOut()
                }
            }

            for key in deactivated {
                if key.isCharacter {
                    key.popIn()
                }
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
            if let key = super.hitTest(point, with: event) as? KeyboardButton {
                if !key.isCharacter {
                    return key
                }
            }
            // Don't propagate the hitTest to subviews: we want to track all touches
            // as they move between subviews.
            return self
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesBegan(touches, with: event)

            changeKeys(with: event)
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesMoved(touches, with: event)

            changeKeys(with: event)
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesEnded(touches, with: event)

            for touch in touches {
                if let key = super.hitTest(touch.location(in: self), with: event) as? KeyboardButton {
                    if !key.isCharacter {
                        continue
                    }

                    key.popIn()
                    activeKeys.remove(key)

                    let name = key.currentTitle

                    if name == Keyboard.spaceName {
                        (keyboardVC.textDocumentProxy as UIKeyInput).insertText(" ")
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

        let isCharacter: Bool!
        let isPoppable: Bool!

        var selectedColor: UIColor = KeyboardButton.bgColor
        var deselectedColor: UIColor = KeyboardButton.bgColor

        init(label: String, isCharacter: Bool, isPoppable: Bool) {
            self.isCharacter = isCharacter
            self.isPoppable = isPoppable

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
            layer.cornerRadius = KeyboardButton.cornerRadius
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 0.2
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 0, height: 1)
            if (isCharacter) {
                deselectedColor = KeyboardButton.bgColor
                if (isPoppable) {
                    selectedColor = KeyboardButton.bgColor
                } else {
                    selectedColor = KeyboardButton.fnBgColor
                }
            } else {
                deselectedColor = KeyboardButton.fnBgColor
                selectedColor = KeyboardButton.bgColor
            }
            backgroundColor = deselectedColor
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) not implemented")
        }

        func popOut() {
            backgroundColor = selectedColor

            if isPoppable {
                UIView.animate(withDuration: KeyboardButton.animationDuration, animations: {
                    self.transform = CGAffineTransform(a: KeyboardButton.xScale, b: 0, c: 0, d: KeyboardButton.yScale, tx: 0, ty: -self.layer.bounds.height/KeyboardButton.yScale)
                    self.titleEdgeInsets = UIEdgeInsetsMake(-self.layer.bounds.height/KeyboardButton.yScale/2, 0, 0, 0)
                    self.titleLabel?.transform = CGAffineTransform(scaleX: 1, y: KeyboardButton.xScale/KeyboardButton.yScale)
                })
            }
        }

        func popIn() {
            backgroundColor = deselectedColor

            if isPoppable {
                UIView.animate(withDuration: KeyboardButton.animationDuration, animations: {
                    self.transform = .identity
                    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                    self.titleLabel?.transform = .identity
                })
            }
        }

    }
}
