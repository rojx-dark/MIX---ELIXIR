defmodule Biblioteca.Libro do
  @moduledoc "Struct que representa un libro de la biblioteca."

  @enforce_keys [:isbn, :titulo, :autor]
  defstruct [:isbn, :titulo, :autor, :anio, :genero, disponible: true]

  def nuevo(isbn, titulo, autor, anio, genero) do
    cond do
      String.trim(isbn) == "" -> {:error, :isbn_vacio}
      String.trim(titulo) == "" -> {:error, :titulo_vacio}
      not is_integer(anio) or anio < 0 -> {:error, :anio_invalido}
      true ->
        {:ok, %__MODULE__{isbn: isbn, titulo: titulo, autor: autor, anio: anio, genero: genero, disponible: true}}
    end
  end

  def prestar(%__MODULE__{disponible: true} = libro), do: {:ok, %{libro | disponible: false}}
  def prestar(%__MODULE__{disponible: false}), do: {:error, :libro_no_disponible}

  def devolver(%__MODULE__{disponible: false} = libro), do: {:ok, %{libro | disponible: true}}
  def devolver(%__MODULE__{disponible: true}), do: {:error, :libro_ya_disponible}

  def es_clasico?(%__MODULE__{anio: anio}), do: Date.utc_today().year - anio > 50
end
