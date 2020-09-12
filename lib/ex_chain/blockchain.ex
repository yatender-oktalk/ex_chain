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

  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    # Here we need to think how can we preserve state
    # I think by gen_server :D
    {last_block, _} = List.pop_at(chain, -1)

    %{blockchain | chain: chain ++ [Block.mine_block(last_block, data)]}
  end

  defp add_genesis(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end
end
