defprotocol Optimus.Format do

  def help(formatable)
  def format(formatable)
  def format_in_usage(formatable)
  def format_in_error(formatable)

end
