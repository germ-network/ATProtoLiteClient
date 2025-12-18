//
//  LocaleFormatting.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/21/25.
//  From from EncodeLocale file by Christopher Jr Riley created 1/21/25.
//

import Foundation

extension KeyedDecodingContainer {

	/// Decodes a non-optional `Locale` object.
	///
	/// Given that `Locale` doesn't neatly decode from a JSON object, this is used as a replacement
	/// of `decode(_:forKey:)` specifically for `Locale` objects.
	///
	/// - Parameter key: The key associated with the `Locale` object.
	/// - Returns: A `Locale` object if decoding is successful.
	///
	/// - Throws: `DecodingError` if the key is missing.
	public func decodeLocaleLite(forKey key: Key) throws -> Locale {
		let localeString = try self.decode(String.self, forKey: key)

		return Locale(identifier: localeString)

	}

}
