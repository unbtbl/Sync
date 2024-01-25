@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Sync<Parent, Child, each Value>(
    _ sync: repeat (_: WritableKeyPath<Child, each Value>, to: WritableKeyPath<Parent, each Value>)
) = #externalMacro(module: "SyncMacros", type: "SyncMacro")

public func _syncToChild<Parent, Child, each Value>(
    parent: Parent,
    child: Child,
    _ keyPaths: repeat (
        _: WritableKeyPath<Child, each Value>, to: WritableKeyPath<Parent, each Value>
    )
) -> Child {
    var child = child

    func sync<V>(_ keyPath: (_: WritableKeyPath<Child, V>, to: WritableKeyPath<Parent, V>)) {
        child[keyPath: keyPath.0] = parent[keyPath: keyPath.to]
    }

    repeat sync(each keyPaths)

    return child
}

public func _syncToParent<Parent, Child, each Value>(
    parent: inout Parent,
    child: Child,
    _ keyPaths: repeat (
        _: WritableKeyPath<Child, each Value>, to: WritableKeyPath<Parent, each Value>
    )
) -> Child {
    func sync<V>(_ keyPath: (_: WritableKeyPath<Child, V>, to: WritableKeyPath<Parent, V>)) {
        parent[keyPath: keyPath.to] = child[keyPath: keyPath.0]
    }

    repeat sync(each keyPaths)

    return child
}
