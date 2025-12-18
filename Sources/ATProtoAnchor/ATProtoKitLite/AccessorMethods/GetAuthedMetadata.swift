//
//  GetAuthedMetadata.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 9/15/25.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	public static func getAuthedMetadata(
		for did: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> AppBskyLexiconLite.ProfileAuthedMetadata {
		var requestURL = pdsURL.appending(path: "/xrpc/app.bsky.actor.getProfile")
		let queryItems = [URLQueryItem(name: "actor", value: did)]
		requestURL = requestURL.appending(queryItems: queryItems)

		// Create and send the request to this URL
		let request = ATProtoOAuthenticator.createRequest(
			requestURL,
			httpMethod: .get)
		let response = try await ATProtoOAuthenticator.sendAuthenticatedRequest(
			request, authenticator: authenticator)

		do {
			return try JSONDecoder().decode(
				AppBskyLexiconLite.ProfileAuthedMetadata.self,
				from: response)
		} catch {
			throw ATProtoAPIError.failedToDecodeJson
		}
	}
}
