defmodule App.Store do
  @moduledoc """
  The Store context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Store.Cuboid

  @doc """
  Returns the list of cuboids.

  ## Examples

      iex> list_cuboids()
      [%Cuboid{}, ...]

  """
  def list_cuboids do
    Repo.all(Cuboid) |> Repo.preload(:bag)
  end

  @doc """
  Gets a single cuboid.

  Raises if the Cuboid does not exist.

  ## Examples

      iex> get_cuboid!(123)
      %Cuboid{}

  """
  def get_cuboid(id), do: Repo.get(Cuboid, id) |> Repo.preload(:bag)

  @doc """
  Creates a cuboid.

  ## Examples

      iex> create_cuboid(%{field: value})
      {:ok, %Cuboid{}}

      iex> create_cuboid(%{field: bad_value})
      {:error, ...}

  """
  def create_cuboid(attrs \\ %{}) do
    %Cuboid{}
    |> Cuboid.changeset(attrs)
    |> Repo.insert()
  end

  def update_cuboid(id, attrs) do
    get_cuboid(id)
    |> Cuboid.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_cuboid(id) do
    cuboid = get_cuboid(id)
    case cuboid do
      nil -> {:error, :not_found}
      cuboid -> cuboid |> Repo.delete()

    end
  end

  alias App.Store.Bag

  @doc """
  Returns the list of bags.

  ## Examples

      iex> list_bags()
      [%Bag{}, ...]

  """
  def list_bags do
    Repo.all(Bag) |> Repo.preload(:cuboids)
  end

  @doc """
  Gets a single bag.

  Raises if the Bag does not exist.

  ## Examples

      iex> get_bag!(123)
      %Bag{}

  """
  def get_bag(id), do: Repo.get(Bag, id) |> Repo.preload(:cuboids) |> update_volumes

  def update_volumes(nil) do
    :no_bag
  end


  def update_volumes(bag) do
    payload_volume = bag.cuboids
    |> Enum.reduce(0, fn(cuboid, acc) ->
      volume = cuboid.width * cuboid.height * cuboid.depth
      acc + volume end)

    bag1 = Map.put(bag, :availableVolume, bag.volume - payload_volume)
    Map.put(bag1, :payloadVolume, payload_volume)
  end




  @doc """
  Creates a bag.

  ## Examples

      iex> create_bag(%{field: value})
      {:ok, %Bag{}}

      iex> create_bag(%{field: bad_value})
      {:error, ...}

  """
  def create_bag(attrs \\ %{}) do
    %Bag{}
    |> Bag.changeset(attrs)
    |> Repo.insert()
  end
end
