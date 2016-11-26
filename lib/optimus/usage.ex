defmodule Optimus.Usage do

  def usage(optimus, subcommand_path \\ []) do
    {subcommand, subcommand_name} = find_subcommand(optimus, subcommand_path, [optimus.name])
    flag_info = flags_usage(subcommand.flags)
    option_info = options_usage(subcommand.options)
    arg_info = args_usage(subcommand.args)
    usage_parts = [subcommand_name, flag_info, option_info, arg_info]
    usage_parts
    |> List.flatten
    |> Enum.join(" ")
  end

  def find_subcommand(optimus, subcommand_path, subcommand_name \\ [])
  def find_subcommand(optimus, [], subcommand_name), do: {optimus, Enum.reverse(subcommand_name)}
  def find_subcommand(optimus, [subcommand | subcommand_path], subcommand_name) do
    case Enum.find(optimus.subcommands, &(subcommand == &1.subcommand)) do
      %Optimus{} = subcommand -> find_subcommand(subcommand, subcommand_path, [subcommand.name | subcommand_name])
      nil -> {optimus, Enum.reverse(subcommand_name)}
    end
  end

  defp flags_usage(flags) do
    flags
    |> Enum.map(&flag_usage(&1))
  end

  defp options_usage(flags) do
    flags
    |> Enum.map(&option_usage(&1))
  end

  defp args_usage(args) do
    args
    |> Enum.map(&arg_usage(&1))
  end

  def flag_usage(flag) do
    flag_name = flag.long || flag.short
    "[#{flag_name}]"
  end

  def option_usage(option) do
    option_name = option.long || option.short
    if option.required do
      "#{option_name} #{option.value_name}"
    else
      "[#{option_name} #{option.value_name}]"
    end
  end

  def arg_usage(arg) do
    if arg.required do
      arg.value_name
    else
      "[#{arg.value_name}]"
    end
  end

end
