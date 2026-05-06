defmodule Biblioteca.Usuario do
  @moduledoc "Struct que representa un usuario de la biblioteca."

  @enforce_keys [:id, :nombre, :email]
  defstruct [:id, :nombre, :email, libros_prestados: []]

  @max_prestamos 3

  def nuevo(id, nombre, email) do
    cond do
      String.trim(id) == "" -> {:error, :id_vacio}
      String.trim(email) == "" -> {:error, :email_vacio}
      not String.contains?(email, "@") -> {:error, :email_invalido}
      true -> {:ok, %__MODULE__{id: id, nombre: nombre, email: email, libros_prestados: []}}
    end
  end

  def puede_prestar?(%__MODULE__{libros_prestados: libros}), do: length(libros) < @max_prestamos

  def agregar_prestamo(%__MODULE__{libros_prestados: libros} = usuario, isbn) do
    cond do
      isbn in libros -> {:error, :ya_tiene_libro}
      not puede_prestar?(usuario) -> {:error, :limite_prestamos_alcanzado}
      true -> {:ok, %{usuario | libros_prestados: [isbn | libros]}}
    end
  end

  def quitar_prestamo(%__MODULE__{libros_prestados: libros} = usuario, isbn) do
    if isbn in libros do
      {:ok, %{usuario | libros_prestados: List.delete(libros, isbn)}}
    else
      {:error, :libro_no_prestado}
    end
  end
end
