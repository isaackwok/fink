import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

  func testSystemKeyboardConstraintWarningsAreMutedInDebug() throws {
    let suiteName = "RunnerTests.systemKeyboardConstraintWarnings"
    let preferenceKey = "_UIConstraintBasedLayoutLogUnsatisfiable"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    defaults.set(true, forKey: preferenceKey)

    SystemKeyboardConstraintLogPolicy.apply(to: defaults)

    XCTAssertFalse(defaults.bool(forKey: preferenceKey))
  }

}
