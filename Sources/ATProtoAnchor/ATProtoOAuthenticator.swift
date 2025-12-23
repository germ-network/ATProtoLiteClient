//
//  ATProtoOAuthenticator.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 1/31/25.
//

import CryptoKit
import Foundation
import OAuthenticator

//store the loginstore and DPoPKey that (O)Authenticator needs
public struct ATProtoOAuthenticator: Sendable {
	public let signer: DPoPSigner.JWTGenerator
	public let authenticator: Authenticator

	public init(
		handleOrDid: String?,
		pdsURL: URL,
		dpopSigner: @escaping DPoPSigner.JWTGenerator,
		loginStorage: LoginStorage,
	) async throws {
		let storageCopy = loginStorage
		signer = dpopSigner

		authenticator =
			try await Self
			.createATProtoAuthenticator(
				handleOrDid: handleOrDid,
				pdsURL: pdsURL,
				jwtGenerator: signer,
				loginStorage: storageCopy
			)
	}

	public static func createATProtoAuthenticator(
		handleOrDid: String?,
		pdsURL: URL,
		jwtGenerator: @escaping DPoPSigner.JWTGenerator,
		loginStorage: LoginStorage,
	) async throws -> Authenticator {
		let responseProvider = URLSession.defaultProvider
		let clientMetadataEndpoint = ATProtoConstants.OAuth.clientId

		let clientConfig = try await ClientMetadata.load(
			for: clientMetadataEndpoint, provider: responseProvider)

		guard let pdsHost = pdsURL.host() else {
			throw ATProtoAPIError.badUrl
		}

		let pdsMetadata = try await ProtectedResourceMetadata.load(
			for: pdsHost, provider: responseProvider)

		// We should probably check that we can create the DPoP signatures with one
		// of pdsMetadata.dpop_signing_alg_values_supported, or assert that it
		// contains ES256, sicne theoretically other dpop signing algorithms may be
		// used.

		guard
			let authorizationServers = pdsMetadata.authorizationServers,
			let authorizationServerUrl = authorizationServers.first,
			let authorizationServer = URL(string: authorizationServerUrl),
			let authorizationServerHost = authorizationServer.host()
		else {
			throw ATProtoAPIError.badUrl
		}

		let serverConfig = try await ServerMetadata.load(
			for: authorizationServerHost,
			provider: responseProvider
		)

		let tokenHandling = Bluesky.tokenHandling(
			account: handleOrDid,
			server: serverConfig,
			jwtGenerator: jwtGenerator
		)

		let config = Authenticator.Configuration(
			appCredentials: clientConfig.credentials,
			loginStorage: loginStorage,
			tokenHandling: tokenHandling
		)

		return Authenticator(config: config)
	}
}

// Creating and sending requests
extension ATProtoOAuthenticator {
	public static func createRequest(
		_ requestURL: URL,
		httpMethod: HTTPMethod,
		contentTypeValue: String? = "application/json"
	) -> URLRequest {
		var request = URLRequest(url: requestURL)
		request.httpMethod = httpMethod.rawValue
		if httpMethod == .post,
			let contentTypeValue
		{
			request.addValue(contentTypeValue, forHTTPHeaderField: "Content-Type")
		}
		return request
	}

	public static func sendAuthenticatedRequest(
		_ request: URLRequest,
		withEncodingBody body: (Encodable & Sendable)? = nil,
		authenticator: Authenticator
	) async throws -> Data {
		var urlRequest = request
		if let body = body {
			do {
				urlRequest.httpBody = try body.toJsonDataLite()
			} catch {
				throw ATProtoAPIError.failedToEncode
			}
		}
		let (data, resp) = try await authenticator.response(for: urlRequest)
		try ATProtoAPIErrorHandling.validate(data: data, resp: resp)
		return data
	}
}

public struct HTTPMethod: Sendable, Equatable {
	public static let get = HTTPMethod(rawValue: "GET")
	public static let post = HTTPMethod(rawValue: "POST")

	public let rawValue: String
}
