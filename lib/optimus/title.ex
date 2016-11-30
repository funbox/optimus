defmodule Optimus.Title do
  def title(optimus, subcommand_path \\ []) do
    {author, description, version, about} = find_title_info(optimus, subcommand_path)
    lines = [
      line([description, version]),
      line([author]),
      line([about])
    ]
    lines
    |> List.flatten
  end

  def find_title_info(optimus, []), do: {optimus.author, optimus.description, optimus.version, optimus.about}
  def find_title_info(optimus, [subcommand_id | subcommand_path]) do
    subcommand = Enum.find(optimus.subcommands, &(subcommand_id == &1.subcommand))
    {author, description, version, about} = find_title_info(subcommand, subcommand_path)
    {
      author || optimus.author,
      description || optimus.description,
      version || optimus.version,
      about || optimus.about
    }
  end

  defp line(items) do
    case Enum.filter(items, &(&1)) do
      [] -> []
      list -> Enum.join(list, " ")
    end
  end

end
