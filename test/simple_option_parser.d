module simple_option_parser_test;

import std.stdio;
import asperan.cli_args.simple_option_parser;

unittest {
	CommandLineOptionParser op = new SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.build();
	assert(op.getOptions.length == 2);
}

unittest {
  CommandLineOptionParser op = new SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.build();
  string[] remainingArguments = op.parse(["-h", "-v", "hello"]);
	assert(remainingArguments.length == 1);
}

unittest {
  CommandLineOptionParser op = new SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.addOption("-d", "--debug", "Print the next argument", (string arg) {writeln(arg);})
											.build();
  string[] remainingArguments = op.parse(["-h", "-v", "--debug", "hello"]);
	assert(remainingArguments.length == 0);
}

unittest {
  import std.exception : assertThrown;
  CommandLineOptionParser op = new SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.addOption("-d", "--debug", "Print the next argument", (string arg) {writeln(arg);})
											.build();
  assertThrown!NoArgumentForLastOptionError(op.parse(["-d"]));
}
