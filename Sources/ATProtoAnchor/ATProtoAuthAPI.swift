//
//  ATProtoAuthAPI.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/2/25.
//

import Foundation
import OAuthenticator

public enum ATProtoAuthAPI {
	public static func updateBio(
		for did: String,
		newBio: String,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws -> ComAtprotoLexiconLite.StrongReference {
		let profileRecord = try await ATProtoPublicAPI.getProfileRecord(
			did: did,
			pdsURL: pdsURL
		)

		// Make a copy of the existing record with a new bio
		let newProfileRecord = AppBskyLexiconLite.ProfileRecord.init(
			displayName: profileRecord.displayName,
			description: newBio,
			avatarBlob: profileRecord.avatarBlob,
			bannerBlob: profileRecord.bannerBlob,
			labels: profileRecord.labels,
			joinedViaStarterPack: profileRecord.joinedViaStarterPack,
			pinnedPost: profileRecord.pinnedPost,
			createdAt: profileRecord.createdAt
		)

		return try await ATProtoKitLite.putRecord(
			repository: did,
			collection: "app.bsky.actor.profile",
			recordKey: "self",
			shouldValidate: true,
			record: .record(newProfileRecord),
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public static func update(
		delegateRecord: GermLexicon.MessagingDelegateRecord,
		for did: String,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws -> ComAtprotoLexiconLite.StrongReference {
		return try await ATProtoKitLite.putRecord(
			repository: did,
			collection: "com.germnetwork.declaration",
			recordKey: "self",
			shouldValidate: false,  // TODO: GER-1196 - Validate lexicon
			record: .record(delegateRecord),
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public static func deleteDelegateRecord(
		for did: String,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws {
		try await ATProtoKitLite.deleteRecord(
			repository: did,
			collection: "com.germnetwork.declaration",
			recordKey: "self",
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public static func updateKeyPackage(
		for did: String,
		newHello: Data,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws -> ComAtprotoLexiconLite.StrongReference {
		let hello = GermLexicon.ArchivedKeyPackageRecord(anchorHello: newHello)
		return try await ATProtoKitLite.putRecord(
			repository: did,
			collection: "com.germnetwork.keypackage",
			recordKey: "self",
			shouldValidate: false,  // Bluesky doesn't recognize this lexicon type
			record: .record(hello),
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public static func deleteKeyPackage(
		for did: String,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws {
		try await ATProtoKitLite.deleteRecord(
			repository: did,
			collection: "com.germnetwork.keypackage",
			recordKey: "self",
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	public static func createBlockRecord(
		for did: String,
		subjectDID: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		let block = AppBskyLexiconLite.BlockRecord(
			subjectDID: subjectDID,
			createdAt: Date()
		)
		let _ = try await ATProtoKitLite.createRecord(
			repository: did,
			collection: "app.bsky.graph.block",
			shouldValidate: true,
			record: .record(block),
			pdsURL: pdsURL,
			authenticator: authenticator
		)
	}

	// TODO: This doesn't work with block lists. But that's a whole new bag of worms.
	public static func deleteBlockRecord(
		for did: String,
		subjectDID: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		// TODO: We could make this faster if we store the block record key
		var cursor: String? = nil
		var fetchCount = 0
		repeat {
			let repoList = try await ATProtoKitLite.listRepoRecords(
				for: did,
				collection: "app.bsky.graph.block",
				cursor: cursor,
				pdsURL: pdsURL
			)
			for record in repoList.records {
				let block = record.value?.getRecord(
					ofType: AppBskyLexiconLite.BlockRecord.self
				)
				if subjectDID == block?.subjectDID {
					if let recordKey = record.uri.split(separator: "/").last {
						try await ATProtoKitLite.deleteRecord(
							repository: did,
							collection: "app.bsky.graph.block",
							recordKey: String(recordKey),
							pdsURL: pdsURL,
							authenticator: authenticator
						)
					}
					return
				}
			}
			cursor = repoList.cursor
			fetchCount += 1
		} while cursor != nil && fetchCount < ATProtoConstants.maxFetches
	}
}

// Authed metadata functions
extension ATProtoAuthAPI {
	public static func getAuthedMetadata(
		for did: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> AppBskyLexiconLite.ViewerStateDefinition {
		guard
			let metadata = try await ATProtoKitLite.getAuthedMetadata(
				for: did,
				pdsURL: pdsURL,
				authenticator: authenticator
			).viewer
		else {
			throw ATProtoAPIError.recordNotFound
		}
		return metadata
	}

	public static func checkIfMyAnchorBlocks(
		_ did: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> Bool {
		guard
			let metadata = try await ATProtoKitLite.getAuthedMetadata(
				for: did,
				pdsURL: pdsURL,
				authenticator: authenticator
			).viewer
		else {
			throw ATProtoAPIError.recordNotFound
		}
		return metadata.blockingURI != nil
	}

	public static func checkIfMyAnchorIsBlocked(
		by did: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws -> Bool {
		guard
			let metadata = try await ATProtoKitLite.getAuthedMetadata(
				for: did,
				pdsURL: pdsURL,
				authenticator: authenticator
			).viewer, let isBlocked = metadata.isBlocked
		else {
			throw ATProtoAPIError.recordNotFound
		}
		return isBlocked
	}
}
