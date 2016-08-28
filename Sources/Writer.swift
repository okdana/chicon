/**
 * This file is part of the chicon project.
 *
 * @copyright © dana <https://github.com/okdana>
 * @license   MIT
 */

import Foundation

/**
 * Provides several print()-style methods for writing to an arbitrary stream.
 */
public struct Writer {
	public let stdout: NSFileHandle
	public let stderr: NSFileHandle

	/**
	 * Initialiser.
	 */
	public init() {
		self.stdout = NSFileHandle.fileHandleWithStandardOutput()
		self.stderr = NSFileHandle.fileHandleWithStandardError()
	}

	/**
	 * Writes to a stream.
	 *
	 * @see self._write()
	 *
	 * @param Any...        items      See _write().
	 * @param String?       separator  See _write().
	 * @param String?       terminator See _write().
	 * @param NSFileHandle? to         See _write().
	 *
	 * @return Int The number of bytes written.
	 */
	public func write(
		items:      Any...,
		separator:  String?       = nil,
		terminator: String?       = nil,
		to:         NSFileHandle? = nil
	) -> Int {
		return self._write(
			items,
			separator:  separator,
			terminator: terminator,
			to:         to
		)
	}

	/**
	 * Writes to STDOUT.
	 *
	 * @see self._write()
	 *
	 * @param Any...        items      See write().
	 * @param String?       separator  See write().
	 * @param String?       terminator See write().
	 * @param NSFileHandle? to         See write(). Defaults to self.stdout.
	 *
	 * @return Int The number of bytes written.
	 */
	public func writeOut(
		items:      Any...,
		separator:  String?       = nil,
		terminator: String?       = nil,
		to:         NSFileHandle? = nil
	) -> Int {
		return self._write(
			items,
			separator:  separator,
			terminator: terminator,
			to:         to == nil ? self.stdout : to!
		)
	}

	/**
	 * Writes to STDERR.
	 *
	 * @see self.write()
	 *
	 * @param Any...        items      See write().
	 * @param String?       separator  See write().
	 * @param String?       terminator See write().
	 * @param NSFileHandle? to         See write(). Defaults to self.stderr.
	 *
	 * @return Int The number of bytes written.
	 */
	public func writeErr(
		items:      Any...,
		separator:  String?       = nil,
		terminator: String?       = nil,
		to:         NSFileHandle? = nil
	) -> Int {
		return self._write(
			items,
			separator:  separator,
			terminator: terminator,
			to:         to == nil ? self.stderr : to!
		)
	}

	/**
	 * Writes to a stream.
	 *
	 * @param [Any] items
	 *   An array of zero or more arbitrary items to write to the stream.
	 *   Multiple items will be concatenated by the separator value.
	 *
	 * @param String? separator
	 *   (optional) The separator string to use when concatenating multiple
	 *   output items. The default is " " (a space).
	 *
	 * @param String? terminator
	 *   (optional) The terminator string to write after all output items have
	 *   been written. The default is "\n" (a new-line).
	 *
	 * @param NSFileHandle? to
	 *   (optional) A stream / file handle to write to. The default is
	 *   self.stdout.
	 *
	 * @return Int The number of bytes written.
	 */
	private func _write(
		items:      [Any],
		separator:  String?       = nil,
		terminator: String?       = nil,
		to:         NSFileHandle? = nil
	) -> Int {
		let handle: NSFileHandle = to == nil ? self.stdout : to!
		var prefix: String       = ""
		var result: String       = ""

		for item in items {
			result += prefix
			result += String(item)
			prefix  = separator == nil ? " " : separator!
		}
		result += terminator == nil ? "\n" : terminator!

		handle.writeData(result.dataUsingEncoding(NSUTF8StringEncoding)!)
		return result.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
	}
}

