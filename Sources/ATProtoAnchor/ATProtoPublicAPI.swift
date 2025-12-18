//
//  ATProtoPublicAPI.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 2/21/25.
//

import ATResolve
import CommProtocol
import Foundation

// MARK: app.bsky
public enum ATProtoPublicAPI {
	public static func getProfileRecord(
		did: String,
		pdsURL: URL
	) async throws -> AppBskyLexiconLite.ProfileRecord {
		try await ATProtoKitLite.getProfileRecord(
			did: did,
			pdsURL: pdsURL
		)
	}
	public static func getHandle(
		did: String,
		pdsURL: URL
	) async throws -> String {
		try await ATProtoKitLite.getHandle(did: did, pdsURL: pdsURL)
	}
}

// MARK: com.germnetwork
extension ATProtoPublicAPI {
	public static func getGermMessagingDelegate(
		did: String,
		pdsURL: URL
	) async throws -> GermLexicon.MessagingDelegateRecord {
		await ATRecordTypeRegistryLite.shared.register(
			types: [GermLexicon.MessagingDelegateRecord.self]
		)

		let resp =
			try await ATProtoKitLite
			.getRepositoryRecord(
				from: did,
				collection: GermLexicon.MessagingDelegateRecord.type,
				recordKey: "self",
				pdsURL: pdsURL
			)
		guard
			let germMessagingDelegate = resp.value?.getRecord(
				ofType: GermLexicon.MessagingDelegateRecord.self)
		else {
			throw ATProtoAPIError.failedToDecodeRecord
		}
		return germMessagingDelegate
	}

	public static func getKeyPackage(
		did: String,
		pdsURL: URL
	) async throws -> GermLexicon.ArchivedKeyPackageRecord {
		await ATRecordTypeRegistryLite.shared.register(
			types: [GermLexicon.ArchivedKeyPackageRecord.self]
		)

		let resp =
			try await ATProtoKitLite
			.getRepositoryRecord(
				from: did,
				collection: GermLexicon.ArchivedKeyPackageRecord.type,
				recordKey: "self",
				pdsURL: pdsURL
			)
		guard
			let keyPackageRecord = resp.value?.getRecord(
				ofType: GermLexicon.ArchivedKeyPackageRecord.self)
		else {
			throw ATProtoAPIError.failedToDecodeRecord
		}
		return keyPackageRecord
	}
}

// MARK: com.atproto
extension ATProtoPublicAPI {
	public static func getBlob(
		from accountDID: String,
		cid: String,
		pdsURL: URL
	) async throws -> Data {
		try await ATProtoKitLite.getBlob(
			from: accountDID,
			cid: cid,
			pdsURL: pdsURL
		)
	}

	public static func getTypedDID(
		handle: String,
		cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy
	) async throws -> ATProtoDID {
		// Handles must be normalized into lowercase for outgoing API calls
		// https://atproto.com/specs/handle
		guard
			let did = try? await ATResolver(provider: URLSession.shared).didForHandle(
				handle.lowercased())
		else {
			throw ATProtoAPIError.badHandle
		}
		return try .init(fullId: did)
	}

	public static func getPds(for did: String) async throws -> String? {
		try await ATResolver(provider: URLSession.shared).plcDirectoryQuery(did).pds?
			.serviceEndpoint
	}

}

// MARK: app.bsky.graph
extension ATProtoPublicAPI {
	public static func getFollows(
		for did: String,
		pdsURL: URL
	) async -> ([String], Bool) {
		await ATProtoKitLite.getAllFollows(
			for: did,
			pdsURL: pdsURL
		)
	}

	public static func getFollowsStream(
		for did: String,
		pdsURL: URL
	) -> AsyncThrowingStream<[String], Error> {
		ATProtoKitLite.getFollowsStream(
			for: did,
			pdsURL: pdsURL
		)
	}

	//	public static func getBlocks(
	//		for did: String,
	//		pdsURL: URL
	//	) async -> ([String], Bool) {
	//		await ATProtoKitLite.getAllBlocks(
	//			for: did,
	//			pdsURL: pdsURL
	//		)
	//	}
	//
	//	public static func getBlocksStream(
	//		for did: String,
	//		pdsURL: URL
	//	) -> AsyncThrowingStream<[String], Error> {
	//		ATProtoKitLite.getBlocksStream(
	//			for: did,
	//			pdsURL: pdsURL
	//		)
	//	}

	public static func checkIf(
		did: String,
		follows anotherDID: String
	) async throws -> Bool {
		let relationship = try await ATProtoKitLite.getRelationship(
			between: did,
			and: anotherDID
		)
		return relationship.followingURI != nil
	}

	public static func checkIf(
		did: String,
		isFollowedBy anotherDID: String
	) async throws -> Bool {
		let relationship = try await ATProtoKitLite.getRelationship(
			between: did,
			and: anotherDID
		)
		return relationship.followedByURI != nil
	}
}
