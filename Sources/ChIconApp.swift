/**
 * This file is part of the chicon project.
 *
 * @copyright © dana <https://github.com/okdana>
 * @license   MIT
 */

import Foundation
import AppKit

/**
 * Represents the command-line `chicon` application.
 */
public class ChIconApp {
	private var writer:  Writer
	private var name:    String
	private var version: String

	/**
	 * Initialiser.
	 *
	 * @param String? name    (optional) The application name.
	 * @param String? version (optional) The application version.
	 * @param Writer? writer  (optional) The Writer to use for output.
	 */
	public init(
		name:    String? = nil,
		version: String? = nil,
		writer:  Writer? = nil
	) {
		self.name    = name   == nil ? "chicon" : name!
		self.version = name   == nil ? "0.0.0"  : version!
		self.writer  = writer == nil ? Writer() : writer!
	}

	/**
	 * Runs the application.
	 *
	 * @param [String] arguments
	 *   (optional) An array of zero or more command-line arguments to the
	 *   application.
	 *
	 * @return Int32 A return status suitable for passing to exit().
	 */
	public func run(arguments: [String] = []) -> Int32 {
		var args:      [String] = self.normaliseArguments(arguments)
		var verbosity: Int      = 0
		var mode:      String   = "add"

		argLoop: for (index, arg) in args.enumerate() {
			switch arg {
				case "-h", "--help":
					return self.doHelp()
				case "-V", "--version":
					return self.doVersion()
				case "-q", "--quiet":
					verbosity = -1
				case "-v", "--verbose":
					verbosity = 1
				case "-c", "--copy":
					mode = "copy"
				case "-r", "--remove":
					mode = "remove"
				case "-t", "--type":
					mode = "type"
				case "--":
					args = Array(args[index + 1 ..< args.count])
					break argLoop
				default:
					self.writer.writeErr("\(name): Unrecognised option: \(arg)")
					self.doHelp(true, to: self.writer.stderr)
					return 1
			}
		}

		if (args.count < 1 || (mode == "type" && args.count < 2)) {
			if verbosity >= 0 {
				self.writer.writeErr("\(name): File path required")
				self.doHelp(true, to: self.writer.stderr)
			}
			return 1
		}

		switch mode {
			case "add", "copy", "type":
				return self.doSetIcon(
					args[0],
					args.count == 1 ? [args[0]] : Array(args[1..<args.count]),
					mode:      mode,
					verbosity: verbosity
				)
			case "remove":
				return self.doRemoveIcon(
					args,
					verbosity: verbosity
				)
			default:
				self.writer.writeErr("\(name): This should never happen!")
				return 1
		}
	}

	/**
	 * Sets a thumb-nail icon on one or more files.
	 *
	 * @param String   iconPath  The icon source path or file type.
	 * @param [String] destPaths One or more file paths.
	 * @param String   mode      (optional) Action type. The default is "add".
	 * @param Int      verbosity (optional) Verbosity level. The default is 0.
	 *
	 * @return Int32 A return status suitable for passing to exit().
	 */
	private func doSetIcon(
		iconPath:    String,
		_ destPaths: [String],
		mode:        String = "add",
		verbosity:   Int    = 0
	) -> Int32 {
		let workspace: NSWorkspace = NSWorkspace.sharedWorkspace()
		var icon:      NSImage?
		var success:   Bool
		var ret:       Int32 = 0

		if (mode != "type" && !NSFileManager.defaultManager().fileExistsAtPath(iconPath)) {
			if verbosity >= 0 {
				self.writer.writeErr("\(name): No such file or directory: \(iconPath)")
			}
			return 1
		}

		if mode == "add" {
			icon = NSImage(contentsOfFile: iconPath)
		} else if mode == "copy" {
			icon = workspace.iconForFile(iconPath)
		} else if mode == "type" {
			icon = workspace.iconForFileType(iconPath)
		}

		if icon == nil {
			if (mode == "type" && verbosity >= 0) {
				self.writer.writeErr("\(name): Failed to load icon for file type: \(iconPath)")
			} else if verbosity >= 0 {
				self.writer.writeErr("\(name): Failed to load icon from file: \(iconPath)")
			}
			return 1
		}

		for path in destPaths {
			if !NSFileManager.defaultManager().fileExistsAtPath(path) {
				if verbosity >= 0 {
					self.writer.writeErr("\(name): No such file or directory: \(path)")
				}
				ret = 1
				continue
			}

			workspace.setIcon(
				nil,
				forFile: path,
				options: NSWorkspaceIconCreationOptions(rawValue: 0)
			)
			success = workspace.setIcon(
				icon,
				forFile: path,
				options: NSWorkspaceIconCreationOptions(rawValue: 0)
			)

			if !success {
				if verbosity >= 0 {
					self.writer.writeErr("\(name): Failed to set icon on file: \(path)")
				}
				ret = 1
				continue
			}

			if verbosity >= 1 {
				self.writer.write("\(iconPath) -> \(path)")
			}
		}

		return ret
	}

