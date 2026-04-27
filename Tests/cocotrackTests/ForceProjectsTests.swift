import XCTest
@testable import cocotrack

final class ForceProjectsTests: XCTestCase {

    // MARK: - Workspace model decoding

    func testWorkspaceDecodesForceProjectsTrue() throws {
        let json = """
        {"id":"ws1","name":"Test","workspaceSettings":{"forceProjects":true}}
        """.data(using: .utf8)!

        let ws = try JSONDecoder.clockifyDecoder.decode(ClockifyWorkspace.self, from: json)
        XCTAssertEqual(ws.id, "ws1")
        XCTAssertTrue(ws.workspaceSettings.forceProjects)
    }

    func testWorkspaceDecodesForceProjectsFalse() throws {
        let json = """
        {"id":"ws1","name":"Test","workspaceSettings":{"forceProjects":false}}
        """.data(using: .utf8)!

        let ws = try JSONDecoder.clockifyDecoder.decode(ClockifyWorkspace.self, from: json)
        XCTAssertFalse(ws.workspaceSettings.forceProjects)
    }

    func testWorkspaceDecodesWithoutForceProjects() throws {
        let json = """
        {"id":"ws1","name":"Test","workspaceSettings":{}}
        """.data(using: .utf8)!

        let ws = try JSONDecoder.clockifyDecoder.decode(ClockifyWorkspace.self, from: json)
        XCTAssertFalse(ws.workspaceSettings.forceProjects)
    }

    func testWorkspaceDecodesExtraFieldsIgnored() throws {
        let json = """
        {"id":"ws1","name":"Test","workspaceSettings":{"forceProjects":true,"timeRoundingInReports":false,"otherField":"value"}}
        """.data(using: .utf8)!

        let ws = try JSONDecoder.clockifyDecoder.decode(ClockifyWorkspace.self, from: json)
        XCTAssertTrue(ws.workspaceSettings.forceProjects)
    }

    // MARK: - Timer validation: start

    func testStartBlockedWhenForceProjectsAndNoProject() {
        XCTAssertTrue(TimerValidation.shouldBlockStart(forceProjects: true, projectId: nil))
    }

    func testStartAllowedWhenForceProjectsAndProjectSet() {
        XCTAssertFalse(TimerValidation.shouldBlockStart(forceProjects: true, projectId: "p1"))
    }

    func testStartAllowedWhenNoForceProjects() {
        XCTAssertFalse(TimerValidation.shouldBlockStart(forceProjects: false, projectId: nil))
    }

    func testStartAllowedWhenNoForceProjectsWithProject() {
        XCTAssertFalse(TimerValidation.shouldBlockStart(forceProjects: false, projectId: "p1"))
    }

    // MARK: - Timer validation: stop

    func testStopWarnWhenForceProjectsAndNoProject() {
        XCTAssertTrue(TimerValidation.shouldWarnProjectOnStop(forceProjects: true, runningProjectId: nil))
    }

    func testStopNoWarnWhenForceProjectsAndProjectSet() {
        XCTAssertFalse(TimerValidation.shouldWarnProjectOnStop(forceProjects: true, runningProjectId: "p1"))
    }

    func testStopNoWarnWhenNoForceProjects() {
        XCTAssertFalse(TimerValidation.shouldWarnProjectOnStop(forceProjects: false, runningProjectId: nil))
    }

    // MARK: - Base URL hardening (F2)

    func testHttpsBaseURLAccepted() throws {
        XCTAssertNoThrow(try ClockifyAPIClient(baseURLString: "https://api.clockify.me/api/v1", apiKey: "k"))
    }

    func testHttpBaseURLRejectedForRemoteHost() {
        XCTAssertThrowsError(try ClockifyAPIClient(baseURLString: "http://attacker.tld/api/v1", apiKey: "k"))
    }

    func testHttpBaseURLAcceptedForLocalhost() throws {
        XCTAssertNoThrow(try ClockifyAPIClient(baseURLString: "http://localhost:8080/api/v1", apiKey: "k"))
        XCTAssertNoThrow(try ClockifyAPIClient(baseURLString: "http://127.0.0.1:8080/api/v1", apiKey: "k"))
    }

    func testFtpSchemeRejected() {
        XCTAssertThrowsError(try ClockifyAPIClient(baseURLString: "ftp://example.com/api", apiKey: "k"))
    }

    func testEmptyHostRejected() {
        XCTAssertThrowsError(try ClockifyAPIClient(baseURLString: "https://", apiKey: "k"))
    }

    func testIsDefaultBaseURL() {
        XCTAssertTrue(ClockifyAPIClient.isDefaultBaseURL("https://api.clockify.me/api/v1"))
        XCTAssertTrue(ClockifyAPIClient.isDefaultBaseURL(" https://api.clockify.me/api/v1 "))
        XCTAssertFalse(ClockifyAPIClient.isDefaultBaseURL("https://api.clockify.me"))
        XCTAssertFalse(ClockifyAPIClient.isDefaultBaseURL("https://attacker.tld/api/v1"))
    }
}
