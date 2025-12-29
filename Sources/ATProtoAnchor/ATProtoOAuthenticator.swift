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
	private let authenticator: Authenticator

	public init(
		handleOrDid: String?,
		pdsURL: URL,
		dpopSigner: @escaping DPoPSigner.JWTGenerator,
		loginStorage: LoginStorage,
		atProtoClient: ATProtoInterface
	) async throws {
		let storageCopy = loginStorage
		signer = dpopSigner

		authenticator =
			try await Self
			.createATProtoAuthenticator(
				handleOrDid: handleOrDid,
				pdsURL: pdsURL,
				jwtGenerator: signer,
				loginStorage: storageCopy,
				atProtoClient: atProtoClient
			)
	}

	public static func createATProtoAuthenticator(
		handleOrDid: String?,
		pdsURL: URL,
		jwtGenerator: @escaping DPoPSigner.JWTGenerator,
		loginStorage: LoginStorage,
		atProtoClient: ATProtoInterface,
	) async throws -> Authenticator {
		let responseProvider = URLSession.defaultProvider
		let clientMetadataEndpoint = ATProtoConstants.OAuth.clientId

		let clientConfig = try await atProtoClient.loadClientMetadata(
			for: clientMetadataEndpoint,
			provider: responseProvider
		)

		guard let pdsHost = pdsURL.host() else {
			throw ATProtoAPIError.badUrl
		}

		let pdsMetadata = try await atProtoClient.loadProtectedResourceMetadata(
			for: pdsHost,
			provider: responseProvider
		)

		//https://datatracker.ietf.org/doc/html/rfc7518#section-3.1
		//PDS doesn't actually fill this field, so we only check it if present
		if let supportedAlgs = pdsMetadata.dpopSigningAlgValuesSupported {
			guard supportedAlgs.contains("ES256")
			else {
				throw ATProtoAPIError.notImplemented
			}
		}

		guard
			let authorizationServerUrl = pdsMetadata.authorizationServers?.first,
			let authorizationServerHost = URL(string: authorizationServerUrl)?.host()
		else {
			throw ATProtoAPIError.badUrl
		}

		let serverConfig = try await atProtoClient.loadServerMetadata(
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

// Authentication - capture initial authentication and pass-through to
// authenticate
extension ATProtoOAuthenticator {
	public func authenticate() async throws {
		try await authenticator.authenticate()
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
