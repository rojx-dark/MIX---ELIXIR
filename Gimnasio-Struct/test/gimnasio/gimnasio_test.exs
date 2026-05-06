defmodule Gimnasio.GimnasioTest do
  use ExUnit.Case

  alias Gimnasio.Gimnasio, as: Gym

  describe "crear_socio/4" do
    test "crea un socio y lo agrega al mapa" do
      {:ok, socios} = Gym.crear_socio(%{}, "123", "Juan Pérez", 30)
      assert map_size(socios) == 1
      assert Map.has_key?(socios, "123")
    end

    test "no permite cédulas duplicadas" do
      {:ok, socios} = Gym.crear_socio(%{}, "123", "Juan", 30)
      assert {:error, :cedula_duplicada} = Gym.crear_socio(socios, "123", "Otro", 25)
    end
  end

  describe "eliminar_socio/2" do
    test "elimina un socio existente" do
      {:ok, socios} = Gym.crear_socio(%{}, "123", "Juan", 30)
      {:ok, socios} = Gym.eliminar_socio(socios, "123")
      assert map_size(socios) == 0
    end

    test "retorna error si el socio no existe" do
      assert {:error, :no_encontrado} = Gym.eliminar_socio(%{}, "999")
    end
  end

  describe "inscribir_clase/3" do
    test "inscribe a un socio en una clase" do
      {:ok, socios} = Gym.crear_socio(%{}, "123", "Juan", 30)
      {:ok, socios} = Gym.inscribir_clase(socios, "123", "Yoga")
      {:ok, socio} = Gym.buscar_socio(socios, "123")
      assert "Yoga" in socio.clases
    end
  end

  describe "buscar_socio/2" do
    test "encuentra un socio por cédula" do
      {:ok, socios} = Gym.crear_socio(%{}, "456", "Ana", 25)
      assert {:ok, socio} = Gym.buscar_socio(socios, "456")
      assert socio.nombre == "Ana"
    end

    test "retorna error si no existe" do
      assert {:error, :no_encontrado} = Gym.buscar_socio(%{}, "999")
    end
  end

  describe "socios_en_clase/2" do
    test "lista socios inscritos en una clase" do
      {:ok, socios} = Gym.crear_socio(%{}, "123", "Juan", 30)
      {:ok, socios} = Gym.crear_socio(socios, "456", "Ana", 25)
      {:ok, socios} = Gym.inscribir_clase(socios, "123", "Yoga")
      {:ok, socios} = Gym.inscribir_clase(socios, "456", "Yoga")
      resultado = Gym.socios_en_clase(socios, "Yoga")
      assert length(resultado) == 2
    end
  end
end
