module asperan.cli_args.exception;

/**
 * Error thrown when the last CLI option requires an additional value (but it is not provided as the option is the last argument).
 */
final class NoArgumentForLastOptionError : Error {
  this() {
    super("Last option needed an argument but no more arguments were given.");
  }
}

