defmodule Inventario.InventarioTest do
  use ExUnit.Case

  alias Inventario.Inventario, as: Inv

  # Setup: crear inventario con datos de prueba
  setup do
    inventario = %{}
    {:ok, inventario} = Inv.agregar_producto(inventario, "P001", "Arroz", 45000, 100)
    {:ok, inventario} = Inv.agregar_producto(inventario, "P002", "Aceite", 120000, 30)
    {:ok, inventario} = Inv.agregar_producto(inventario, "P003", "Leche", 8500, 200)
    %{inventario: inventario}
  end

  describe "agregar_producto/5" do
    test "agrega un producto nuevo al inventario" do
      {:ok, inv} = Inv.agregar_producto(%{}, "P001", "Arroz", 45000, 100)
      assert map_size(inv) == 1
    end

    test "no permite códigos duplicados", %{inventario: inventario} do
      assert {:error, :codigo_duplicado} =
               Inv.agregar_producto(inventario, "P001", "Leche", 8500, 200)
    end
  end

  describe "eliminar_producto/2" do
    test "elimina un producto existente", %{inventario: inventario} do
      {:ok, inv} = Inv.eliminar_producto(inventario, "P001")
      assert map_size(inv) == 2
    end

    test "retorna error si no existe" do
      assert {:error, :no_encontrado} = Inv.eliminar_producto(%{}, "P999")
    end
  end

  describe "actualizar_producto/5" do
    test "actualiza un producto existente", %{inventario: inventario} do
      {:ok, inv} = Inv.actualizar_producto(inventario, "P001", "Arroz Integral", 50000, 80)
      producto = Map.get(inv, "P001")
      assert producto.nombre == "Arroz Integral"
      assert producto.precio == 50000
    end

    test "retorna error si no existe" do
      assert {:error, :no_encontrado} =
               Inv.actualizar_producto(%{}, "P999", "Test", 100, 10)
    end
  end

  describe "Consultas Enum" do
    test "productos con al menos 2 vocales", %{inventario: inventario} do
      resultado = Inv.productos_con_dos_vocales(inventario)
      codigos = Enum.map(resultado, fn {cod, _} -> cod end)
      assert "P001" in codigos
      assert "P002" in codigos
      assert "P003" in codigos
    end

    test "tres productos más caros", %{inventario: inventario} do
      resultado = Inv.tres_productos_mas_caros(inventario)
      assert length(resultado) == 3
      precios = Enum.map(resultado, & &1.precio)
      assert precios == Enum.sort(precios, :desc)
    end

    test "productos por debajo de un precio", %{inventario: inventario} do
      resultado = Inv.productos_por_debajo_de_precio(inventario, 50000)
      assert length(resultado) == 2
    end

    test "productos entre precios retorna cadena", %{inventario: inventario} do
      resultado = Inv.productos_entre_precios(inventario, 10000, 50000)
      assert is_binary(resultado)
      assert String.contains?(resultado, "Arroz")
    end

    test "agrupar por rango de precio", %{inventario: inventario} do
      resultado = Inv.agrupar_por_rango_precio(inventario)
      assert Map.has_key?(resultado, "Menores a 50000")
      assert Map.has_key?(resultado, "Entre 50000 y 100000")
      assert Map.has_key?(resultado, "Mayores a 100000")
    end
  end
end
