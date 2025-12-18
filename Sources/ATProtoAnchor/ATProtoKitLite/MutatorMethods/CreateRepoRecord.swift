//
//  CreateRepoRecord.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/2/25.
//  Created by Christopher Jr Riley on 2024-03-11.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {

	/// Creates a record attached to a user account.
	///
	/// - Warning: If you're using a lexicon that's not made by `com.atproto` or `app.bsky`,
	/// make sure you set `shouldValidate` to `false`. Failure to do so will result in an error
	/// that the lexicon isn't found.
	///
	/// - Note: According to the AT Protocol specifications: "Create a single new repository
	/// record. Requires auth, implemented by PDS."
	///
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/createRecord.json
	public static func createRecord(
		repository: String,
		collection: String,  // The Namespaced Identifier (NSID) of the record.
		recordKey: String? = nil,  // The record key of the collection. Optional.
		// Indicates whether the record should be validated. Optional.
		shouldValidate: Bool? = true,
		record: UnknownTypeLite,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> ComAtprotoLexiconLite.StrongReference {
		let requestURL = pdsURL.appending(path: "/xrpc/com.atproto.repo.createRecord")

		let requestBody = ComAtprotoLexiconLite.CreateRecordRequestBody(
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
