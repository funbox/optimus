defmodule Optimus.Usage do
  def usage(optimus, subcommand_path \\ []) do
    {subcommand, subcommand_name} = Optimus.fetch_subcommand(optimus, subcommand_path)
    flag_info = subcommand.flags |> Enum.filter(&(not &1.hide)) |> format_usage()
    option_info = subcommand.options |> Enum.filter(&(not &1.hide)) |> format_usage()
    arg_info = format_arg_usage(subcommand)
    usage_parts = [subcommand_name, flag_info, option_info, arg_info]

    usage_parts
    |> List.flatten()
    |> Enum.join(" ")
  end

  def help_usage(optimus) do
    optimus.name <> " --help"
  end

  def version_usage(optimus) do
    optimus.name <> " --version"
  end

  def subcomand_help_usage(optimus) do
    optimus.name <> " help subcommand"
  end

  defp format_usage(formatables) do
    formatables
    |> Enum.map(&Optimus.Format.format_in_usage/1)
  end

  defp format_arg_usage(subcommand) do
    arg_usage = format_usage(subcommand.args)

    if subcommand.allow_unknown_args do
      arg_usage ++ ["..."]
    else
      arg_usage
    end
  end
end
