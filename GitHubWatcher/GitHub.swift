import Foundation

class GitHub {
    static let shared = GitHub()
    let decoder = JSONDecoder()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private func search(query: String) async throws -> Results {
        let secret = try CredentialsManager.get()
        
        guard var url = URL(string: "https://api.github.com/search/issues") else {
            throw GitHubError.invalidURL
        }
        url.append(queryItems: [URLQueryItem(name:"q",value: query)])
        
        var request = URLRequest(url: url)
        // TODO: store token in keychain
        request.setValue("Bearer \(secret!)", forHTTPHeaderField: "Authorization")
        // request.timeoutInterval = . // TODO: request timeout
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GitHubError.badResponse
        }
        
        do {
            return try decoder.decode(Results.self, from: data)
        } catch {
            throw GitHubError.invalidJSON
        }
    }
    
    func pullRequestsWaitingMyReview() async throws -> Results {
        let q = "is:pr is:open -review:approved -draft:true -label:not-for-review org:rabotaua review-requested:@me"
        return try await search(query: q)
    }
    
    func humanPullRequestsWaitingMyReview() async throws -> Results {
        let q = "is:pr is:open -review:approved -draft:true -label:not-for-review org:rabotaua review-requested:@me -author:dependabot[bot]"
        return try await search(query: q)
    }
    
    func botPullRequestsWaitingMyReview() async throws -> Results {
        let q = "is:pr is:open -review:approved -draft:true -label:not-for-review org:rabotaua review-requested:@me author:dependabot[bot]"
        return try await search(query: q)
    }
    
    func myPullRequestsWaitingForReview() async throws -> Results {
        let q = "is:pr is:open -review:approved -draft:true -label:not-for-review org:rabotaua author:@me"
        return try await search(query: q)
    }
    
    func myPullRequestsReadyToBeMerged() async throws -> Results {
        let q = "is:pr is:open review:approved author:@me"
        return try await search(query: q)
    }
}

struct Results: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Item]
}

struct Item: Decodable {
    let title: String
    let htmlUrl: URL
    let user: User
    let labels: [Label]
    let state: String
    let comments: Int
    let createdAt: Date
    let updatedAt: Date
    let draft: Bool
}

struct User: Decodable {
    let login: String
    let type: String
}

struct Label: Decodable {
    let name: String
}

enum GitHubError: Error {
    case invalidURL
    case badResponse
    case invalidJSON
    case credentialsMissing
}
