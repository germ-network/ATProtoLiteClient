//
//  LoginViewModel.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 8/1/25.
//

import CommProtocol
import CryptoKit
import Foundation
import OAuthenticator
import SwiftUI
import os

//simpler version of the App LoginViewModel
//defers handle collection and validation to the parent
@MainActor
@Observable public class ATProtoLiteClientViewModel {
	static let logger = Logger(
		subsystem: "com.germnetwork.ATProtoLiteClient",
		category: "ATProtoLiteClientViewModel")

	public typealias LoginSource = (ATProtoDID) async -> (OAuthStorage)

	public let handle: String
	public let did: ATProtoDID

	//interface to where login is actually stored
	let oauthStorage: OAuthStorage

	//authenticator object generated from the loginCredential
	public var _authenticator: ATProtoOAuthenticator? = nil

	static public func create(
		handle: String,
		loginSource: @escaping LoginSource,
		cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy
	) -> Task<ATProtoLiteClientViewModel, Error> {
		Task {
			let did =
				try await ATProtoPublicAPI
				.getTypedDID(
					handle: handle,
					cachePolicy: cachePolicy
				)

			return ATProtoLiteClientViewModel(
				handle: handle,
				did: did,
				oauthStorage: await loginSource(did)
			)
		}
	}

	public init(
		handle: String,
		did: ATProtoDID,
		oauthStorage: OAuthStorage
	) {
		self.handle = handle
		self.did = did
		self.oauthStorage = oauthStorage
	}

	//lazily get
	public func getAuthenticator(
		pdsURL: URL
	) async throws -> ATProtoOAuthenticator {
		if let _authenticator { return _authenticator }
		let newAuthenticator = try await ATProtoOAuthenticator(
			handleOrDid: handle,
			pdsURL: pdsURL,
			dpopSigner: oauthStorage.dPoPSigner,
			loginStorage: oauthStorage.loginStorage
		)
		self._authenticator = newAuthenticator
		return newAuthenticator
	}

	public func clearLogin() {
		Task {
			do {
				try await oauthStorage.clearLogin()
				_authenticator = nil
			} catch {
				Self.logger.error(
					"Error: clear login \(error.localizedDescription)")
			}
		}
	}
}
