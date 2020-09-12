defmodule ExChain.BlockChain do
  @moduledoc """
  This module contains the blockchain related functions
  """
  alias __MODULE__
  alias ExChain.BlockChain.Block

  defstruct ~w(chain)a

  @type t :: %BlockChain{
          chain: [Block.t({})]
        }

  @spec new :: BlockChain.t()
  def new() do
    %__MODULE__{}
    |> add_genesis()
  end

  def add_block(chain = %__MODULE__{}, data) do
    # Here we need to think how can we preserve state
    # I think by gen_server :D
    [Block.mine_block(Block.genesis(), data)]
  end

  defp add_genesis(chain = %__MODULE__{}) do
    %{chain | chain: [Block.genesis()]}
  end
end
