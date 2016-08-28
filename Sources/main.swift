/**
 * This file is part of the chicon project.
 *
 * @copyright © dana <https://github.com/okdana>
 * @license   MIT
 */

import Foundation

let app = ChIconApp(
	name:    NSURL(fileURLWithPath: Process.arguments[0]).lastPathComponent,
	version: "0.1.0"
)
exit(app.run(Array(Process.arguments[1..<Process.arguments.count])))

