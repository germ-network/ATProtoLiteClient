//
//  ATProtoInterface.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/22/25.
//

import CommProtocol
import Foundation
import OAuthenticator

//lets us stub out online interfaces related to ATProto
//for local testing
public protocol ATProtoInterface: Sendable {
	func loadServerMetadata(
		for host: String,
		provider: URLResponseProvider
	) async throws -> ServerMetadata

	func update(
		delegateRecord: GermLexicon.MessagingDelegateRecord,
		for did: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws

	func deleteKeyPackage(
		for did: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws
}
