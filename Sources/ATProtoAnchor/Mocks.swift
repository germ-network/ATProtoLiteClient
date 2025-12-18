//
//  Mocks.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 2/10/25.
//

import CryptoKit
import Foundation
import OAuthenticator

public struct MockDPoPKeyStore: Sendable {
	let dpopKey: P256.Signing.PrivateKey

	public init() {
		self.dpopKey = P256.Signing.PrivateKey()
	}

	public init(from dpopKey: P256.Signing.PrivateKey) {
		self.dpopKey = dpopKey
	}

	public func dpopSigner() throws -> DPoPSigner.JWTGenerator {
		{ (parameters: DPoPSigner.JWTParameters) async throws -> String in
			print(parameters)
			print("\n")

			let payload: any Encodable = {
				if let nonce = parameters.nonce,
					let authorizationServerIssuer = parameters.issuingServer,
					let accessTokenHash = parameters.tokenHash
				{
					DPoPRequestPayload(
						httpMethod: parameters.httpMethod,
						httpRequestURL: parameters.requestEndpoint,
						createdAt: Int(Date.now.timeIntervalSince1970),
						expiresAt: Int(
							Date.now.timeIntervalSince1970 + 3600),
						nonce: nonce,
						authorizationServerIssuer:
							authorizationServerIssuer,
						accessTokenHash: accessTokenHash
					)
				} else {
					DPoPTokenPayload(
						httpMethod: parameters.httpMethod,
						httpRequestURL: parameters.requestEndpoint,
						createdAt: Int(Date.now.timeIntervalSince1970),
						expiresAt: Int(
							Date.now.timeIntervalSince1970 + 3600),
						nonce: parameters.nonce
					)
				}
			}()

			return try await JWTSerializerLite.sign(
				payload,
				with: JWTLexiconLite.JWTHeader(
					typ: parameters.keyType,
					jwk: JWTLexiconLite.JWK(key: dpopKey)
				),
				using: ECDSASigner(key: dpopKey)
			)
		}
	}
}
