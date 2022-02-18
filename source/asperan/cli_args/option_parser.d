module asperan.cli_args.option_parser;

public import std.typecons : Nullable, Tuple;

/**
 *  Option object.
 *
 *  It has a short name (for example "-h"), a long name (for example "--help") and a description.
 *
 *  Usually on UNIX systems the short version of an option starts with "-" (one hyphen) and the long version starts with "--" (two hyphens).
 *
 *  Also, short names and long names should be unique among all options (i.e. there cannot be two options with the same short name or the same long name).
 *
 *  This type of options has a side effect which does not need an argument (flag option, like --verbose) or 
 *  a side effect which accepts a string value as argument (the passed value can then be parsed to the desired type, for example "int"), 
 *  which usually is the next CLI argument to be parsed.
 */
class CommandLineOption
{
    /// The short name of the option.
    const string shortName;
    /// The long name of the option.
    const string longName;
    /// The description of the option.
    const string description;

    private void delegate() voidSideEffect;
    private void delegate(string) stringSideEffect;

    /// This constructor initialize the basic components of the option.
    protected this(in string _shortName, in string _longName, in string _description)
    {
        this.shortName = _shortName;
        this.longName = _longName;
        this.description = _description;
    }

    /// This constructor creates a new flag option, whose side effect function does not request an argument.
    this(in string _shortName, in string _longName, in string _description, in void delegate() _voidSideEffect)
    {
        this(_shortName, _longName, _description);
        this.voidSideEffect = _voidSideEffect;
        this.stringSideEffect = null;
    }

    /// This constructor creates new option, whose side effect function requires an argument.
    this(in string _shortName, in string _longName, in string _description, in void delegate(string) _stringSideEffect)
    {
        this(_shortName, _longName, _description);
        this.stringSideEffect = _stringSideEffect;
        this.voidSideEffect = null;
    }

    /// Returns whether the option needs an additional argument
    bool needsArgument() { return stringSideEffect.funcptr != null; }

    /// Executes the side effect with no arguments without checks on the actual presence of the function.
    void runVoidSideEffect() { this.voidSideEffect(); }

    /// Executes the side effect with a string arguments without checks on the actual presence of the function.
    void runStringSideEffect(in string value) { this.stringSideEffect(value); }
}

/**
 *  A subcommand further specifies what functionality is requested by the user.
 *
 *  Subcommands can have subsubcommands (and so on), but only one subcommand can be specified for each level of depth.
 *
 *  An example can be 'dub run' or 'dub test' where both 'run' and 'test' are subcommands.
 */
abstract class Subcommand
{
private:
    string name;
    string description;

public:
    this(in string name, in string description)
    {
        this.name = name;
        this.description = description;
    }

    string getName()
    {
        return this.name;
    }

    string getDescription()
    {
        return this.description;
    }

    /**
     *  Returns: the option parser of the subcommand.
     */
    CommandLineOptionParser getOptionParser();

    /**
     *  Runs the subcommand with the given arguments.
     *
     *  Params:
     *      arguments = the arguments to pass to the subcommand.
     */
    void run(string[] arguments);
}

/// Alias for the parsing result.
alias ParseResult = Tuple!(Nullable!Subcommand, "subcommand", string[], "remainingArguments");

/**
 *  An option parser is the object which parses an array of strings into options and command arguments.
 *  It should accept and register options.
 */
abstract class CommandLineOptionParser
{
private:
    CommandLineOption[] options;

package:

    final void registerOption(CommandLineOption opt)
    {
        this.options ~= opt;
    }

public:
    /**
     *  Parses the argument array as Options and divide them from the command line arguments.
     *  It should also run the defined side effects.
     *  Params:
     *      arguments = the array of the command line arguments.
     *  Returns: the non-Option arguments.
     */
    ParseResult parse(string[] arguments);

    /**
     *  Returns: the registered option list.
     */
    final CommandLineOption[] getOptions() const
    {
        return cast(CommandLineOption[]) this.options;
    }
}

package abstract class OptionParserBuilder
{
protected:

    CommandLineOptionParser getParser();

public:

    /**
     *  Returns the configured parser.
     */
    CommandLineOptionParser build() { return this.getParser; }

}

package Nullable!CommandLineOption findOption(CommandLineOption[] options, in string value)
{
    import std.algorithm.comparison : among;
    foreach(CommandLineOption o; options)
    {
        if (value.among(o.shortName, o.longName))
        {
            return Nullable!CommandLineOption(o);
        }
    }
    return Nullable!CommandLineOption();
}

package Nullable!Subcommand findSubcommand(Subcommand[] subcommands, in string value)
{
    foreach(Subcommand s; subcommands)
    {
        if (s.getName == value)
        {
            return Nullable!Subcommand(s);
        }
    }
    return Nullable!Subcommand();
}
