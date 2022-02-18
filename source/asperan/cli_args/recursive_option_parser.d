module asperan.cli_args.recursive_option_parser;

import asperan.cli_args.option_parser;

/**
 * A builder for option parsers which support nested subcommands.
 */
class RecursiveOptionParserBuilder : OptionParserBuilder
{
private:

    RecursiveOptionParser parser;

public:

    this()
    {
        this.parser = new RecursiveOptionParser();
    }

    override protected CommandLineOptionParser getParser() { return this.parser; }

    RecursiveOptionParserBuilder addSubcommand(Subcommand subcommand)
    {
        this.parser.registerSubcommand(subcommand);
        return this;
    }

    /**
     *  Adds an option to the parser. The option has a side effect which does not require an argument.
     *  This method returns the builder it is called on, so it can be chained with other calls.
     */
    RecursiveOptionParserBuilder addOption(
        in string shortName,
        in string longName,
        in string description,
        in void delegate() voidSideEffect
    )
    {
        this.getParser.registerOption(new CommandLineOption(shortName, longName, description, voidSideEffect));
        return this;
    }

    /**
     *  Adds an option to the parser. The option has a side effect which requires an argument.
     *  This method returns the builder it is called on, so it can be chained with other calls.
     */
    RecursiveOptionParserBuilder addOption(
        in string shortName,
        in string longName,
        in string description,
        in void delegate(string) stringSideEffect
    )
    {
        this.getParser.registerOption(new CommandLineOption(shortName, longName, description, stringSideEffect));
        return this;
    }
}

private class RecursiveOptionParser : CommandLineOptionParser
{
private:
    Subcommand[] subcommands;

    void registerSubcommand(Subcommand cmd) { subcommands ~= cmd; }

    /// Returns: true if an option has been found (the input array is modified),
    ///     else false (the input array is not modified).
    bool handleOption(ref string[] argumentList)
    {
        import asperan.cli_args.exception : NoArgumentForLastOptionError;
        Nullable!CommandLineOption correspondingOption = findOption(this.getOptions, argumentList[0]);
        if (!correspondingOption.isNull)
        {
            if (correspondingOption.get.needsArgument)
            {
                if (argumentList.length < 2)
                {
                    throw new NoArgumentForLastOptionError();
                }
                else
                {
					correspondingOption.get.runStringSideEffect(argumentList[1]);
				}
            } 
            else
            {
                correspondingOption.get.runVoidSideEffect();
            }
            argumentList = argumentList[(1 + 1 * correspondingOption.get.needsArgument)..$];
            return true;
        } 
        else 
        {
            return false;
        }
    }

public:

    override ParseResult parse(string[] arguments)
    {
        import std.typecons : tuple;
		string[] output;
        Nullable!Subcommand selectedSubcommand = Nullable!Subcommand();
        while (arguments.length > 0)
        {
            if (selectedSubcommand.isNull)
            {
                selectedSubcommand = findSubcommand(this.getSubcommands, arguments[0]);
                if (!selectedSubcommand.isNull)
                {
                    // Start parsing of subcommand options
                    auto parseResult = selectedSubcommand.get.getOptionParser.parse(arguments[1..$]);
                    if(!parseResult.subcommand.isNull) // The subcommand has a nested subcommand
                    {
                        /* The main command does not care how many levels are there of subcommand nesting,
                           it should only need the last specified subcommand, which is the one to run. */
                        selectedSubcommand = parseResult.subcommand;
                    }
                    // remove parsed options from the argument list
                    arguments = parseResult.remainingArguments;
                    // The argument list is changed, the cycle needs to restart.
                    continue;
                }
            }

            if (!handleOption(arguments)) // The option is not recognized
            {
                output ~= arguments[0];
                arguments = arguments[1..$];
            }
        }

        return tuple!("subcommand", "remainingArguments")(selectedSubcommand, output);
    }

}

/**
 *  Returns a formatted string with the short name, the long name and the description of the options of the given parser.
 */
private string getSimpleHelpMessage(in CommandLineOptionParser parser)
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
