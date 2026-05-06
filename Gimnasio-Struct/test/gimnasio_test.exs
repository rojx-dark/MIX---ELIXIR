defmodule GimnasioTest do
  use ExUnit.Case

  test "la aplicación se define correctamente" do
    assert Code.ensure_loaded?(Gimnasio)
  end
end
