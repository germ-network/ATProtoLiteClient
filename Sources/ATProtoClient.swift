//
//  ATProtoClient.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/22/25.
//

import CommProtocol
import Foundation
import OAuthenticator

public struct ATProtoClient: ATProtoInterface {
	public init() {}

	public func loadServerMetadata(
		for host: String,
		provider: @Sendable (URLRequest) async throws -> (Data, URLResponse)
	) async throws -> ServerMetadata {
		try await .load(for: host, provider: provider)
	}

	public func update(
		delegateRecord: GermLexicon.MessagingDelegateRecord,
		for did: ATProtoDID,
		pdsURL: URL,
		authenticator: OAuthenticator.Authenticator
	) async throws {
		let _ = try await ATProtoAuthAPI.update(
			delegateRecord: delegateRecord,
			for: did.fullId,
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public func updateKeyPackage(
		for did: ATProtoDID,
		newHello: AnchorHello,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		let _ = try await ATProtoAuthAPI.updateKeyPackage(
			for: did.fullId,
			newHello: try newHello.wireFormat,
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public func deleteKeyPackage(
		for did: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		try await ATProtoAuthAPI.deleteKeyPackage(
			for: did.fullId,
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public func createBlockRecord(
		for myDid: ATProtoDID,
		subjectDID: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		try await ATProtoAuthAPI.createBlockRecord(
			for: myDid.fullId,
			subjectDID: subjectDID.fullId,
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}
	
	public func deleteBlockRecord(
		for myDid: ATProtoDID,
		subjectDID: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		try await ATProtoAuthAPI
			.deleteBlockRecord(
				for: myDid.fullId,
				subjectDID: subjectDID.fullId,
				pdsURL: pdsURL,
				authenticator: authenticator
			)
	}
}
