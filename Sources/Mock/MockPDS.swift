//
//  MockPDS.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/23/25.
//

import CommProtocol
import Foundation

class MockPDS {
	var handle: String
	var profileRecord: ATProtoDID.ProfileRecord
	var germIdKeyPackage: GermLexicon.MessagingDelegateRecord?
	var legacyKeyPackage: AnchorHello?
	var blobs: [ATProtoDID.CID: Data]
	var follows: Set<ATProtoDID> = []
	var blocks: Set<ATProtoDID> = []

	init(
		handle: String,
		profileRecord: ATProtoDID.ProfileRecord = .init(),
		keyPackage: AnchorHello? = nil,
		blobs: [ATProtoDID.CID: Data] = [:]
	) {
		self.handle = handle
		self.profileRecord = profileRecord
		self.legacyKeyPackage = keyPackage
		self.blobs = blobs
	}
}
