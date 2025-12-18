//
//  ResolveHandle.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 1/27/24.
//

import Foundation

extension ATProtoKitLite {

	/// Retrieves a decentralized identifier (DID) based on a given handle from a specified
	/// Personal Data Server (PDS).
	///
	/// - Note: According to the AT Protocol specifications: "Resolves a handle (domain name)
	/// to a DID."
	///
	/// - SeeAlso: This is based on the [`com.atproto.identity.resolveHandle`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/identity/resolveHandle.json
	///
	/// - Parameters:
	///   - handle: The handle to resolve into a decentralized identifier (DID).
	///   - pdsURL: The URL of the PDS to request from
	/// - Returns: The resolved handle's decentralized identifier (DID).
	///
	/// - Throws: An ``ATProtoError``-conforming error type, depending on the issue. Go to
	/// ``ATAPIError`` and ``ATRequestPrepareError`` for more details.
	//	static public func resolveHandle(
	//		from handle: String,
	//		pdsURL: URL,
	//		cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy
	//	) async throws -> ResolveHandleOutput {
	//		// Add path
	//		var requestURL = pdsURL.appending(path: "/xrpc/com.atproto.identity.resolveHandle")
	//
	//		// Add query items
	//		let queryItems = [
	//			URLQueryItem(name: "handle", value: handle)
	//		]
	//		requestURL = requestURL.appending(queryItems: queryItems)
	//
	//		// Create and send the request to this URL
	//		var request = URLRequest(url: requestURL)
	//		request.httpMethod = HTTPMethod.get.rawValue
	//		request.addValue("application/json", forHTTPHeaderField: "Accept")
	//		request.cachePolicy = cachePolicy
	//		let (data, resp) = try await URLSession.shared.data(for: request)
	//
	//		if let httpResp = resp as? HTTPURLResponse {
	//			if httpResp.statusCode != 200 {
	//				throw ATProtoAPIError.badResponse
	//			}
	//		}
	//
	//		// Decode the response data
	//		do {
	//			return try JSONDecoder().decode(
	//				ResolveHandleOutput.self,
	//				from: data)
	//		} catch {
	//			print(error)
	//			throw ATProtoAPIError.failedToDecodeJson
	//		}
	//	}
}
