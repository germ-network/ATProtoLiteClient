//
//  TruncatedEncoding.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 1/25/24.
//

import Foundation

/// A protocol that defines a method for truncating an object.
public protocol TruncatableLite {

	/// Truncates the object to the specified length.
	///
	/// - Parameter length: The maximum number of items the object can have.
	/// - Returns: The truncated object.
	func truncatedLite(toLength length: Int) -> Self
}

extension KeyedEncodingContainer {

	/// Encodes a `TruncatableLite & Encodable` value to a container with truncation.
	///
	/// This is used as a replacement of `encode(_:forKey:)` if the object needs to be truncated
	/// before it's encoded.
	///
	/// - Parameters:
	///   - value: The value to encode.
	///   - key: The key to associate with the encoded value.
	///   - characterLength: The maximum length of characters a `String` value can have
	///   before encoding. Optional. Defaults to `nil`.
	///   - arrayLength: The maximum length of items an `Array` can have before encoding. Optional.
	///   Defaults to `nil`.
	/// - Throws: `EncodingError.invalidValue` if the given value is invalid in the current context
	/// for this format.
	public mutating func truncatedEncodeLite<Element: TruncatableLite & Encodable>(
		_ value: Element,
		forKey key: Key,
		upToCharacterLength characterLength: Int? = nil,
		upToArrayLength arrayLength: Int? = nil
	) throws {
		if let arrayValue = value as? [Element] {
			// Truncate the array if `upToArrayLength` is specified
			var truncatedArray = arrayValue

			if let arrayLength = arrayLength {
				truncatedArray = Array(truncatedArray.prefix(arrayLength))
			}
			// Truncate each element in the array if `upToCharacterLength` is specified
			let truncatedElements = truncatedArray.map { element -> Element in
				if let characterLength = characterLength {
					return element.truncatedLite(toLength: characterLength)
				}

				return element
			}

			try encode(truncatedElements, forKey: key)
		} else {
			// Truncate the value if `upToCharacterLength` is specified
			var truncatedValue = value

			if let characterLength = characterLength {
				truncatedValue = truncatedValue.truncatedLite(
					toLength: characterLength)
			}

			try encode(truncatedValue, forKey: key)
		}
	}

	/// Encodes an optional `TruncatableLite & Encodable` value to a container with truncation if the
	/// value is present.
	///
	/// This is used as a replacement of `encodeIfPresent(_:forKey:)`  if the object needs to be
	/// truncated before it's encoded.
	///
	/// - Parameters:
	///   - value: The optional value to encode if present.
	///   - key: The key to associate with the encoded value.
	///   - characterLength: The maximum length of characters a `String` value can have
	///   before encoding. Optional. Defaults to `nil`.
	///   - arrayLength: The maximum length of items an `Array` can have before encoding. Optional.
	///   Defaults to `nil`.
	/// - Throws: `EncodingError.invalidValue` if the given value is invalid in the current context
	/// for this format.
	public mutating func truncatedEncodeIfPresentLite<Element: TruncatableLite & Encodable>(
		_ value: Element?,
		forKey key: Key,
		upToCharacterLength characterLength: Int? = nil,
		upToArrayLength arrayLength: Int? = nil
	) throws {
		if let value = value {
			if let arrayValue = value as? [Element] {
				// Truncate the array if `upToArrayLength` is specified
				var truncatedArray = arrayValue

				if let arrayLength = arrayLength {
					truncatedArray = Array(truncatedArray.prefix(arrayLength))
				}
				// Truncate each element in the array if `upToCharacterLength` is specified
				let truncatedElements = truncatedArray.map { element -> Element in
					if let characterLength = characterLength {
						return element.truncatedLite(
							toLength: characterLength)
					}

					return element
				}

				try encode(truncatedElements, forKey: key)
			} else {
				// Truncate the value if `upToCharacterLength` is specified
				var truncatedValue = value

				if let characterLength = characterLength {
					truncatedValue = truncatedValue.truncatedLite(
						toLength: characterLength)
				}

				try encode(truncatedValue, forKey: key)
			}
		}
	}
}

// MARK: - String Extension
extension String: TruncatableLite {

