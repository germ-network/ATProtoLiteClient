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

	func loadClientMetadata(
		for: String,
		provider: URLResponseProvider
	) async throws -> ClientMetadata

	func pdsUrlFetcher() async -> ((ATProtoDID) async throws -> URL)
	func profileRecordPDSFetcher() async -> (
		(ATProtoDID, URL) async throws -> ATProtoDID.ProfileRecord
	)
	func handleFetcher() async -> (
		(ATProtoDID, URL) async throws -> String
	)
	func messageDelegateFetcher() async -> (
		(ATProtoDID, URL) async throws -> GermLexicon.MessagingDelegateRecord
	)
	func followsFetcher(
		did: ATProtoDID,
		pdsUrl: URL
	) async -> AsyncThrowingStream<[String], any Error>
	//to be deprecated
	func anchorIntroductionFetcher() async -> (
		(
			ATProtoDID,
			URL,
			AnchorPublicKey
		) async throws -> AnchorHello.Verified.Archive?
	)

	func update(
		delegateRecord: GermLexicon.MessagingDelegateRecord,
		for: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws

	func deleteDelegateRecord(
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

	//Deprecate
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

	func updateBio(
		for did: ATProtoDID,
		newBio: String,
		pdsURL: URL,
		authenticator: Authenticator,
	) async throws
}
