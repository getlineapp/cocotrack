import Foundation

struct ClockifyUser: Decodable {
    let id: String
    let name: String?
    let email: String?
    let defaultWorkspace: String?
    let activeWorkspace: String?
}

struct ClockifyProject: Decodable, Identifiable {
    let id: String
    let name: String
    let color: String?
    let archived: Bool?
    let clientName: String?
}

struct ClockifyTimeEntry: Decodable, Identifiable {
    let id: String
    let description: String?
    let projectId: String?
    let taskId: String?
    let billable: Bool?
    let userId: String?
    let workspaceId: String?
    let timeInterval: ClockifyTimeInterval
}

struct ClockifyTimeInterval: Decodable {
    let start: Date
    let end: Date?
    let duration: String?
}

struct ClockifyCreateTimeEntryRequest: Encodable {
    let start: String
    let description: String
    let projectId: String?
}

struct ClockifyUpdateTimeEntryRequest: Encodable {
    let start: String
    let description: String
    let end: String?
    let projectId: String?
}

struct ClockifyCreateProjectRequest: Encodable {
    let name: String
    let color: String?
    let isPublic: Bool
}

struct ClockifyStopTimeEntryRequest: Encodable {
    let end: String
}

struct ClockifyBulkEditTimeEntryRequest: Encodable {
    let id: String
    let description: String?
    let start: String?
    let end: String?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case start
        case end
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(start, forKey: .start)
        try container.encodeIfPresent(end, forKey: .end)
    }
}

struct ClockifyWorkspace: Decodable {
    let id: String
    let name: String
    let workspaceSettings: ClockifyWorkspaceSettings
}

struct ClockifyWorkspaceSettings: Decodable {
    let forceProjects: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        forceProjects = try container.decodeIfPresent(Bool.self, forKey: .forceProjects) ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case forceProjects
    }
}

struct ClockifyAPIErrorResponse: Decodable {
    let message: String?
    let error: String?
}
