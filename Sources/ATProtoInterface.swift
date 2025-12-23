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
		for: String,
		provider: URLResponseProvider
	) async throws -> ServerMetadata

	func update(
		delegateRecord: GermLexicon.MessagingDelegateRecord,
		for: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws

	func updateKeyPackage(
		for: ATProtoDID,
		newHello: AnchorHello,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws

	func deleteKeyPackage(
		for: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws

	func createBlockRecord(
		for: ATProtoDID,
		subjectDID: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws
	
	func deleteBlockRecord(
		for: ATProtoDID,
		subjectDID: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws
	
	func fetchImage(
		did: ATProtoDID,
		cid: ATProtoDID.CID,
		pdsURL: URL,
	) async throws -> Data
}
