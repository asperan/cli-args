module option_parser;

/**
 * Option object. It has a short name (for example "-h"), a long name (for example "--help") and a description.
 * Usually on UNIX systems the short version of an option starts with "-" (one hyphen) and the long version starts with "--" (two hyphens).
 * Also, short names and long names should be unique among all options (i.e. there cannot be two options with the same short name or the same long name).
 * This type of options has a side effect which does not need an argument (flag option, like --verbose) or 
 * a side effect which accepts a string value as argument (the passed value can then be parsed to the desired type, for example "int").
 */
class CommandLineOption {
  /// The short name of the option.
  const string shortName;
  /// The long name of the option.
	const string longName;
  /// The description of the option.
	const string description;

	private void delegate() voidSideEffect;
  private void delegate(string) stringSideEffect;

  /// This constructor initialize the basic components of the option.
  protected this(in string _shortName, in string _longName, in string _description) {
		this.shortName = _shortName;
		this.longName = _longName;
		this.description = _description;
  }

  /// This constructor creates a new flag option, whose side effect function does not request an argument.
  this(in string _shortName, in string _longName, in string _description, in void delegate() _voidSideEffect) {
		this(_shortName, _longName, _description);
    this.voidSideEffect = _voidSideEffect;
	}

  /// This constructor creates new option, whose side effect function requires an argument.
  this(in string _shortName, in string _longName, in string _description, in void delegate(string) _stringSideEffect) {
		this(_shortName, _longName, _description);
    this.stringSideEffect = _stringSideEffect;
	}

  /// Returns whether the option needs an additional argument
  bool needsArgument() { return stringSideEffect.funcptr != null; }

  /// Executes the side effect with no arguments without checks.
  void runVoidSideEffect() { this.voidSideEffect(); }

  /// Executes the side effect with a string arguments without checks.
  void runStringSideEffect(in string value) { this.stringSideEffect(value); }
}

/**
 * An option parser is the object which parses an array of strings into options and command arguments.
 * It should accept and register options.
 */
interface CommandLineOptionParser {
  /**
   * Parses the argument array as Options and divide them from the command line arguments.
   * It should also run the defined side effects.
   * Params:
   *  arguments = the array of the command line arguments.
   * Returns: the non-Option arguments.
   */
  string[] parse(in string[] arguments);

	/**
   * Returns: the registered option list.
   */
  CommandLineOption[] getOptions() const;
}

