//
//  MockATProto.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/22/25.
//

import CommProtocol
import Foundation
import OAuthenticator
import os

public actor MockATProto {
	static let logger = Logger(
		subsystem: "ATProtoLiteClient",
		category: "MockATProto"
	)
	public init() {}

	var resolvePDS: [ATProtoDID: URL] = [:]
	var pdsTable: [URL: MockPDS] = [:]

	private var holdPDS: (AsyncStream<Void>, AsyncStream<Void>.Continuation)?
}

extension MockATProto {
	func holdPDSResponses() {
		assert(holdPDS == nil)
		holdPDS = AsyncStream<Void>.makeStream()
	}

	func releaseHold() {
		assert(holdPDS != nil)
		if let holdPDS {
			self.holdPDS = nil
			holdPDS.1.yield()
			holdPDS.1.finish()
		}
	}

	func awaitHold() async {
		if let holdPDS {
			for await _ in holdPDS.0 {
				print("waiting")
			}
			print("finished")
		}
	}

	public func createDid(handle: String = UUID().uuidString) throws -> ATProtoDID {
		let newDid = ATProtoDID.mock()
		let newUrl = URL(string: "https://example.com/\(UUID().uuidString)")!

		assert(resolvePDS[newDid] == nil)
		assert(pdsTable[newUrl] == nil)

		resolvePDS[newDid] = newUrl
		pdsTable[newUrl] = .init(handle: handle)

		return newDid
	}
}

extension MockATProto: ATProtoInterface {
	public func loadServerMetadata(
		for host: String,
		provider: (URLRequest) async throws -> (Data, URLResponse)
	) throws -> ServerMetadata {
		try JSONDecoder().decode(
			ServerMetadata.self,
			from:
				"""
				{"issuer":"https://bsky.social","request_parameter_supported":true,"request_uri_parameter_supported":true,"require_request_uri_registration":true,"scopes_supported":["atproto","transition:email","transition:generic","transition:chat.bsky"],"subject_types_supported":["public"],"response_types_supported":["code"],"response_modes_supported":["query","fragment","form_post"],"grant_types_supported":["authorization_code","refresh_token"],"code_challenge_methods_supported":["S256"],"ui_locales_supported":["en-US"],"display_values_supported":["page","popup","touch"],"request_object_signing_alg_values_supported":["RS256","RS384","RS512","PS256","PS384","PS512","ES256","ES256K","ES384","ES512","none"],"authorization_response_iss_parameter_supported":true,"request_object_encryption_alg_values_supported":[],"request_object_encryption_enc_values_supported":[],"jwks_uri":"https://bsky.social/oauth/jwks","authorization_endpoint":"https://bsky.social/oauth/authorize","token_endpoint":"https://bsky.social/oauth/token","token_endpoint_auth_methods_supported":["none","private_key_jwt"],"token_endpoint_auth_signing_alg_values_supported":["RS256","RS384","RS512","PS256","PS384","PS512","ES256","ES256K","ES384","ES512"],"revocation_endpoint":"https://bsky.social/oauth/revoke","pushed_authorization_request_endpoint":"https://bsky.social/oauth/par","require_pushed_authorization_requests":true,"dpop_signing_alg_values_supported":["RS256","RS384","RS512","PS256","PS384","PS512","ES256","ES256K","ES384","ES512"],"client_id_metadata_document_supported":true}
				""".utf8Data
		)
	}

	public func pdsUrlFetcher() -> @Sendable (ATProtoDID) async throws -> URL {
		{ try await self.resolvePDS[$0].tryUnwrap }
	}

	public func profileRecordPDSFetcher()
		async -> @Sendable (ATProtoDID, URL) async throws -> ATProtoDID.ProfileRecord
	{
		{
			(did, _) in try await self.profileRecord(for: did).tryUnwrap
		}
	}

	public func handleFetcher() async -> @Sendable (ATProtoDID, URL) async throws -> String {
		{ (did, _) in
			try await self.handle(for: did).tryUnwrap
		}
	}

	public func messageDelegateFetcher() async
		-> @Sendable (ATProtoDID, URL) async throws -> GermLexicon.MessagingDelegateRecord
	{
		{ (did, _) in
			try await self.messagingDelegateRecord(for: did)
				.tryUnwrap
		}
	}

	public func followsFetcher(did: ATProtoDID, pdsUrl: URL) async -> AsyncThrowingStream<
		[String], any Error
	> {
		let (stream, continuation) = AsyncThrowingStream<[String], Error>
			.makeStream(bufferingPolicy: .unbounded)

		Task {
			do {
				continuation.yield(try .init(pds(for: did).follows.map(\.fullId)))
				continuation.finish()
			} catch {
				continuation.finish(throwing: error)
			}
		}

		return stream
	}

