defmodule Optimus.Help do
  def help(optimus, subcommand_path, max_width) do
    title = Optimus.Title.title(optimus, subcommand_path)
    usage = usage(optimus, subcommand_path)

    {subcommand, _} = Optimus.fetch_subcommand(optimus, subcommand_path)

    formatable_help =
      subcommand_formatables(subcommand)
      |> nonempty_formatables
      |> formatable_help(max_width)

    title ++ usage ++ formatable_help ++ [""]
  end

  defp usage(optimus, []) do
    List.flatten([
      "",
      "USAGE:",
      "    #{Optimus.Usage.usage(optimus)}",
      "    #{Optimus.Usage.version_usage(optimus)}",
      "    #{Optimus.Usage.help_usage(optimus)}",
      case optimus.subcommands do
        [] -> []
        _ -> "    #{Optimus.Usage.subcomand_help_usage(optimus)}"
      end,
      ""
    ])
  end

  defp usage(optimus, subcommand_path) do
    [
      "",
      "USAGE:",
      "    #{Optimus.Usage.usage(optimus, subcommand_path)}",
      ""
    ]
  end

  defp subcommand_formatables(subcommand) do
    [
      {"ARGS:", subcommand.args},
      {"FLAGS:", subcommand.flags},
      {"OPTIONS:", subcommand.options},
      {"SUBCOMMANDS:", subcommand.subcommands}
    ]
  end

  defp nonempty_formatables(formatables_with_titles) do
    formatables_with_titles
    |> Enum.reject(fn {_, list} -> is_nil(list) || list == [] end)
  end

  defp formatable_help(formatables_with_titles, max_width) do
    formatables_with_titles
    |> Enum.map(fn {title, formatables} ->
      Optimus.FormatableHelp.formatable_help(title, formatables, max_width)
    end)
    |> Enum.intersperse([""])
    |> Enum.concat()
  end
end
