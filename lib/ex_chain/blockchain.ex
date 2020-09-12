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
    %__MODULE__{chain: [Block.genesis()]}
  end

  @spec add_block(any()) :: [Block.t({})]
  def add_block(data) do
    # Here we need to think how can we preserve state
    # I think by gen_server :D
    [Block.mine_block(Block.genesis(), data)]
  end
end