	/// Truncates the `String` to a certain length.
	///
	/// In the AT Protocol, certain fields can only have a maximum of a certain number of
	/// "graphenes," which are a group of characters treated as one. In order to help prevent
	/// crashes, `ATProtoKit` will truncate a `String` to the maximum number of graphenes.
	/// However, we will still call them "characters" since this is the more understood term.
	/// - Parameter length: The maximum number of characters that the `String` can have
	/// before it truncates.
	/// - Returns: A new `String` that contains the maximum number of characters or less.
	public func truncatedLite(toLength length: Int) -> String {
		return String(self.prefix(length))
	}

	/// Transforms a string into one with a limited selection of characters.
	///
	/// Only the English alphabet in lowercase and the standard hyphen (-) are allowed to be used.
	/// Any uppercased characters will be lowercased. Any characters that could be interpreted as
	/// hypens will be converted into standard hyphens. Any additional characters will
	/// be discarded.
	public func transformToLowerASCIIAndHyphen() -> String {
		// Trim trailing spaces.
		let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)

		// Convert to lowercase.
		let lowercasedString = trimmedString.lowercased()

		// Define a set of Unicode scalars that represent various hyphen-like characters.
		let hyphenLikeScalars: [UnicodeScalar] = [
			"\u{2010}",  // Hyphen
			"\u{2011}",  // Non-breaking hyphen
			"\u{2012}",  // Figure dash
			"\u{2013}",  // En dash
			"\u{2014}",  // Em dash
			"\u{2015}",  // Horizontal bar
			"\u{2043}",  // Hyphen bullet
			"\u{2053}",  // Swung dash
			"\u{2212}",  // Minus sign
			"\u{2E3A}",  // Two-em dash
			"\u{2E3B}",  // Three-em dash
			"\u{FE58}",  // Small em dash
			"\u{FE63}",  // Small hyphen-minus
			"\u{FF0D}",  // Full-width hyphen-minus
		]
		let hyphenLikeCharacters = CharacterSet(hyphenLikeScalars)

		// Replace spaces and hyphen-like characters with standard hyphens.
		let withHyphens = lowercasedString.unicodeScalars.map { scalar in
			if CharacterSet.whitespaces.contains(scalar)
				|| hyphenLikeCharacters.contains(scalar)
			{
				return "-"
			} else {
				return String(scalar)
			}
		}
		.joined()

		// Define allowed characters: letters and hyphen.
		let allowedCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: "-"))

		// Filter the string to remove characters not in the allowed set.
		let filteredString = withHyphens.unicodeScalars.filter {
			allowedCharacters.contains($0)
		}.map(String.init).joined()

		return filteredString
	}

	/// Checks if the string matches the given regular expression pattern.
	///
	/// This method uses `NSRegularExpression` to determine if the entire string
	/// matches the specified regular expression pattern. It throws an error if
	/// the pattern is invalid.
	///
	/// - Parameter pattern: The regular expression pattern to match against.
	/// - Returns: A Boolean value indicating whether the string matches the pattern.
	/// - Throws: An error of type `NSError` if the regular expression pattern is invalid.
	///
	/// # Example Usage:
	/// ```
	/// let isValid = try "example123".matches(pattern: "^[a-zA-Z0-9]*$")
	/// print(isValid) // true if the string contains only alphanumeric characters
	/// ```
	//	func matches(pattern: String) throws -> Bool {
	//		let regex = try NSRegularExpression(pattern: pattern)
	//		let range = NSRange(location: 0, length: self.utf16.count)
	//
	//		return regex.firstMatch(in: self, options: [], range: range) != nil
	//	}
}

// MARK: - Array Extension
extension Array: TruncatableLite {

	/// /// Truncates the number of items in an `Array` to a certain length.
	///
	/// In the AT Protocol, certain fields can only have a maximum of items in their
	/// `Array`. In order to help prevent crashes,
	/// `ATProtoKit` will truncate an`Array` to the maximum number of items.
	/// - Parameter length: The maximum number of items that an `Array` can
	/// have before it truncates.
	/// - Returns: A new `Array` that contains the maximum number of items or less.
	public func truncatedLite(toLength length: Int) -> [Element] {
		return Array(self.prefix(length))
	}
}

// MARK: - Encodable Extension
extension Encodable {

	/// Converts an object into a JSON object.
	///
	/// - Returns: A JSON object.
	public func toJsonDataLite() throws -> Data? {
		return try JSONEncoder().encode(self)
	}
}
