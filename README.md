# Cli-args

Cli-args is a library for D for parsing command line arguments and options.

It provides the bases to create your own custom parser and also a basic implementation (in the module `asperan.cli_args.simple_option_parser`).

The base class provides support for 2 kind of argument:
- "flag" arguments, which do not need additional arguments as they work like switches (for example, the usual options `--help` or `--version`);
- other options, which needs an additional arguments (i.e. for `dub --build docs`: option `--build`, additional argument `docs`).

The provided parser just passes along the unrecognized arguments, so no option is lost.

### Examples
```
CommandLineOptionParser op = SimpleOptionParserBuilder()
	.addOption("-v", "--version", "Print the program version and exit", () {writeln("void");})
	.addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
	.addOption("-d", "--debug", "Print the next argument", (string arg) {writeln(arg);})
	.build();
```
