//
//  GetRelationships.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 9/15/25.
//

import Foundation

extension ATProtoKitLite {
	/// Run on Bluesky's AppView (public.api.bsky.app)
	/// Probably won't work if Bluesky has them blocked from their AppView, but we can allowlist other AppViews
	/// another time.
	public static func getRelationship(
		between did: String,
		and other: String
	) async throws -> AppBskyLexiconLite.RelationshipDefinition {
		let relationship = try await getRelationships(between: did, and: [other])
			.relationships.first.tryUnwrap
		guard case .relationship(let relationshipDefinition) = relationship else {
			throw ATProtoAPIError.recordNotFound
		}
		return relationshipDefinition
	}

	public static func getRelationships(
		between did: String,
		and others: [String]
	) async throws -> AppBskyLexiconLite.GetRelationshipsOutput {
		// We make this as an unauthed call to Bluesky's public API
		guard let publicAPI = URL(string: ATProtoConstants.publicAPI) else {
			throw ATProtoAPIError.badUrl
		}
		var requestURL = publicAPI.appending(path: "/xrpc/app.bsky.graph.getRelationships")

		guard others.count <= 30 else {
			throw ATProtoAPIError.badRequest
		}

		// Add query items
		var queryItems = [URLQueryItem(name: "actor", value: did)]
		queryItems += others.map { URLQueryItem(name: "others", value: $0) }

		requestURL = requestURL.appending(queryItems: queryItems)

		// Create and send the request to this URL
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.get.rawValue
		request.addValue("'*/*'", forHTTPHeaderField: "Accept")
		let (data, resp) = try await URLSession.shared.data(for: request)
		try ATProtoAPIErrorHandling.validate(data: data, resp: resp)

		return try JSONDecoder().decode(
			AppBskyLexiconLite.GetRelationshipsOutput.self, from: data)
	}
}
