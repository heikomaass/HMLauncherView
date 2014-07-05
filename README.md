# HMLauncherView

[![Version](https://img.shields.io/cocoapods/v/HMLauncherView.svg?style=flat)](http://cocoadocs.org/docsets/HMLauncherView)
[![License](https://img.shields.io/cocoapods/l/HMLauncherView.svg?style=flat)](http://cocoadocs.org/docsets/HMLauncherView)
[![Platform](https://img.shields.io/cocoapods/p/HMLauncherView.svg?style=flat)](http://cocoadocs.org/docsets/HMLauncherView)

HMLauncherView is an UI component which mimics the iOS homescreen (a.k.a SpringBoard) behaviour. 
Added icons can be reordered and removed. In addition the HMLauncherView supports drag&drop of icons between several HMLauncherView instances.
Checkout the demo video: 
[![Demo Video showing the launcher icon movement](https://i1.ytimg.com/vi/Mqv1usdM6fA/mqdefault.jpg)](https://www.youtube.com/watch?v=Mqv1usdM6fA)

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

The HMLaucherView needs a datasource and a delegate. The implementation of `HMLauncherDataSource` has to provide the grid dimensions (columns/rows), the number of pages,
and accessor methods to the `HMLaucherIcon`s, which represents the icons of the laucher view. 

The `HMLauncherViewDelegate` should react to any interactions (like dragging, tapping, deleting) on the launcher view. In addition the delegate is resposible to find out
to which the current dragged `HMLaucherIcon` belongs to.  

Checkout the [LauncherService](Example/HMLauncherViewExample/LauncherService.m) class of the example project.


## Installation

HMLauncherView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "HMLauncherView"

## Author

Heiko Maaß, mail@heikomaass.de

## License

HMLauncherView is available under the Apache 2.0 license. See the LICENSE file for more info.

