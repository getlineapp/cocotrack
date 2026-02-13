import Foundation

enum ClockifyAPIError: LocalizedError {
    case invalidBaseURL
    case missingData
    case invalidResponse
    case httpError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return L10n.errorInvalidBaseURL
        case .missingData:
            return L10n.errorMissingData
        case .invalidResponse:
            return L10n.errorInvalidResponse
        case .httpError(let statusCode, let message):
            return L10n.apiError(statusCode, message)
        }
    }
}

struct ClockifyAPIClient {
    let baseURL: URL
    let apiKey: String
    private let session: URLSession

    init(baseURLString: String, apiKey: String, session: URLSession = .shared) throws {
        guard let baseURL = URL(string: baseURLString) else {
            throw ClockifyAPIError.invalidBaseURL
        }

        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }

    func fetchCurrentUser() async throws -> ClockifyUser {
        try await request(
            method: "GET",
            path: "user",
            queryItems: [],
            body: Optional<String>.none,
            responseType: ClockifyUser.self
        )
    }

    func fetchRecentTimeEntries(workspaceId: String, userId: String, limit: Int) async throws -> [ClockifyTimeEntry] {
        try await request(
            method: "GET",
            path: "workspaces/\(workspaceId)/user/\(userId)/time-entries",
            queryItems: [
                URLQueryItem(name: "page-size", value: "\(limit)")
            ],
            body: Optional<String>.none,
            responseType: [ClockifyTimeEntry].self
        )
    }

    func fetchRunningTimeEntry(workspaceId: String, userId: String) async throws -> ClockifyTimeEntry? {
        let entries = try await request(
            method: "GET",
            path: "workspaces/\(workspaceId)/user/\(userId)/time-entries",
            queryItems: [
                URLQueryItem(name: "in-progress", value: "true"),
                URLQueryItem(name: "page-size", value: "1")
            ],
            body: Optional<String>.none,
            responseType: [ClockifyTimeEntry].self
        )

        return entries.first
    }

    func startTimer(workspaceId: String, description: String, start: Date) async throws -> ClockifyTimeEntry {
        let payload = ClockifyCreateTimeEntryRequest(
            start: start.clockifyISO8601String,
            description: description
        )

        return try await request(
            method: "POST",
            path: "workspaces/\(workspaceId)/time-entries",
            queryItems: [],
            body: payload,
            responseType: ClockifyTimeEntry.self
        )
    }

    func stopRunningTimer(workspaceId: String, userId: String, end: Date) async throws -> ClockifyTimeEntry {
        let payload = ClockifyStopTimeEntryRequest(end: end.clockifyISO8601String)

        return try await request(
            method: "PATCH",
            path: "workspaces/\(workspaceId)/user/\(userId)/time-entries",
            queryItems: [],
            body: payload,
            responseType: ClockifyTimeEntry.self
        )
    }

    func bulkEditTimeEntries(workspaceId: String, userId: String, payload: [ClockifyBulkEditTimeEntryRequest]) async throws -> [ClockifyTimeEntry] {
        try await request(
            method: "PUT",
            path: "workspaces/\(workspaceId)/user/\(userId)/time-entries",
            queryItems: [],
            body: payload,
            responseType: [ClockifyTimeEntry].self
        )
    }

    private func request<Body: Encodable, Response: Decodable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem],
        body: Body?,
        responseType: Response.Type
    ) async throws -> Response {
        let url = try buildURL(path: path, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.httpBody = try JSONEncoder.clockifyEncoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClockifyAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder.clockifyDecoder.decode(ClockifyAPIErrorResponse.self, from: data)
            let message = apiError?.message ?? apiError?.error ?? L10n.errorUnknownApi
            throw ClockifyAPIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        guard !data.isEmpty else {
            throw ClockifyAPIError.missingData
        }

        return try JSONDecoder.clockifyDecoder.decode(Response.self, from: data)
    }

    private func buildURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        let url = baseURL.appendingPathComponent(path)

        if queryItems.isEmpty {
            return url
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw ClockifyAPIError.invalidBaseURL
        }

        components.queryItems = queryItems

        guard let result = components.url else {
            throw ClockifyAPIError.invalidBaseURL
        }

        return result
    }
}
