//
//  RefreshSession.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 1/15/26.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	public static func refreshSession(
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> ComAtprotoLexiconLite.RefreshSessionOutput {
		let requestURL = pdsURL.appending(path: "/xrpc/com.atproto.server.refreshSession")

		// Create and send the request to this URL
		let request = ATProtoOAuthenticator.createRequest(
			requestURL,
			httpMethod: .post)
		let response = try await ATProtoOAuthenticator.sendAuthenticatedRequest(
			request, authenticator: authenticator)

		do {
			return try JSONDecoder().decode(
				ComAtprotoLexiconLite.RefreshSessionOutput.self,
				from: response)
		} catch {
			throw ATProtoAPIError.failedToDecodeJson
		}
	}
}
