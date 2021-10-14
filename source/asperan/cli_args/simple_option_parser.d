module asperan.cli_args.simple_option_parser;

public import asperan.cli_args.option_parser;
import asperan.option;

/**
 * A builder for an OptionParser which insert as command line argument all the unrecognized options;
 * the only error thrown is when the last string value is a recognized option which needs a secondary argument.
 *
 * Examples:
 * --------------------------
 * CommandLineOptionParser op = new SimpleOptionParserBuilder()
 *   .addOption("-v", "--version", "Print the program version and exit", () {writeln("version");})
 *   .addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
 *   .addOption("-d", "--debug", "Print the next argument", (string arg) {writeln(arg);})
 *   .build(); 
 * --------------------------
 */
class SimpleOptionParserBuilder {

  private SimpleOptionParser parser; 

  this() { this.parser = new SimpleOptionParser(); }

  /**
   * Returns the configured parser.
   */
  CommandLineOptionParser build() { return this.parser; }

  /**
   * Adds an option to the parser. The option has a side effect which does not require an argument.
   * This method returns the builder it is called on, so it can be chained with other calls.
   */
  SimpleOptionParserBuilder addOption(in string shortName, in string longName, in string description, in void delegate() voidSideEffect) {
    this.parser.registerOption(new CommandLineOption(shortName, longName, description, voidSideEffect));
    return this;
	}

  /**
   * Adds an option to the parser. The option has a side effect which requires an argument.
   * This method returns the builder it is called on, so it can be chained with other calls.
   */
	SimpleOptionParserBuilder addOption(in string shortName, in string longName, in string description, in void delegate(string) stringSideEffect) {
    this.parser.registerOption(new CommandLineOption(shortName, longName, description, stringSideEffect));
    return this;
	}
}

/**
 * Returns a formatted string with the short name, the long name and the description of the options of the given parser.
 */
string getSimpleHelpMessage(in CommandLineOptionParser parser) {
  import std.algorithm.iteration : map, reduce; import std.algorithm.searching : maxElement; import std.string : leftJustify;
  CommandLineOption[] options = parser.getOptions;
  size_t maxShortVersionLength = options.map!(o => o.shortName.length).maxElement;
  size_t maxLongVersionLength = options.map!(o => o.longName.length).maxElement;
  return options.map!(o => leftJustify(o.shortName, maxShortVersionLength) ~ " " ~ leftJustify(o.longName, maxLongVersionLength) ~ " " ~ o.description ~ "\n")
                .reduce!"a ~ b";
}

/**
 * Error thrown when the last CLI option requires an additional value (but it is not provided as the option is the last argument).
 */
final class NoArgumentForLastOptionError : Error {
  this() {
    super("Last option needed an argument but no more arguments were given.");
  }
}

private class SimpleOptionParser : CommandLineOptionParser {
  private CommandLineOption[] options;

  CommandLineOption[] getOptions() const { return cast(CommandLineOption[])options[]; }

  string[] parse(in string[] arguments) {
		string[] output;
		for(size_t index = 0; index < arguments.length; index++) {
      string arg = arguments[index];
      Option!CommandLineOption correspondingOption = findOption(arg);
      if (!correspondingOption.isEmpty) {
        if (correspondingOption.get.needsArgument) {
          if (index + 1 >= arguments.length) { throw new NoArgumentForLastOptionError(); }
					else {
						correspondingOption.get.runStringSideEffect(arguments[index + 1]);
						index += 1;
					}
        } else { correspondingOption.get.runVoidSideEffect(); }
      } else { output ~= arg; }
    }
    return output;
  }

  void registerOption(CommandLineOption opt) { options ~= opt; }

  private Option!CommandLineOption findOption(in string value) {
		foreach(size_t index, CommandLineOption o; this.options) {
      if (o.shortName == value || o.longName == value) {
        return Option!CommandLineOption.some(this.options[index]);
      }
    }
    return Option!CommandLineOption.none();
  }
}

