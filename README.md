# Sync

`Sync` is a Swift package that provides a Macro to synchronize properties across different instances. `Sync` ensures that your properties stay in sync, reflecting changes instantaneously and reliably, without resorting to manually writing boilerplate.

Syncing is performed when the property the macro is applied to is set or read. With that in mind, it's most useful on properties that contain value types (structs and enums).

Our primary use case for this package is with [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), where we use it to share state across different components of the application.

## Usage

```swift
import Sync

struct UserProfile {
    var name: String
    var email: String

    @Sync(
        (\SessionInfo.username, to: \UserProfile.name),
        (\SessionInfo.email, to: \UserProfile.email)
    )
    var sessionInfo: SessionInfo

    init() {
        name = "John Doe"
        email = "johndoe@example.com"
        _sessionInfo = SessionInfo(username: name, email: email)
    }
}

struct SessionInfo {
    var username: String
    var isLoggedIn: Bool = false
}
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
