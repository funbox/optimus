# Optimus

[![Build Status](https://travis-ci.org/funbox/optimus.svg?branch=master)](https://travis-ci.org/funbox/optimus)
[![Coverage Status](https://coveralls.io/repos/github/funbox/optimus/badge.svg?branch=master)](https://coveralls.io/github/funbox/optimus?branch=master)

A command line arguments parsing library for [Elixir](http://elixir-lang.org).

It's aim is to take off the maximum possible amount of manual argument handling.
The intended use case is to configure Optimus parser, run it against the
command line and then do nothing but take completely validated
ready to use values.

The library was strongly inspired by the awesome [clap.rs](https://clap.rs/)
library. Optimus does not generally follow its design, but it tries to
follow the idea of zero manual manipulation with the values after the parser has
returned them.

## Installation

Add `optimus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:optimus, "~> 0.1.0"}]
end
```

## Example

Let's configure a CLI interface to an imaginary utility which reads data from
a file of the following format:

```
# timestamp, value
1481729245, 12.0
1481729245, 13.0
1481729246, 11.1
...
```

and outputs some statistic metrics of the values.
It also has a subcommand which validates the source file integrity.

```elixir
defmodule Statcalc do
  def main(argv) do
    Optimus.new!(
      name: "statcalc",
      description: "Statistic metrics calculator",
      version: "1.2.3",
      author: "John Smith js@corp.com",
      about: "Utility for calculating statistic metrics of values read from a file for a certain period of time",
      allow_unknown_args: false,
      parse_double_dash: true,
      args: [
        infile: [
          value_name: "INPUT_FILE",
          help: "File with raw data",
          required: true,
          parser: :string
        ],
        outfile: [
          value_name: "OUTPUT_FILE",
          help: "File to write statistics to",
          required: false,
          parser: :string
        ]
      ],
      flags: [
        print_header: [
          short: "-h",
          long: "--print-header",
          help: "Specifies wheather to print header before the outputs",
          multiple: false,
        ],
        verbosity: [
          short: "-v",
          help: "Verbosity level",
          multiple: true,
        ],
      ],
      options: [
        date_from: [
          value_name: "DATE_FROM",
          short: "-f",
          long: "--from",
          help: "Start date for the period",
          parser: fn(s) ->
            case Date.from_iso8601(s) do
              {:error, _} -> {:error, "invalid date"}
              {:ok, _} = ok -> ok
            end
          end,
          required: true
        ],
        date_to: [
          value_name: "DATE_TO",
          short: "-t",
          long: "--to",
          help: "End date for the period",
          parser: fn(s) ->
            case Date.from_iso8601(s) do
              {:error, _} -> {:error, "invalid date"}
              {:ok, _} = ok -> ok
            end
          end,
          required: false,
          default: &Date.utc_today/0
        ],
      ],
      subcommands: [
        validate: [
          name: "validate",
          about: "Validates the raw contents of a file",
          args: [
            file: [
              value_name: "FILE",
              help: "File with raw data to validate",
              required: true,
              parser: :string
            ]
          ]
        ]
      ]
    ) |> Optimus.parse!(argv) |> IO.inspect
  end
end
```

(The whole sample code can be found in
[optimus_example](https://github.com/savonarola/optimus_example) repo.)

Nearly all of the configuration options above are not mandatory.

Also most configuration parameters are self-explanatory, except `parser`. 
For options and positional arguments `parser` is a lambda which accepts a string argument and returns either 
`{:ok, parsed_value}` or `{:error, string_reason}`. There are also some predefined parsers which are denoted by atoms: 
`:string`, `:integer` and `:float`. No parser means that `:string` parser will be used.

Not required `options` can have a `default` value. Both a term (string, number, etc.) or a lambda with zero arity can be used. 
If the `option` accepts `multiple` values, the `default` value should be a list, for example `[1.0]` or `fn -> ["x", "y"] end`.

Now if we try to launch our compiled escript without any args we'll see the following:

```
>./statcalc
The following errors occured:
- missing required arguments: INPUT_FILE
- missing required options: --from(-f), --to(-t)

Try
    statcalc --help

to see available options
```

There are several things to note:
* the script exited (in `Optimus.parse!`) since we haven't received a valid set
of arguments;
* a list of errors is displayed (and it's as full as possible);
* a user is offered to launch `statcalc` with `--help` flag which is automatically
handled by Optimus.

If we launch `statcalc --help`, we'll see the following:

```
>./statcalc --help
Statistic metrics calculator 1.2.3
John Smith js@corp.com
Utility for calculating statistic metrics of values read from a file for a certain period of time

USAGE:
    statcalc [--print-header] --from DATE_FROM --to DATE_TO INPUT_FILE [OUTPUT_FILE]
    statcalc --version
    statcalc --help
    statcalc help subcommand

ARGS:

    INPUT_FILE         File with raw data
    OUTPUT_FILE        File to write statistics to

FLAGS:

    -h, --print-header        Specifies wheather to print header before the
                              outputs

OPTIONS:

    -f, --from        Start date for the period
    -t, --to          End date for the period  (default: 2017-12-20)

SUBCOMMANDS:

    validate        Validates the raw contents of a file

```

The things to note are:
* Optimus formed a formatted help information and also exited;
* it also offers some other autogenerated commands (`--version` and `help subcommand`).

Now if we finally produce a valid list of args, we'll have our arguments parsed:

```elixir
>./statcalc --print-header -f 2016-01-01 -t 2016-02-01 infile.raw outfile.dat
%Optimus.ParseResult{
  args: %{
    infile: "infile.raw",
    outfile: "outfile.dat"
  },
  flags: %{
    print_header: true
  },
  options: %{
    date_from: ~D[2016-01-01],
    date_to: ~D[2016-02-01]
  },
  unknown: []
}
```

`Optimus.ParseResult` is a struct with four fields: `args`, `flags`, `options`,
which are maps, and `unknown`, which is a list. Things to note are:
* `unknown` list is always empty if we set `allow_unknown_args: false` for our
(sub)command;
* values in `args`, `flags` and `options` maps are kept under keys specified in configuration;
* for options with `multiple: true` the value is a list;
* for flags without `multiple: true` the value is a boolean;
* for flags with `multiple: true` the value is an integer (representing the
  number of occurrences of a flag).

One can load configuration from a YAML file:

```elixir
optimus = Optimus.from_yaml!("path/to/config.yaml")
```

But in this case custom parsers are obviously unavailable.

## Credits

* [José Valim](https://github.com/josevalim) and all other creators of [`Elixir`](http://elixir-lang.org)
* [Kevin K.](https://github.com/kbknapp) and all other creators of [`clap.rs`](https://clap.rs)

[![Sponsored by FunBox](https://funbox.ru/badges/sponsored_by_funbox_centered.svg)](https://funbox.ru)
