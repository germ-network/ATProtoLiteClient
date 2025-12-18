//
//  GetBlocks.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 6/2/25.
//  Created by Christopher Jr Riley on 2024-03-08.
//

import Foundation
import OAuthenticator

//extension ATProtoKitLite {
//	/// Returns a tuple:
//	/// - List of DIDs this DID is blocking
//	/// - Bool of whether or not the list is complete (false if we error)
//	public static func getAllBlocks(
//		for did: String,
//		pdsURL: URL
//	) async -> ([String], Bool) {
//		var cursor: String? = nil
//		var blocksList: [String] = []
//		repeat {
//			do {
//				let blocks = try await ATProtoKitLite.getBlocks(
//					for: did,
//					cursor: cursor,
//					pdsURL: pdsURL
//				)
//				let blockedDids = blocks.1.map { $0.subjectDID }
//				blocksList.append(contentsOf: blockedDids)
//				cursor = blocks.0
//			} catch {
//				print("Error fetching blocks: \(error)")
//				return (blocksList, false)
//			}
//		} while cursor != nil
//		return (blocksList, true)
//	}
//
//	public static func getBlocksStream(
//		for did: String,
//		pdsURL: URL
//	) -> AsyncThrowingStream<[String], Error> {
//		let (stream, continuation) = AsyncThrowingStream<[String], Error>
//			.makeStream(bufferingPolicy: .unbounded)
//		Task {
//			var cursor: String? = nil
//			var fetchCount = 0
//			do {
//				repeat {
//					let (next, blocks) = try await ATProtoKitLite.getBlocks(
//						for: did,
//						cursor: cursor,
//						pdsURL: pdsURL
//					)
//					let blockingDids = blocks.map { $0.subjectDID }
//					continuation.yield(blockingDids)
//					cursor = next
//					fetchCount += 1
//				} while cursor != nil && fetchCount < ATProtoConstants.maxFetches
//				continuation.finish()
//			} catch {
//				continuation.finish(throwing: error)
//			}
//		}
//		return stream
//	}
//}
//
//extension ATProtoKitLite {
//	public static func getBlocks(
//		for actorDID: String,
//		limit: Int? = 100,
//		cursor: String? = nil,
//		pdsURL: URL
//	) async throws -> (String?, [AppBskyLexiconLite.BlockRecord]) {
//
//		await ATRecordTypeRegistryLite.shared.register(
//			types: [AppBskyLexiconLite.BlockRecord.self]
//		)
//
//		let repoListOutput = try await listRepoRecords(
//			for: actorDID,
//			collection: "app.bsky.graph.block",
//			limit: limit,
//			cursor: cursor,
//			pdsURL: pdsURL
//		)
//
//		let blocks = try repoListOutput.records.map {
//			guard
//				let block = $0.value?.getRecord(
//					ofType: AppBskyLexiconLite.BlockRecord.self)
//			else {
//				throw ATProtoAPIError.failedToDecodeRecord
//			}
//			return block
//		}
//
//		return (repoListOutput.cursor, blocks)
//	}
//}
