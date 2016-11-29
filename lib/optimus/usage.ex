defmodule Optimus.Usage do

  def usage(optimus, subcommand_path \\ []) do
    {subcommand, subcommand_name} = find_subcommand(optimus, subcommand_path, [optimus.name])
    flag_info = format_usage(subcommand.flags)
    option_info = format_usage(subcommand.options)
    arg_info = format_usage(subcommand.args)
    usage_parts = [subcommand_name, flag_info, option_info, arg_info]
    usage_parts
    |> List.flatten
    |> Enum.join(" ")
  end

  def find_subcommand(optimus, [], subcommand_name), do: {optimus, Enum.reverse(subcommand_name)}
  def find_subcommand(optimus, [subcommand_id | subcommand_path], subcommand_name) do
    subcommand = Enum.find(optimus.subcommands, &(subcommand_id == &1.subcommand))
    find_subcommand(subcommand, subcommand_path, [subcommand.name | subcommand_name])
  end

  defp format_usage(formatables) do
    formatables
    |> Enum.map(&Optimus.Format.format_in_usage(&1))
  end

end
