//
//  GetFollows.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/2/25.
//  Created by Christopher Jr Riley on 2024-03-08.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	/// Returns a tuple:
	/// - List of DIDs this DID is following
	/// - Bool of whether or not the list is complete (false if we error)
	public static func getAllFollows(
		for did: String,
		pdsURL: URL
	) async -> ([String], Bool) {
		var cursor: String? = nil
		var followsList: [String] = []
		repeat {
			do {
				let follows = try await ATProtoKitLite.getFollows(
					for: did,
					cursor: cursor,
					pdsURL: pdsURL
				)
				let followingDids = follows.1.map { $0.subjectDID }
				followsList.append(contentsOf: followingDids)
				cursor = follows.0
			} catch {
				print("Error fetching follows: \(error)")
				return (followsList, false)
			}
		} while cursor != nil
		return (followsList, true)
	}

	public static func getFollowsStream(
		for did: String,
		pdsURL: URL
	) -> AsyncThrowingStream<[String], Error> {
		let (stream, continuation) = AsyncThrowingStream<[String], Error>
			.makeStream(bufferingPolicy: .unbounded)
		Task {
			var cursor: String? = nil
			var fetchCount = 0
			do {
				repeat {
					let (next, follows) = try await ATProtoKitLite.getFollows(
						for: did,
						cursor: cursor,
						pdsURL: pdsURL
					)
					let followingDids = follows.map { $0.subjectDID }
					continuation.yield(followingDids)
					cursor = next
					fetchCount += 1
				} while cursor != nil && fetchCount < ATProtoConstants.maxFetches
				continuation.finish()
			} catch {
				continuation.finish(throwing: error)
			}
		}
		return stream
	}
}

extension ATProtoKitLite {

	/// Gets all of the accounts the user account follows.
	///
	/// - Note: According to the AT Protocol specifications: "Enumerates accounts which a
	/// specified account (actor) follows."
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/graph/getFollows.json
	private static func getFollows(
		for actorDID: String,
		limit: Int? = 100,
		cursor: String? = nil,
		pdsURL: URL
	) async throws -> (String?, [AppBskyLexiconLite.FollowRecord]) {
		await ATRecordTypeRegistryLite.shared.register(
			types: [AppBskyLexiconLite.FollowRecord.self]
		)

		let repoListOutput = try await listRepoRecords(
			for: actorDID,
			collection: "app.bsky.graph.follow",
			limit: limit,
			cursor: cursor,
			pdsURL: pdsURL
		)

		let follows = try repoListOutput.records.map {
			guard
				let block = $0.value?.getRecord(
					ofType: AppBskyLexiconLite.FollowRecord.self)
			else {
				throw ATProtoAPIError.failedToDecodeRecord
			}
			return block
		}

		return (repoListOutput.cursor, follows)
	}
}
