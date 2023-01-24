defmodule App.Store.Cuboid do
  @moduledoc """
  This module defines the Cuboid schema.
  """

  alias App.Store

  use Ecto.Schema
  import Ecto.Changeset

  schema "cuboids" do
    field :depth, :integer
    field :height, :integer
    field :width, :integer
    field :volume, :integer
    belongs_to :bag, App.Store.Bag

    timestamps()
  end

  @doc false
  def changeset(cuboid, attrs) do
    cuboid
    |> cast(attrs, [:width, :height, :depth, :bag_id])
    |> validate_required([:width, :height, :depth])
    |> cast_assoc(:bag, require: true)
    |> assoc_constraint(:bag, require: true)
    |> add_volume()
  end


  defp add_volume(changeset) do
    case changeset.valid? do
      false ->
        changeset
      true ->
        %{width: width, depth: depth, height: height, bag_id: bag_id} = changeset.changes
        volume = width * height * depth
        bag = Store.get_bag(bag_id)
        case bag do
          :no_bag -> add_error(changeset, :bag, "does not exist")
          bag ->
            case bag.availableVolume >  volume do
              true ->
                existing_changes = changeset.changes
                Map.put(changeset, :changes, Map.put(existing_changes, :volume, volume))
              false ->
                add_error(changeset, :volume, "Insufficient space in bag")
            end

        end
    end
  end


  def update_changeset(cuboid, attrs) do
    cuboid
    |> cast(attrs, [:width, :height, :depth, :bag_id])
    |> validate_required([:width, :height, :depth])
    |> cast_assoc(:bag, require: true)
    |> assoc_constraint(:bag, require: true)
    |> check_volume()
  end


  def check_volume(changeset) do
    case changeset.valid? do
      false ->
        changeset
      true ->
        %{width: width, depth: depth, height: height} = changeset.changes
        %{bag_id: bag_id} = changeset.data
        volume = width * height * depth
        bag = Store.get_bag(bag_id)

        case bag do
          :no_bag -> add_error(changeset, :bag, "does not exist")
          bag ->
            case bag.availableVolume >  volume do
              true ->
                existing_changes = changeset.changes
                Map.put(changeset, :changes, Map.put(existing_changes, :volume, volume))
              false ->
                add_error(changeset, :volume, "Insufficient space in bag")
            end
        end
      end
  end
end
