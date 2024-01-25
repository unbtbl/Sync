import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum SyncMacroError: Error, CustomStringConvertible {
    case invalidNode
    case unsupportedNumberOfBindings
    case invalidPattern
    case noArguments
    case missingTypeAnnotation

    var description: String {
        switch self {
        case .invalidNode:
            return "@Sync can only be applied to a variable declaration"
        case .unsupportedNumberOfBindings:
            return "@Sync can only be applied to a variable declaration with a single binding"
        case .invalidPattern:
            return
                "@Sync can only be applied to a variable declaration with a single binding with an identifier pattern"
        case .noArguments:
            return "@Sync requires at least one argument"
        case .missingTypeAnnotation:
            return "@Sync requires a type annotation"
        }
    }
}

public struct SyncMacro {

}

extension SyncMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard case .argumentList(let arguments) = node.arguments, !arguments.isEmpty else {
            throw SyncMacroError.noArguments
        }

        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw SyncMacroError.invalidNode
        }

        guard let binding = declaration.bindings.first, declaration.bindings.count == 1 else {
            throw SyncMacroError.unsupportedNumberOfBindings
        }

        guard let bindingIdentifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw SyncMacroError.invalidPattern
        }

        guard let bindingType = binding.typeAnnotation?.type else {
            throw SyncMacroError.missingTypeAnnotation
        }

        let storedVariableName: TokenSyntax = "_\(bindingIdentifier.identifier)"

        // TODO: Support `Optional<Wrapped>` instead of `Wrapped?`
        let optionalGetGuardStatement: DeclSyntax =
            if bindingType.is(OptionalTypeSyntax.self) {
                """
                guard let \(storedVariableName) else {
                    return nil
                }

                """
            } else {
                ""
            }

        let optionalSetGuardStatement: DeclSyntax =
            if bindingType.is(OptionalTypeSyntax.self) {
                """
                guard let newValue else {
                    \(storedVariableName) = nil
                    return
                }

                """
            } else {
                ""
            }

        return [
            """
            get {
                \(optionalGetGuardStatement)return _syncToChild(
                    parent: self,
                    child: \(storedVariableName),
                    \(arguments.trimmed)
                )
            }
            """,
            """
            set {
                \(optionalSetGuardStatement)\(storedVariableName) = _syncToParent(
                    parent: &self,
                    child: newValue,
                    \(arguments.trimmed)
                )
            }
            """,
        ]
    }
}

extension SyncMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw SyncMacroError.invalidNode
        }

        guard let binding = declaration.bindings.first, declaration.bindings.count == 1 else {
            throw SyncMacroError.unsupportedNumberOfBindings
        }
        
        guard let bindingIdentifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw SyncMacroError.invalidPattern
        }

        return [
            """
            /// The backing storage for the ``\(bindingIdentifier.trimmed)`` property.
            /// - Note: The value of this property is not synchronized with the parent. Use the ``\(bindingIdentifier.trimmed)`` property instead.
            private var _\(binding.trimmed)
            """
        ]
    }
}

@main
struct SyncPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SyncMacro.self
    ]
}
