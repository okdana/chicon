/**
 * This file is part of the chicon project.
 *
 * @copyright © dana <https://github.com/okdana>
 * @license   MIT
 */

import Foundation

let app = ChIconApp(
  name:    NSURL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent,
  version: "0.3.0"
)
exit(app.run(
  arguments: Array(CommandLine.arguments[1..<CommandLine.arguments.count])
))
