//
//  ListRepoRecords.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/11/25.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	public static func listRepoRecords(
		for actorDID: String,
		collection: String,
		limit: Int? = 100,
		cursor: String? = nil,
		pdsURL: URL
	) async throws -> ComAtprotoLexiconLite.ListRecordsOutput {
		var requestURL = pdsURL.appending(path: "/xrpc/com.atproto.repo.listRecords")

		// Add query items
		var queryItems = [
			URLQueryItem(name: "repo", value: actorDID),
			URLQueryItem(name: "collection", value: collection),
		]
		if let limit {
			let finalLimit = max(1, min(limit, 100))
			queryItems.append(URLQueryItem(name: "limit", value: "\(finalLimit)"))
		}
		if let cursor {
			queryItems.append(URLQueryItem(name: "cursor", value: cursor))
		}
		requestURL = requestURL.appending(queryItems: queryItems)

		// Send the request
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.get.rawValue
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		let (data, resp) = try await URLSession.shared.data(for: request)
		try ATProtoAPIErrorHandling.validate(data: data, resp: resp)

		// Decode the response data
		do {
			return try JSONDecoder().decode(
				ComAtprotoLexiconLite.ListRecordsOutput.self,
				from: data)
		} catch {
			print(error)
			throw ATProtoAPIError.failedToDecodeJson
		}
	}
}
