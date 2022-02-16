module asperan.cli_args.simple_option_parser;

public import asperan.cli_args.option_parser;

/**
 *  A builder for an OptionParser which insert as command line argument all the unrecognized options;
 *  the only error thrown is when the last string value is a recognized option which needs a secondary argument.
 *
 *  Examples:
 *  --------------------------
 *  CommandLineOptionParser op = new SimpleOptionParserBuilder()
 *      .addOption("-v", "--version", "Print the program version and exit", () {writeln("version");})
 *      .addOption("-h", "--help", "Print the help message and exit", () {writeln("help");})
 *      .addOption("-d", "--debug", "Print the next argument", (string arg) {writeln(arg);})
 *      .build(); 
 *  --------------------------
 */
class SimpleOptionParserBuilder : OptionParserBuilder
{

    private SimpleOptionParser parser; 

    /**
     * Ctor.
     */
    this() { this.parser = new SimpleOptionParser(); }

    override protected CommandLineOptionParser getParser() { return this.parser; }
}

/**
 *  Returns a formatted string with the short name, the long name and the description of the options of the given parser.
 */
string getSimpleHelpMessage(in CommandLineOptionParser parser)
{
    import std.algorithm.iteration : map, reduce;
    import std.algorithm.searching : maxElement;
    import std.string : leftJustify;

    CommandLineOption[] options = parser.getOptions;
    size_t maxShortVersionLength = options.map!(o => o.shortName.length).maxElement;
    size_t maxLongVersionLength = options.map!(o => o.longName.length).maxElement;
    return options
            .map!(
                o => 
                    leftJustify(o.shortName, maxShortVersionLength) ~ 
                    " " ~
                    leftJustify(o.longName, maxLongVersionLength) ~
                    " " ~
                    o.description ~
                    "\n"
            )
            .reduce!"a ~ b";
}

private class SimpleOptionParser : CommandLineOptionParser
{
    import std.typecons : Nullable;

    override string[] parse(in string[] arguments)
    {
        import asperan.cli_args.exception : NoArgumentForLastOptionError;
		string[] output;
		for(size_t index = 0; index < arguments.length; index++)
        {
            string arg = arguments[index];
            Nullable!CommandLineOption correspondingOption = findOption(this.getOptions, arg);
            if (!correspondingOption.isNull)
            {
                if (correspondingOption.get.needsArgument)
                {
                    if (index + 1 >= arguments.length) { throw new NoArgumentForLastOptionError(); }
                    else
                    {
						correspondingOption.get.runStringSideEffect(arguments[index + 1]);
						index += 1;
					}
                } 
                else { correspondingOption.get.runVoidSideEffect(); }
            } 
            else { output ~= arg; }
        }
        return output;
    }
}

