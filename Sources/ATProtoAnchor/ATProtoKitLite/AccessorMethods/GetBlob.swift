//
//  GetBlob.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/29/25.
//  Created by Christopher Jr Riley on 2024-02-10.
//

import Foundation

extension ATProtoKitLite {

	/// Retrieves a blob from a given record.
	///
	/// - Note: According to the AT Protocol specifications: "Get a blob associated with a given
	/// account. Returns the full blob as originally uploaded. Does not require auth; implemented
	/// by PDS."
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/sync/getBlob.json
	static public func getBlob(
		from accountDID: String,
		cid: String,  // CID hash of the blob
		pdsURL: URL
	) async throws -> Data {
		// Add path
		var requestURL = pdsURL.appending(path: "/xrpc/com.atproto.sync.getBlob")

		// Add query items
		let queryItems = [
			URLQueryItem(name: "did", value: accountDID),
			URLQueryItem(name: "cid", value: cid),
		]
		requestURL = requestURL.appending(queryItems: queryItems)

		// Create and send the request to this URL
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.get.rawValue
		request.addValue("'*/*'", forHTTPHeaderField: "Accept")
		let (data, resp) = try await URLSession.shared.data(for: request)
		try ATProtoAPIErrorHandling.validate(data: data, resp: resp)
		return data
	}
}
