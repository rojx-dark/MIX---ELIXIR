defmodule Inventario.ProductoTest do
  use ExUnit.Case

  alias Inventario.Producto

  describe "Producto.nuevo/4" do
    test "crea un producto válido" do
      assert {:ok, %Producto{codigo: "P001", nombre: "Arroz", precio: 45000, cantidad: 100}} =
               Producto.nuevo("P001", "Arroz", 45000, 100)
    end

    test "rechaza código mayor a 5 caracteres" do
      assert {:error, :codigo_muy_largo} = Producto.nuevo("P00123", "Arroz", 45000, 100)
    end

    test "rechaza nombre con números" do
      assert {:error, :nombre_invalido} = Producto.nuevo("P001", "Arroz123", 45000, 100)
    end

    test "rechaza precio negativo" do
      assert {:error, :precio_invalido} = Producto.nuevo("P001", "Arroz", -100, 100)
    end

    test "rechaza cantidad negativa" do
      assert {:error, :cantidad_invalida} = Producto.nuevo("P001", "Arroz", 45000, -5)
    end

    test "acepta precio cero" do
      assert {:ok, %Producto{precio: 0}} = Producto.nuevo("P001", "Arroz", 0, 100)
    end

    test "acepta cantidad cero" do
      assert {:ok, %Producto{cantidad: 0}} = Producto.nuevo("P001", "Arroz", 45000, 0)
    end
  end

  describe "Producto.solo_letras?/1" do
    test "acepta solo letras" do
      assert Producto.solo_letras?("Arroz")
    end

    test "acepta letras con acentos" do
      assert Producto.solo_letras?("Café Premium")
    end

    test "rechaza cadenas con números" do
      refute Producto.solo_letras?("Arroz123")
    end
  end
end
