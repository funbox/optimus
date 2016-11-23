defprotocol Optimus.Parser do
  @moduledoc false

  def parse(parser, parse_results, args)
end
