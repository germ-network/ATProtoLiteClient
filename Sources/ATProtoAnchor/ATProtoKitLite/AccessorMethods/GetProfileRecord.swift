//
//  GetProfileRecord.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 2/18/24.
//

import Foundation
import OAuthenticator

extension ATProtoKitLite {
	public static func getProfileRecord(
		did: String,
		pdsURL: URL
	) async throws -> AppBskyLexiconLite.ProfileRecord {
		await ATRecordTypeRegistryLite.shared.register(
			types: [AppBskyLexiconLite.ProfileRecord.self]
		)

		let resp =
			try await ATProtoKitLite
			.getRepositoryRecord(
				from: did,
				collection: AppBskyLexiconLite.ProfileRecord.type,
				recordKey: "self",
				pdsURL: pdsURL
			)
		guard
			let profileRecord = resp.value?.getRecord(
				ofType: AppBskyLexiconLite.ProfileRecord.self)
		else {
			throw ATProtoAPIError.failedToDecodeRecord
		}
		return profileRecord
	}
}
