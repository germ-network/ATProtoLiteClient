//
//  LexiconBytes.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 2/9/26.
//

import Foundation

public struct LexiconBytes: Codable, Equatable, Hashable, Sendable {
	public let bytes: Data

	public init(bytes: Data) {
		self.bytes = bytes
	}

	enum CodingKeys: String, CodingKey {
		case bytes = "$bytes"
	}
}

//we made a mistake and left them as top level bytes
public struct ShimLexiconBytes: Codable, Equatable, Hashable, Sendable {
	public let bytes: Data

	public init(bytes: Data) {
		self.bytes = bytes
	}

	public init?(bytes: Data?) {
		guard let bytes else {
			return nil
		}
		self.bytes = bytes
	}

	public init(from decoder: any Decoder) throws {
		do {
			let container = try decoder.container(
				keyedBy: LexiconBytes.CodingKeys.self
			)
			self.bytes = try container.decode(Data.self, forKey: .bytes)
		} catch {
			let container = try decoder.singleValueContainer()
			self.bytes = try container.decode(Data.self)
		}
	}

	//don't yet write to new
	//	public func encode(to encoder: any Encoder) throws {
	//		var container = encoder.singleValueContainer()
	//		try container.encode(LexiconBytes(bytes: bytes))
	//	}
}
