module asperan.cli_args.option_parser_test;

import asperan.cli_args.option_parser;
import std.stdio;

unittest {
	CommandLineOption o = new CommandLineOption("-v", "--version", "Print the program version and exit", () {writeln("void\n");});
	assert(o.shortName == "-v");
  assert(o.longName == "--version");
  assert(!o.needsArgument());
}

unittest {
  bool verbose = false;
  assert(!verbose);
  CommandLineOption o = new CommandLineOption("-vv", "--verbose", "Verbose mode: print more debug infos", () { verbose = true; });
  o.runVoidSideEffect();
  assert(verbose);
}
