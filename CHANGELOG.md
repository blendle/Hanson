## Changelog

### 2.1.0 (2020-12-09)

- The `unowned` reference type is replaced with `weak` reference type on target property of `CustomBindable` 

### 2.0.0 (2020-11-06)

Breaking change:

- Added support for `EventScheduler`. This changes the `EventPublisher` protocol. Apps that use their own implementation of this protocol need to update their implementation.

### 1.2 (2017-09-26)

- Update for Swift 4.

### 1.1.1 (2017-06-01)

- Make observation manager init method public.

### 1.1 (2017-06-01)

- Add support for observing notifications.

### 1.0.1 (2017-06-01)

Features:

- Support for observing NotificationCenter notifications.

### 1.0 (2017-05-29)

- First public release! 🎉
