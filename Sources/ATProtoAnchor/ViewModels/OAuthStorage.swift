//
//  OAuthStorage.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 8/2/25.
//

import CryptoKit
import Foundation
import OAuthenticator

///A more involved version of OAuthenticator.LoginStorage with a getter for the DPoP key
///And a way to clear the login

public struct OAuthStorage: Sendable {
	public typealias ClearLogin = @Sendable () async throws -> Void

	let dpopKey: P256.Signing.PrivateKey

	public let retrieveLogin: LoginStorage.RetrieveLogin
	public let storeLogin: LoginStorage.StoreLogin
	public let clearLogin: ClearLogin

	public init(
		dpopKey: P256.Signing.PrivateKey,
		retrieveLogin: @escaping LoginStorage.RetrieveLogin,
		storeLogin: @escaping LoginStorage.StoreLogin,
		clearLogin: @escaping ClearLogin
	) {
		self.dpopKey = dpopKey
		self.retrieveLogin = retrieveLogin
		self.storeLogin = storeLogin
		self.clearLogin = clearLogin
	}

	public var dPoPSigner: DPoPSigner.JWTGenerator {
		dpopKey.dPoPSigner
	}

	var loginStorage: LoginStorage {
		.init(retrieveLogin: retrieveLogin, storeLogin: storeLogin)
	}
}
