import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import WWDCMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "EnumSubset": EnumSubsetMacro.self
]

final class WWDCTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
    }

    func testMacroWithStringLiteral() {
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
    }
    
    func testEnumSubset() {
        assertMacroExpansion(
            """
            @EnumSubset<Slope>
            enum EasySlope {
                case beginnerParadise
                case practiceRun
            }
            """,
            expandedSource:
            """
            enum EasySlope {
                case beginnerParadise
                case practiceRun
                init?(_ slope: Slope) {
                    switch slope {
                    case .beginnerParadise:
                        self = .beginnerParadise
                    case .practiceRun:
                        self = .practiceRun
                    default:
                        return nil
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testEnumSubsetOnStruct() throws {
        assertMacroExpansion(
            """
            @EnumSubset
            struct Skier {
            }
            """,
            expandedSource:
            """
            struct Skier {
            }
            """
            ,
            diagnostics: [
                DiagnosticSpec(
                    message: "@EnumSubset can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
}
