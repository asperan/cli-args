module recursive_option_parser_test;

import std.stdio;
import asperan.cli_args.simple_option_parser;

alias fail = (string t) { assert(0, t); };

/// Build of a RecursiveOptionParser
unittest
{
    import asperan.cli_args.recursive_option_parser;
    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser = new RecursiveOptionParserBuilder().addOption("-h", "--help", "TestSubcommand help", () {}).build();    
    public:
        this()
        {
            super("test", "Test subcommand");
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments)
        {

        }
    }

    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    CommandLineOptionParser mainParser = builder
        .addOption("-h", "--help", "Help", () { })
        .addSubcommand(new TestSubcommand())
        .build();
    assert(mainParser);
}


/// Recognition of a subcommand
unittest
{
    import asperan.cli_args.recursive_option_parser;
    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser = new RecursiveOptionParserBuilder().build();    
    public:
        this()
        {
            super("test", "Test subcommand");
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments) { }
    }

    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    CommandLineOptionParser mainParser = builder
        .addSubcommand(new TestSubcommand())
        .build();
    
    auto result = mainParser.parse(["test"]);
    assert(!result[0].isNull, "Subcommand is not recognized");
}

/// A common option is parsed by the subcommand (and not by the parent command)
unittest
{
    import asperan.cli_args.recursive_option_parser;

    bool isSubcommandOption = false;

    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser;
    public:
        this()
        {
            super("test", "Test subcommand");
            this.optionParser = new RecursiveOptionParserBuilder().addOption("-o", "--option", "TestOption", () { isSubcommandOption = true; } ).build();
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments) { }
    }

    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    CommandLineOptionParser mainParser = builder
        .addSubcommand(new TestSubcommand())
        .addOption("-o", "--option", "TestOption", () { isSubcommandOption = false; } )
        .build();
    mainParser.parse(["test", "-o"]);
    assert(isSubcommandOption);
    mainParser.parse(["-o", "test"]);
    assert(!isSubcommandOption);
}

/// Only the first subcommand specified is parsed, the remaining arguments are considered options or subcommand arguments
unittest
{
    import asperan.cli_args.recursive_option_parser;
    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser = new RecursiveOptionParserBuilder().build();    
    public:
        this()
        {
            super("test", "Test subcommand");
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments) { }
    }
    class AnotherTestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser = new RecursiveOptionParserBuilder().build();    
    public:
        this()
        {
            super("another-test", "Another test subcommand");
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments) { }
    }
    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    AnotherTestSubcommand rightSubcommand = new AnotherTestSubcommand();

    CommandLineOptionParser mainParser = builder
        .addSubcommand(new TestSubcommand())
        .addSubcommand(rightSubcommand)
        .build();

    auto parseResult = mainParser.parse(["another-test", "test"]);
    assert(parseResult.subcommand == rightSubcommand && parseResult.remainingArguments == [ "test" ]);
}

/// Nested subcommands
unittest
{
    import asperan.cli_args.recursive_option_parser;
    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser = new RecursiveOptionParserBuilder().build();    
    public:
        this()
        {
            super("test", "Test subcommand");
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments) { }
    }

    class AnotherTestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser;
    public:
        this(TestSubcommand subcommand)
        {
            super("another-test", "Another test subcommand");
            optionParser = new RecursiveOptionParserBuilder().addSubcommand(subcommand).build();
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments) { }
    }

    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    TestSubcommand testSubcommand = new TestSubcommand();
    CommandLineOptionParser mainParser = builder
        .addSubcommand(new AnotherTestSubcommand(testSubcommand))
        .build();

    auto parseResult = mainParser.parse(["another-test", "test"]);
    assert(!parseResult.subcommand.isNull && parseResult.subcommand.get == testSubcommand);
}

/// Option which needs an argument: the argument is not considered a subcommand or a command argument
unittest
{
    string input = "";

    import asperan.cli_args.recursive_option_parser;
    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser;
    public:
        this()
        {
            super("test", "Test subcommand");
            optionParser = new RecursiveOptionParserBuilder().build();
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments)
        {

        }
    }

    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    CommandLineOptionParser mainParser = builder
        .addOption("-i", "--input", "Set the input", (string s) { input = s; })
        .addSubcommand(new TestSubcommand())
        .build();
    auto parseResult = mainParser.parse(["-i", "test"]);
    assert(input == "test" && parseResult.remainingArguments.length == 0 && parseResult.subcommand.isNull);
}

/// Option which needs an argument exception
unittest
{
    import std.exception : assertThrown;
    import asperan.cli_args.exception;

    string input = "";

    import asperan.cli_args.recursive_option_parser;
    class TestSubcommand : Subcommand
    {
    private:
        CommandLineOptionParser optionParser;
    public:
        this()
        {
            super("test", "Test subcommand");
            optionParser = new RecursiveOptionParserBuilder().build();
        }

        override CommandLineOptionParser getOptionParser()
        {
            return this.optionParser;
        }
        override void run(string[] arguments)
        {

        }
    }

    RecursiveOptionParserBuilder builder = new RecursiveOptionParserBuilder();

    CommandLineOptionParser mainParser = builder
        .addOption("-i", "--input", "Set the input", (string s) { input = s; })
        .addSubcommand(new TestSubcommand())
        .build();
    assertThrown!NoArgumentForLastOptionError(mainParser.parse(["-i"]));
}