	public func anchorIntroductionFetcher() async
		-> @Sendable (ATProtoDID, URL, AnchorPublicKey) async throws -> AnchorHello.Verified
		.Archive?
	{
		{
			(did, _, anchorPubKey) in
			try await self.anchorIntroductionFetcher(
				did: did,
				anchorKey: anchorPubKey
			)
		}

	}

	public func update(
		delegateRecord: GermLexicon.MessagingDelegateRecord,
		for did: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) throws {
		try write(
			messagingDelegate: delegateRecord,
			did: did
		)
	}

	public func updateKeyPackage(
		for did: ATProtoDID,
		newHello: AnchorHello,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		try setPDSKeyPackageRecord(
			did: did,
			hello: newHello
		)
	}

	public func deleteKeyPackage(
		for did: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		try deleteKeyPackage(
			for: did,
			pdsUrl: pdsURL,
		)
	}

	public func createBlockRecord(
		for did: ATProtoDID,
		subjectDID: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		assert(resolvePDS[did] == pdsURL)
		try pds(for: did).blocks.insert(subjectDID)
	}

	public func deleteBlockRecord(
		for myDid: ATProtoDID,
		subjectDID: ATProtoDID,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		assert(resolvePDS[myDid] == pdsURL)
		try pds(for: myDid).blocks.remove(subjectDID)
	}
}

extension MockATProto {
	func write(
		messagingDelegate: GermLexicon.MessagingDelegateRecord,
		did: ATProtoDID
	) throws {
		try pds(for: did).germIdKeyPackage = messagingDelegate
	}

	private func pds(for did: ATProtoDID) throws -> MockPDS {
		try pdsTable[resolvePDS[did].tryUnwrap].tryUnwrap
	}

	func profileRecord(for did: ATProtoDID) async -> ATProtoDID
		.ProfileRecord?
	{
		await awaitHold()

		guard let pdsUrl = resolvePDS[did] else {
			Self.logger.error("missing pdsUrl")
			return nil
		}

		return pdsTable[pdsUrl]?.profileRecord
	}

	func handle(for did: ATProtoDID) -> String? {
		guard let pdsUrl = resolvePDS[did] else {
			Self.logger.error("missing pdsUrl")
			return nil
		}

		return pdsTable[pdsUrl]?.handle
	}

	func messagingDelegateRecord(
		for did: ATProtoDID
	) -> GermLexicon.MessagingDelegateRecord? {
		guard let pdsUrl = resolvePDS[did] else {
			Self.logger.error("missing pdsUrl")
			return nil
		}

		return pdsTable[pdsUrl]?.germIdKeyPackage
	}

	private func anchorIntroductionFetcher(
		did: ATProtoDID,
		anchorKey: AnchorPublicKey
	) throws -> AnchorHello.Verified.Archive? {
		let hello = try keyPackage(
			for: did,
		).tryUnwrap
		return
			(try anchorKey.verify(
				hello: hello,
				for: .init(anchorTo: did)
			).archive)
	}

	func keyPackage(for did: ATProtoDID) -> AnchorHello? {
		guard let pdsUrl = resolvePDS[did] else {
			Self.logger.error("missing pdsUrl")
			return nil
		}

		return pdsTable[pdsUrl]?.legacyKeyPackage
	}

	//legacy
	func setPDSKeyPackageRecord(
		did: ATProtoDID,
		hello: AnchorHello
	) throws {
		if let existing = try? pds(for: did).legacyKeyPackage,
			(try? existing.wireFormat) != (try? hello.wireFormat)
		{
			Self.logger.notice("overwriting anchor blob")
		}
		try pds(for: did).legacyKeyPackage = hello
	}

	func deleteKeyPackage(
		for did: ATProtoDID,
		pdsUrl: URL,
		//		authenticatorInput: Authenticator.Input,
	) throws {
		//TODO, mock authenticator behavior
		assert(resolvePDS[did] == pdsUrl)
		try pds(for: did).legacyKeyPackage = nil
	}

	public func fetchImage(
		did: ATProtoDID,
		cid: ATProtoDID.CID,
		pdsURL: URL
	) async throws -> Data {
		assert(resolvePDS[did] == pdsURL)
		return try pds(for: did).blobs[cid].tryUnwrap
	}

	public func updateBio(
		for did: ATProtoDID,
		newBio: String,
		pdsURL: URL,
		authenticator: Authenticator
	) async throws {
		try pds(for: did).profileRecord.profileText = newBio
	}
}
