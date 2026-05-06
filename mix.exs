defmodule Biblioteca.Prestamo do
  @moduledoc "Struct que representa un préstamo de la biblioteca."

  @enforce_keys [:id, :libro_isbn, :usuario_id, :fecha_prestamo]
  defstruct [:id, :libro_isbn, :usuario_id, :fecha_prestamo, fecha_devolucion: nil]

  @dias_limite 14

  def nuevo(id, libro_isbn, usuario_id) do
    {:ok, %__MODULE__{id: id, libro_isbn: libro_isbn, usuario_id: usuario_id, fecha_prestamo: Date.utc_today(), fecha_devolucion: nil}}
  end

  def registrar_devolucion(%__MODULE__{fecha_devolucion: nil} = prestamo) do
    {:ok, %{prestamo | fecha_devolucion: Date.utc_today()}}
  end
  def registrar_devolucion(%__MODULE__{}), do: {:error, :ya_devuelto}

  def dias_de_retraso(%__MODULE__{fecha_prestamo: fp, fecha_devolucion: nil}) do
    max(0, Date.diff(Date.utc_today(), fp) - @dias_limite)
  end
  def dias_de_retraso(%__MODULE__{fecha_prestamo: fp, fecha_devolucion: fd}) do
    max(0, Date.diff(fd, fp) - @dias_limite)
  end

  def vencido?(%__MODULE__{fecha_devolucion: nil} = p), do: dias_de_retraso(p) > 0
  def vencido?(%__MODULE__{}), do: false

  def activo?(%__MODULE__{fecha_devolucion: nil}), do: true
  def activo?(%__MODULE__{}), do: false
end
