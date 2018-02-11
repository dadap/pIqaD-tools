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
                let key = KeyboardButton(label: name)

                if name == Keyboard.switchName {
                    keyboardVC.nextKeyboardButton = key

                    if #available(iOSApplicationExtension 11.0, *) {
                        if keyboardVC.needsInputModeSwitchKey {
                            addArrangedSubview(key)
                        }
                    } else {
                        addArrangedSubview(key)
                    }
                } else {
                    if name == Keyboard.enterName {
                        key.backgroundColor = KeyboardButton.labelColor
                        key.setTitleColor(KeyboardButton.bgColor, for: .normal)
                    }

                    addArrangedSubview(key)
                }
            }

            if (arrangedSubviews[0] as! KeyboardButton).isPrintable() {
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
            spacing = KeyboardButton.buttonSpacing

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
    }

    class KeyboardButton: UIButton {
        static let bgColor = UIColor.lightGray
        static let labelColor = UIColor.red

        static let fontName = "pIqaD qolqoS"
        static let fontSize = CGFloat(20)
        static let buttonSpacing = CGFloat(4)
        static let cornerRadius = CGFloat(6)

        static let animationDuration = 0.04

        init(label: String) {
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
            backgroundColor = KeyboardButton.bgColor
            layer.cornerRadius = KeyboardButton.cornerRadius
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 0.2
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 1, height: 1)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) not implemented")
        }

        func isPrintable() -> Bool {
            return self.currentTitle?.count == 1 && self.currentTitle != Keyboard.backspaceName
        }

        func popOut() {
            backgroundColor = .white

            if isPrintable() {
                UIView.animate(withDuration: KeyboardButton.animationDuration, animations: {
                    self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 2, tx: 0, ty: -self.layer.bounds.height/2)
                    self.titleEdgeInsets = UIEdgeInsetsMake(-self.layer.bounds.height/4, 0, 0, 0)
                    self.titleLabel?.transform = CGAffineTransform(scaleX: 1, y: 1/2)
                })
            }
        }

        func popIn() {
            if currentTitle == Keyboard.enterName {
                backgroundColor = KeyboardButton.labelColor
            } else {
                backgroundColor = KeyboardButton.bgColor
            }

            if isPrintable() {
                UIView.animate(withDuration: KeyboardButton.animationDuration, animations: {
                    self.transform = .identity
                    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                    self.titleLabel?.transform = .identity
                })
            }
        }

    }
}
