//
//  ATProtoDIDTypes.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 8/29/25.
//

import CommProtocol
import Foundation

extension ATProtoDID {
	public typealias CID = String
	public typealias FullDID = String

	public struct ProfileRecord: Equatable, Codable, Sendable {
		public var displayName: String?
		public var profileText: String?
		public var avatarCid: CID?
		public var bannerCid: CID?

		public init(
			displayName: String? = nil,
			profileText: String? = nil,
			avatarCid: String? = nil,
			bannerCid: String? = nil
		) {
			self.displayName = displayName
			self.profileText = profileText
			self.avatarCid = avatarCid
			self.bannerCid = bannerCid
		}
	}

	public struct SocialGraph: Equatable, Codable, Sendable {
		public var didList: [FullDID]
		public var complete: Bool

		public init(didList: [FullDID], complete: Bool) {
			self.didList = didList
			self.complete = complete
		}
	}
}
