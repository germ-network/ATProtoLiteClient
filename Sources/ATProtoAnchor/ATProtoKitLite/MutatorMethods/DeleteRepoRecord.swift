//
//  DeleteRepoRecord.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/2/25.
//  Created by Christopher Jr Riley on 2024-03-11.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	public static func deleteRecord(
		repository: String,
		collection: String,
		recordKey: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		let requestURL = pdsURL.appending(path: "/xrpc/com.atproto.repo.deleteRecord")
		let requestBody = ComAtprotoLexiconLite.DeleteRecordRequestBody(
			repository: repository,
			collection: collection,
			recordKey: recordKey
		)
		let request = ATProtoOAuthenticator.createRequest(
			requestURL,
			httpMethod: .post,
			contentTypeValue: "application/json"
		)
		let _ = try await ATProtoOAuthenticator.sendAuthenticatedRequest(
			request,
			withEncodingBody: requestBody,
			authenticator: authenticator
		)
	}
}
