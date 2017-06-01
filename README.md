<p align="center">
    <img width="900px" src="https://cloud.githubusercontent.com/assets/8394738/22552794/a4489eb6-e95a-11e6-90bf-37b7ccbf3fab.png">
</p>

<p align="center">
	<img src="https://travis-ci.org/blendle/Hanson.svg?style=flat)]" />
	<img src="https://img.shields.io/badge/language-swift-orange.svg"
         alt="Language: Swift" />
    <img src="https://img.shields.io/badge/platform-macos%20%7C%20ios%20%7C%20watchos%20%7C%20tvos-lightgrey.svg"
         alt="Platform: macOS | iOS | watchOS | tvOS" />
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"
         alt="Carthage" />
    <img src="https://img.shields.io/badge/license-ISC-000000.svg"
         alt="License" />
</p>

## What is Hanson?

Hanson is a simple, lightweight library to observe and bind values in Swift. It's been developed to support the MVVM architecture in our [Blendle iOS app](https://itunes.apple.com/nl/app/blendle/id947936149). Hanson provides several advantages to using KVO in Swift, such as a Swiftier syntax, no boilerplate code, and the ability to use it in pure Swift types.

## Example Usage

The most basic use case is to simply observe an `Observable` for changes:
```swift
let observable = Observable("Hello World")
observe(observable) { event in
    // Invoked whenever observable.value is set.
    print("Value changed from \(event.oldValue) to \(event.newValue)")
}
```

Hanson also provides a wrapper around KVO, so you can do the following to observe a `UITextField`'s `text` property for changes:
```swift
let textField = UITextField()
let textFieldObservable = textField.dynamicObservable(keyPath: #keyPath(UITextField.text), type: String.self)
observe(textFieldObservable) { event in
    print("Text field value changed from \(event.oldValue) to \(event.newValue)")
}
```

Furthermore, you can also use Hanson to bind an observable to another observable. Let's say we have a view model that's responsible for loading data, and we want the view to show an activity indicator while the view model is loading data:
```swift
class ViewModel {

    let isLoadingData = Observable(false)

}

class View {

    let showsActivityIndicator = Observable(false)

}

let viewModel = ViewModel()
let view = View()
bind(viewModel.isLoadingData, to: view.showsActivityIndicator)
```

Now, whenever the view model's `isLoadingData` property is set to a different value, it will automatically be set to the view's `showsActivityIndicator` property.

Binding is also supported from and to KVO-backed observables. To bind a text field's content to a label:
```swift
let textField = UITextField()
let textFieldObservable = textField.dynamicObservable(keyPath: #keyPath(UITextField.text), type: String.self)

let label = UILabel()
let labelObservable = label.dynamicObservable(keyPath: #keyPath(UILabel.text), type: String.self)

bind(textFieldObservable, to: labelObservable)
```

If you want to handle the binding yourself, you can also provide a closure that will be invoked when a new value should be set. In the following example, we'll bind an `isLoadingData` observable to a `UIActivityIndicatorView`:
```swift
let isLoadingData = Observable(false)
let activityIndicatorView = UIActivityIndicatorView()
bind(isLoadingData, to: activityIndicatorView) { activityIndicatorView, isLoadingData in
    if isLoadingData {
        activityIndicatorView.startAnimating()
    } else {
        activityIndicatorView.stopAnimating()
    }
}
```

Hanson also supports observering notifications sent through a `NotificationCenter`. For example, to observe when an application is entering the background:
```swift
let observable = NotificationCenter.default.observable(for: Notification.Name.UIApplicationDidEnterBackground)
observe(observable) { notification in
    print("Application did enter background")
}
```

## Requirements

* iOS 8.0+ / macOS 10.9+ / tvOS 9.0+
* Xcode 8

## Installation

Hanson is available through either [CocoaPods](http://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage).

### Cocoapods

1. Add `pod 'Hanson'` to your `Podfile`.
2. Run `pod install`.

### Carthage

1. Add `github 'blendle/Hanson'` to your `Cartfile`.
2. Run `carthage update`.
3. Link the framework with your target as described in [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

## Building

The project obviously builds fine through Xcode, just load up `Hanson.xcodeproj` and run it.

For convenience, we've included a few scripts and a `Makefile` that allow you to build Hanson from the command line and through continuous integration. They are inspired by GitHub's [Scripts to Rule Them All](https://github.com/github/scripts-to-rule-them-all) boilerplate:

```
|-- script/
  |-- etc/
    |-- config.sh   # Contains basic configuration parameters
  |-- bootstrap     # Prepares the project
  |-- setup         # Sets up the local building process
  |-- test          # Runs tests locally
  |-- cisetup       # Sets up the CI building process
  |-- citest        # Runs tests in a CI environment
```

To get started:

`$ make`

To skip setup and immediately start testing:

`$ make test`

Make sure all tests pass before opening a Pull Request.

## Release Notes

See [CHANGELOG.md](https://github.com/blendle/Hanson/blob/master/CHANGELOG.md) for a list of changes.

## License

Hanson is released under the ISC license. See [LICENSE](https://github.com/blendle/Hanson/blob/master/LICENSE) for details.
