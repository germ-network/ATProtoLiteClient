//
//  Utilities.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 4/24/25.
//

import Foundation

extension DataProtocol {
	public func copyBytes() -> [UInt8] {
		if let array = self.withContiguousStorageIfAvailable({ buffer in
			[UInt8](buffer)
		}) {
			return array
		} else {
			let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(
				capacity: self.count)
			self.copyBytes(to: buffer)
			defer { buffer.deallocate() }
			return [UInt8](buffer)
		}
	}
}

extension DataProtocol {
	package func base64URLEncodedBytes() -> [UInt8] {
		Data(copyBytes()).base64EncodedData().base64URLEscaped().copyBytes()
	}
}

// MARK: Data Escape

extension Data {
	/// Converts base64 encoded data to a base64-url encoded data.
	///
	/// https://tools.ietf.org/html/rfc4648#page-7
	fileprivate mutating func base64URLEscape() {
		for idx in self.indices {
			switch self[idx] {
			case 0x2B:  // +
				self[idx] = 0x2D  // -
			case 0x2F:  // /
				self[idx] = 0x5F  // _
			default: break
			}
		}
		self = split(separator: 0x3D).first ?? .init()
	}

	/// Converts base64 encoded data to a base64-url encoded data.
	///
	/// https://tools.ietf.org/html/rfc4648#page-7
	fileprivate func base64URLEscaped() -> Data {
		var data = self
		data.base64URLEscape()
		return data
	}
}
