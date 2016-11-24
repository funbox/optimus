defprotocol Optimus.Parser do

  @type reason :: binary
  @type parse_result :: term
  @type rest_args :: [binary]

  @type parse_results :: {:ok, parse_result, rest_args} | {:error, reason, rest_args} | {:error, reason}

  def parse(parser, parsed, command_line)
end
