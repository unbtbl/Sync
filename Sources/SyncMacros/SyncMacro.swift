import MacroToolkit
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum SyncMacroError: Error, CustomStringConvertible {
    case invalidNode
    case unsupportedNumberOfBindings
    case invalidPattern
    case noArguments

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

        let storedVariableName: TokenSyntax = "_\(bindingIdentifier.identifier)"

        return [
            """
            get {
                _syncToChild(
                    parent: self,
                    child: \(storedVariableName),
                    \(arguments.withoutTrivia())
                )
            }
            """,
            """
            set {
                \(storedVariableName) = _syncToParent(
                    parent: &self,
                    child: newValue,
                    \(arguments.withoutTrivia())
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

        return [
            """
            private var _\(binding.withoutTrivia())
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
