//
//  GetRepoRecord.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 2/8/24.
//

import Foundation

extension ATProtoKitLite {

	/// Searches for and validates a record from the repository.
	///
	/// - Note: According to the AT Protocol specifications: "Get a single record from a
	/// repository. Does not require auth."
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/getRecord.json
	static public func getRepositoryRecord(
		from repository: String,
		collection: String,  // The Namespaced Identifier (NSID) of the record.
		recordKey: String,  // The record key of the record.
		pdsURL: URL
	) async throws -> ComAtprotoLexiconLite.GetRecordOutput {
		// Add path
		var requestURL = pdsURL.appending(path: "/xrpc/com.atproto.repo.getRecord")

		// Add query items
		let queryItems = [
			URLQueryItem(name: "repo", value: repository),
			URLQueryItem(name: "collection", value: collection),
			URLQueryItem(name: "rkey", value: recordKey),
		]
		requestURL = requestURL.appending(queryItems: queryItems)

		// Create and send the request to this URL
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.get.rawValue
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		let (data, resp) = try await URLSession.shared.data(for: request)
		try ATProtoAPIErrorHandling.validate(data: data, resp: resp)

		// Decode the response data
		do {
			return try JSONDecoder().decode(
				ComAtprotoLexiconLite.GetRecordOutput.self,
				from: data)
		} catch {
			print(error)
			throw ATProtoAPIError.failedToDecodeJson
		}
	}
}
