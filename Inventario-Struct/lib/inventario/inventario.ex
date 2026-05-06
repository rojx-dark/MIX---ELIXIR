defmodule Inventario.Inventario do
  @moduledoc """
  Módulo de lógica de negocio para la gestión del inventario.
  Usa un Map donde la clave es el código y el valor es el struct Producto.
  Incluye consultas avanzadas usando Enum.
  """

  alias Inventario.Producto

  # === CRUD ===

  @doc """
  Agrega un nuevo producto al inventario.
  No permite códigos repetidos.
  """
  def agregar_producto(inventario, codigo, nombre, precio, cantidad) do
    case Producto.nuevo(codigo, nombre, precio, cantidad) do
      {:ok, producto} ->
        if Map.has_key?(inventario, codigo) do
          {:error, :codigo_duplicado}
        else
          {:ok, Map.put(inventario, codigo, producto)}
        end

      {:error, razon} ->
        {:error, razon}
    end
  end

  @doc """
  Actualiza un producto existente en el inventario.
  """
  def actualizar_producto(inventario, codigo, nombre, precio, cantidad) do
    case Map.get(inventario, codigo) do
      nil ->
        {:error, :no_encontrado}

      _producto ->
        cond do
          String.trim(nombre) == "" ->
            {:error, :nombre_vacio}

          not Producto.solo_letras?(nombre) ->
            {:error, :nombre_invalido}

          not is_number(precio) or precio < 0 ->
            {:error, :precio_invalido}

          not is_integer(cantidad) or cantidad < 0 ->
            {:error, :cantidad_invalida}

          true ->
            actualizado = %Producto{codigo: codigo, nombre: nombre, precio: precio, cantidad: cantidad}
            {:ok, Map.put(inventario, codigo, actualizado)}
        end
    end
  end

  @doc """
  Elimina un producto del inventario por su código.
  """
  def eliminar_producto(inventario, codigo) do
    if Map.has_key?(inventario, codigo) do
      {:ok, Map.delete(inventario, codigo)}
    else
      {:error, :no_encontrado}
    end
  end

  @doc """
  Retorna la lista de todos los productos.
  """
  def listar_productos(inventario), do: Map.values(inventario)

  # === CONSULTAS AVANZADAS CON ENUM ===

  @doc """
  Productos cuyo nombre contenga al menos dos vocales.
  Retorna una lista de tuplas: [{codigo, nombre}]
  """
  def productos_con_dos_vocales(inventario) do
    vocales = ~w(a e i o u á é í ó ú A E I O U Á É Í Ó Ú)

    inventario
    |> Map.values()
    |> Enum.filter(fn producto ->
      cantidad_vocales =
        producto.nombre
        |> String.graphemes()
        |> Enum.count(fn char -> char in vocales end)

      cantidad_vocales >= 2
    end)
    |> Enum.map(fn producto -> {producto.codigo, producto.nombre} end)
  end

  @doc """
  Productos cuyo nombre comience y termine con la misma letra.
  """
  def productos_misma_letra_inicio_fin(inventario) do
    inventario
    |> Map.values()
    |> Enum.filter(fn producto ->
      nombre = String.trim(producto.nombre)

      if String.length(nombre) > 0 do
        primera = nombre |> String.first() |> String.downcase()
        ultima = nombre |> String.last() |> String.downcase()
        primera == ultima
      else
        false
      end
    end)
  end

  @doc """
  Productos con precio por debajo de un valor dado.
  """
  def productos_por_debajo_de_precio(inventario, precio_maximo) do
    inventario
    |> Map.values()
    |> Enum.filter(fn producto -> producto.precio < precio_maximo end)
  end

  @doc """
  Los tres productos más caros del inventario.
  """
  def tres_productos_mas_caros(inventario) do
    inventario
    |> Map.values()
    |> Enum.sort_by(fn producto -> producto.precio end, :desc)
    |> Enum.take(3)
  end

  @doc """
  Productos con precio entre dos valores.
  Retorna una cadena: "Producto1 - 50000, Producto2 - 70000"
  """
  def productos_entre_precios(inventario, precio_min, precio_max) do
    inventario
    |> Map.values()
    |> Enum.filter(fn producto ->
      producto.precio >= precio_min and producto.precio <= precio_max
    end)
    |> Enum.map(fn producto -> "#{producto.nombre} - #{producto.precio}" end)
    |> Enum.join(", ")
  end

  @doc """
  Agrupa productos por rango de precio:
  - Menores a 50000
  - Entre 50000 y 100000
  - Mayores a 100000
  """
  def agrupar_por_rango_precio(inventario) do
    productos = Map.values(inventario)

    %{
      "Menores a 50000" =>
        Enum.filter(productos, fn p -> p.precio < 50_000 end),
      "Entre 50000 y 100000" =>
        Enum.filter(productos, fn p -> p.precio >= 50_000 and p.precio <= 100_000 end),
      "Mayores a 100000" =>
        Enum.filter(productos, fn p -> p.precio > 100_000 end)
    }
  end
end
