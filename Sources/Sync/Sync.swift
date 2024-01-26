import CasePaths

@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Sync<Parent, Child, each Value>(
    _ sync: repeat (_: KeyPath<Child, each Value>, to: KeyPath<Parent, each Value>)
) = #externalMacro(module: "SyncMacros", type: "SyncMacro")

@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Sync<Parent, Child, each ChildState, each Value>(
    _ sync: repeat (
        _: CaseKeyPath<Child, each ChildState>, _: KeyPath<each ChildState, each Value>, to: KeyPath<Parent, each Value>
    )
) = #externalMacro(module: "SyncMacros", type: "SyncMacro")

// MARK: Support functions - non-optional

public func _syncToChild<Parent, Child, each Value>(
    parent: Parent,
    child: Child,
    _ keyPaths: repeat (
        _: KeyPath<Child, each Value>, to: KeyPath<Parent, each Value>
    )
) -> Child {
    var child = child

    func sync<V>(_ keyPath: (_: KeyPath<Child, V>, to: KeyPath<Parent, V>)) {
        guard let childKeyPath = keyPath.0 as? WritableKeyPath<Child, V> else { return }
        child[keyPath: childKeyPath] = parent[keyPath: keyPath.to]
    }

    repeat sync(each keyPaths)

    return child
}

public func _syncToParent<Parent, Child, each Value>(
    parent: inout Parent,
    child: Child,
    _ keyPaths: repeat (
        _: KeyPath<Child, each Value>, to: KeyPath<Parent, each Value>
    )
) -> Child {
    func sync<V>(_ keyPath: (_: KeyPath<Child, V>, to: KeyPath<Parent, V>)) {
        guard let to = keyPath.to as? WritableKeyPath<Parent, V> else { return }
        parent[keyPath: to] = child[keyPath: keyPath.0]
    }

    repeat sync(each keyPaths)

    return child
}

// MARK: CaseKeyPath support

public func _syncToChild<Parent, Child, each ChildState, each Value>(
    parent: Parent,
    child: Child,
    _ keyPaths: repeat (
        _: CaseKeyPath<Child, each ChildState>, _: KeyPath<each ChildState, each Value>, to: KeyPath<Parent, each Value>
    )
) -> Child where Child: CasePathable {
    var child = child

    func sync<CS, V>(_ keyPath: (_: CaseKeyPath<Child, CS>, _: KeyPath<CS, V>, to: KeyPath<Parent, V>)) {
        guard
            let valueCaseStateKeyPath = keyPath.1 as? WritableKeyPath<CS, V>,
            var value = child[case: keyPath.0] else { return }
        value[keyPath: valueCaseStateKeyPath] = parent[keyPath: keyPath.to]
        child = keyPath.0(value)
    }

    repeat sync(each keyPaths)

    return child
}

public func _syncToParent<Parent, Child, each ChildState, each Value>(
    parent: inout Parent,
    child: Child,
    _ keyPaths: repeat (
        _: CaseKeyPath<Child, each ChildState>, _: KeyPath<each ChildState, each Value>, to: KeyPath<Parent, each Value>
    )
) -> Child where Child: CasePathable {
    func sync<CS, V>(_ keyPath: (_: CaseKeyPath<Child, CS>, _: KeyPath<CS, V>, to: KeyPath<Parent, V>)) {
        guard let to = keyPath.to as? WritableKeyPath<Parent, V> else { return }
        if let value = child[case: keyPath.0] {
            parent[keyPath: to] = value[keyPath: keyPath.1]
        }
    }

    repeat sync(each keyPaths)

    return child
}

