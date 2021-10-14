module simple_option_parser_test;

import std.stdio;
import option_parser;
import simple_option_parser;

unittest {
	CommandLineOptionParser op = SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.build();
	assert(op.getOptions.length == 2);
}

unittest {
  CommandLineOptionParser op = SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.build();
  string[] remainingArguments = op.parse(["-h", "-v", "hello"]);
	assert(remainingArguments.length == 1);
}

unittest {
  CommandLineOptionParser op = SimpleOptionParserBuilder()
											.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
											.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
											.addOption("-d", "--debug", "Print the next argument", (string arg) {writeln(arg);})
											.build();
  string[] remainingArguments = op.parse(["-h", "-v", "--debug", "hello"]);
	assert(remainingArguments.length == 0);
}