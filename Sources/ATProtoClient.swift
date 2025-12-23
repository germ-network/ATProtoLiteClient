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

	public func pdsUrlFetcher() -> (ATProtoDID) async throws -> URL {
		{
			let pds =
				try await ATProtoPublicAPI
				.getPds(for: $0.fullId)
				.tryUnwrap

			return try URL(string: pds).tryUnwrap
		}
	}

	public func profileRecordPDSFetcher()
		async -> (ATProtoDID, URL) async throws -> ATProtoDID.ProfileRecord
	{
		{ (did, pdsURL) in
			let result =
				try await ATProtoPublicAPI
				.getProfileRecord(did: did.fullId, pdsURL: pdsURL)

			return .init(
				displayName: result.displayName,
				profileText: result.description,
				avatarCid: result.avatarBlob?.reference
					.link,
				bannerCid: result.bannerBlob?.reference
					.link,
			)
		}
	}

	public func handleFetcher() async -> (ATProtoDID, URL) async throws -> String {
		{ (did, pdsUrl) in
			try await ATProtoPublicAPI.getHandle(
				did: did.fullId,
				pdsURL: pdsUrl
			)
		}
	}

	public func messageDelegateFetcher() async -> (ATProtoDID, URL) async throws ->
		GermLexicon.MessagingDelegateRecord
	{
		{ (did, pdsUrl) in
			try await ATProtoPublicAPI.getGermMessagingDelegate(
				did: did.fullId,
				pdsURL: pdsUrl
			)
		}
	}

	public func followsFetcher(did: ATProtoDID, pdsUrl: URL) async -> AsyncThrowingStream<
		[String], any Error
	> {
		ATProtoPublicAPI.getFollowsStream(
			for: did.fullId,
			pdsURL: pdsUrl
		)
	}

	public func anchorIntroductionFetcher() async -> (
		ATProtoDID,
		URL,
		AnchorPublicKey
	) async throws -> AnchorHello.Verified.Archive? {
		{ (did, pdsUrl, anchorPubKey) in
			do {
				let record =
					try await ATProtoPublicAPI.getKeyPackage(
						did: did.fullId,
						pdsURL: pdsUrl
					)
				let anchorHello = try AnchorHello.finalParse(
					record.anchorHello
				)
				.tryUnwrap

				do {
					return try anchorPubKey.verify(
						hello: anchorHello,
						for: .init(anchorTo: did)
					).archive
				} catch {
					// If verification fails, we want to return nil to overwrite the
					// old value (to alert us that it's broken) instead of throwing,
					// which would discard the new value
					return nil
				}
			} catch ATProtoAPIError.recordNotFound {
				return nil
			}
		}
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

	public func fetchImage(
		did: ATProtoDID,
		cid: ATProtoDID.CID,
		pdsURL: URL
	) async throws -> Data {
		try await ATProtoPublicAPI.getBlob(
			from: did.fullId,
			cid: cid,
			pdsURL: pdsURL
		)
	}

	public func updateBio(
		for did: ATProtoDID,
		newBio: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		let _ = try await ATProtoAuthAPI.updateBio(
			for: did.fullId,
			newBio: newBio,
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}
}
