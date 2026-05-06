defmodule InventarioTest do
  use ExUnit.Case

  test "la aplicación se define correctamente" do
    assert Code.ensure_loaded?(Inventario)
  end
end
