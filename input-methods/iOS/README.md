ipIqaD - Klingon pIqaD Keyboard for iOS
---------------------------------------

ipIqaD is a keyboard extension for iOS 9 and later which enables input of
Klingon pIqaD characters using the encoding registered in the Conscript Unicode
Registry in the Unicode Basic Multilingual Plane from code points U+F8D0-U+F8FF.

Quick Setup Guide
=================

Two post-installation steps are necessary in order to use the keyboard:

1. Add the ipIqaD keyboard layout in the Settings app. Go to:
   Settings:General:Keyboard:Keyboards:Add New Keyboard and select "ipIqaD".
2. Install a pIqaD font systemwide if you don't already have one. ipIqaD comes
   bundled with the "pIqaD qolqoS" font for use in the keyboard and in the
   ipIqaD app, but you will need a font installed systemwide to read and write
   pIqaD in other apps. Click on the "yIjom" button in the ipIqaD app or visit
   <https://dadap.github.io/pIqaD-tools/input-methods/iOS/install-font>
   to install the pIqaD qolqoS font systemwide via a configuration profile. You
   can also install the pIqaD font of your choice by creating a configuration
   profile and e-mailing it to yourself, as long as the font conforms with the
   Klingon mapping in the Conscript Unicode Registry.

Known Issues
============

* Typing the Klingon Empire symbol may sometimes display an Apple logo. This is
  because both symbols occupy the same code point in the Private Use Area of the
  Basic Multilingual Plane, namely, U+F8FF. You will need to explicitly set a
  font that provides the Klingon Empire symbol (rather than just allowing the
  renderer to select a pIqaD font for characters which happen to be pIqaD) in
  order to avoid seeing an Apple logo.
* A redundant keyboard switch key is displayed on iPhone X.

Privacy Policy
==============

ipIqaD transmits keystrokes to the active application immediately as they are
registered, and does not intentionally retain any keystroke input data. ipIqaD
does not transmit any information over the network, and does not share keystroke
data with any application apart from the application intended as the recipient
of the keystrokes.

Future versions of ipIqaD may cache keystroke input for the purpose of choosing
autocorrect or autocomplete suggestions. If this is to happen, any such data
collected would either remain internal to the ipIqaD application and be user
resettable, or if any network functionality is available (e.g. to improve
autocomplete suggestions), it would require an explicit user opt-in. This
privacy policy may be updated at any time to reflect new functionality of the
ipIqaD keyboard.

Acknowledgements
================

Klingon is a registered trademark of CBS Studios Inc.

iOS and Apple are registered trademarks of Apple Inc.

ipIqaD uses the "pIqaD qolqoS" font, available from:

<https://github.com/dadap/pIqaD-fonts>

This font is distributed under the SIL Open Font License. For more details, see
the full license text at universal-transliterator/pIqaD-qolqoS.LICENSE