	/**
	 * Removes a thumb-nail icon from one or more files.
	 *
	 * @param [String] destPaths One or more file paths.
	 * @param Int      verbosity (optional) Verbosity level. The default is 0.
	 *
	 * @return Int32 A return status suitable for passing to exit().
	 */
	private func doRemoveIcon(
		destPaths: [String],
		verbosity: Int = 0
	) -> Int32 {
		let workspace: NSWorkspace = NSWorkspace.sharedWorkspace()
		var success: Bool
		var ret:     Int32 = 0

		for path in destPaths {
			if !NSFileManager.defaultManager().fileExistsAtPath(path) {
				if verbosity >= 0 {
					self.writer.writeErr("\(name): No such file or directory: \(path)")
				}
				ret = 1
				continue
			}

			success = workspace.setIcon(
				nil,
				forFile: path,
				options: NSWorkspaceIconCreationOptions(rawValue: 0)
			)

			if !success {
				if verbosity >= 0 {
					self.writer.writeErr("\(name): Failed to remove icon from file: \(path)")
				}
				ret = 1
				continue
			}

			if verbosity >= 1 {
				self.writer.write(path)
			}
		}

		return ret
	}

	/**
	 * Prints usage help.
	 *
	 * @param Bool brief
	 *   (optional) Whether to print only the brief usage help. The default is
	 *   false (print full help).
	 *
	 * @param NSFileHandle? to
	 *   (optional) A stream to write to.
	 *
	 * @return Int32 Always 0.
	 */
	private func doHelp(brief: Bool = false, to: NSFileHandle? = nil) -> Int32 {
		let synopsis = "\(self.name) [-h|-V] [-q|-v] [-c|-r|-t] [--] <iconfile> [<destfile> ...]"

		if brief {
			self.writer.write("usage: \(synopsis)", to: to)
			return 0
		}

		self.writer.write("Usage:", to: to)
		self.writer.write("  \(synopsis)", to: to)

		self.writer.write("Operands:", to: to)
		self.writer.write("  iconfile       Path to icon file, or file type", to: to)
		self.writer.write("  destfile       Path to destination file(s)", to: to)

		self.writer.write("Options:", to: to)
		self.writer.write("  -h, --help     Display this usage help", to: to)
		self.writer.write("  -V, --version  Display version information", to: to)
		self.writer.write("  -q, --quiet    Reduce output verbosity", to: to)
		self.writer.write("  -v, --verbose  Increase output verbosity", to: to)
		self.writer.write("  -c, --copy     Copy icon set on iconfile instead of using its contents", to: to)
		self.writer.write("  -r, --remove   Remove icons from specified files", to: to)
		self.writer.write("  -t, --type     Treat iconfile as a file type whose icon should be used", to: to)

		return 0
	}

	/**
	 * Prints application version information.
	 *
	 * @param NSFileHandle? to (optional) A stream to write to.
	 *
	 * @return Int32 Always 0.
	 */
	private func doVersion(to: NSFileHandle? = nil) -> Int32 {
		self.writer.write("\(self.name) version \(self.version)", to: to)
		return 0
	}

	/**
	 * Parses command-line arguments and returns an array with the arguments
	 * normalised and sorted as follows:
	 *
	 * in:  ["-ab", "--option1", "operand1", "--option2", "operand2"]
	 * out: ["-a", "-b", "--option1", "--option2", "--", "operand1", "operand2"]
	 *
	 * Errata: This method does not support options that take arguments, nor
	 * does it perform validation on option names (so if you pass in an argument
	 * list like ["-!@#"], you will get back ["-!", "-@", "-#"]. Also, to avoid
	 * erroneous insertion of "--" into the result, hyphens encountered within a
	 * cluster of short options (e.g. "-ab-cd") will be dropped.
	 *
	 * @param [String] Zero or more command-line arguments to parse.
	 *
	 * @return [String] Zero or more normalised/sorted arguments.
	 */
	private func normaliseArguments(arguments: [String]) -> [String] {
		var options:      [String] = []
		var operands:     [String] = []
		var afterOptions: Bool     = false

		for arg in arguments {
			switch true {
				// End-of-options marker
				case arg == "--":
					if !afterOptions {
						afterOptions = true
						continue
					}
					fallthrough
				// Argument beginning with hyphen
				case arg[arg.startIndex] == "-":
					// After options — add to operands
					if afterOptions {
						operands += [arg]
						continue
					// Long argument — add to options
					} else if arg[arg.startIndex.advancedBy(1)] == "-" {
						options += [arg]
						continue
					}
					// Short argument — add each character to options
					for char in arg.substringFromIndex(arg.startIndex.advancedBy(1)).characters {
						// Avoid inserting a false '--'
						if char == "-" {
							continue
						}
						options += ["-\(char)"]
					}
				// Operand
				default:
					operands += [arg]
			}
		}

		return options + ["--"] + operands
	}
}

