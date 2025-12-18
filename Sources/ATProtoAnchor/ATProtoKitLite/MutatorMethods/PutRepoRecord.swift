//
//  PutRepoRecord.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/2/25.
//  Created by Christopher Jr Riley on 2024-03-11.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	/// Writes a record in the repository, which may replace a previous record.
	///
	/// - Note: According to the AT Protocol specifications: "Write a repository record, creating
	/// or updating it as needed. Requires auth, implemented by PDS."
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/putRecord.json
	public static func putRecord(
		repository: String,
		collection: String,  // The Namespaced Identifier (NSID) of the record.
		recordKey: String,  // The record key of the collection.
		// Indicates whether the record should be validated. Optional.
		shouldValidate: Bool? = true,
		record: UnknownTypeLite,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> ComAtprotoLexiconLite.StrongReference {
		let requestURL = pdsURL.appending(path: "/xrpc/com.atproto.repo.putRecord")

		let requestBody = ComAtprotoLexiconLite.PutRecordRequestBody(
			repository: repository,
			collection: collection,
			recordKey: recordKey,
			shouldValidate: shouldValidate,
			record: record
		)

		let request = ATProtoOAuthenticator.createRequest(
			requestURL,
			httpMethod: .post,
			contentTypeValue: "application/json"
		)
		let response = try await ATProtoOAuthenticator.sendAuthenticatedRequest(
			request,
			withEncodingBody: requestBody,
			authenticator: authenticator
		)

		do {
			return try JSONDecoder().decode(
				ComAtprotoLexiconLite.StrongReference.self,
				from: response)
		} catch {
			throw ATProtoAPIError.failedToDecodeJson
		}
	}
}
