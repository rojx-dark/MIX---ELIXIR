defmodule Inventario.Producto do
  @moduledoc """
  Struct que representa un producto del inventario.
  Cada producto tiene: código, nombre, precio y cantidad.
  """

  @enforce_keys [:codigo, :nombre, :precio, :cantidad]
  @derive Jason.Encoder
  defstruct [:codigo, :nombre, :precio, :cantidad]

  @doc """
  Crea un nuevo producto con validaciones.
  - Código: máximo 5 caracteres, no vacío
  - Nombre: solo letras y espacios
  - Precio: mayor o igual a 0
  - Cantidad: entero mayor o igual a 0
  Retorna {:ok, producto} o {:error, motivo}.
  """
  def nuevo(codigo, nombre, precio, cantidad) do
    cond do
      String.trim(codigo) == "" ->
        {:error, :codigo_vacio}

      String.length(codigo) > 5 ->
        {:error, :codigo_muy_largo}

      String.trim(nombre) == "" ->
        {:error, :nombre_vacio}

      not solo_letras?(nombre) ->
        {:error, :nombre_invalido}

      not is_number(precio) or precio < 0 ->
        {:error, :precio_invalido}

      not is_integer(cantidad) or cantidad < 0 ->
        {:error, :cantidad_invalida}

      true ->
        {:ok, %__MODULE__{codigo: codigo, nombre: nombre, precio: precio, cantidad: cantidad}}
    end
  end

  @doc """
  Verifica si una cadena contiene solo letras (incluyendo acentos) y espacios.
  """
  def solo_letras?(nombre) do
    String.match?(nombre, ~r/^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/)
  end
end
