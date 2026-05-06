defmodule Biblioteca.Menu do
  @moduledoc "Menú interactivo por consola para la biblioteca."

  alias Biblioteca.Biblioteca, as: Bib
  alias Biblioteca.GestionArchivos

  def iniciar do
    IO.puts("\n===================================")
    IO.puts("   SISTEMA DE GESTIÓN BIBLIOTECA")
    IO.puts("===================================\n")

    case GestionArchivos.cargar_estado() do
      {:ok, estado} ->
        IO.puts("Libros: #{map_size(estado.libros)} | Usuarios: #{map_size(estado.usuarios)} | Préstamos: #{map_size(estado.prestamos)}\n")
        loop(estado)
      {:error, _} ->
        IO.puts("Error al cargar. Iniciando vacío.\n")
        loop(Bib.nuevo())
    end
  end

  defp loop(estado) do
    mostrar_menu()
    op = IO.gets("Seleccione una opción: ") |> String.trim()

    case op do
      "1"  -> estado |> agregar_libro() |> loop()
      "2"  -> estado |> eliminar_libro() |> loop()
      "3"  -> estado |> listar_libros() |> loop()
      "4"  -> estado |> agregar_usuario() |> loop()
      "5"  -> estado |> eliminar_usuario() |> loop()
      "6"  -> estado |> listar_usuarios() |> loop()
      "7"  -> estado |> registrar_prestamo() |> loop()
      "8"  -> estado |> registrar_devolucion() |> loop()
      "9"  -> estado |> listar_prestamos() |> loop()
      "10" -> estado |> reporte_mas_prestados() |> loop()
      "11" -> estado |> reporte_vencidos() |> loop()
      "12" -> estado |> reporte_por_genero() |> loop()
      "13" -> estado |> reporte_disponibilidad() |> loop()
      "14" -> estado |> reporte_clasicos() |> loop()
      "0"  ->
        IO.puts("\n¡Hasta luego!")
        :ok
      _ ->
        IO.puts("\nOpción no válida.\n")
        loop(estado)
    end
  end

  defp mostrar_menu do
    IO.puts("--- MENÚ PRINCIPAL ---")
    IO.puts("1.  Agregar libro")
    IO.puts("2.  Eliminar libro")
    IO.puts("3.  Listar libros")
    IO.puts("4.  Agregar usuario")
    IO.puts("5.  Eliminar usuario")
    IO.puts("6.  Listar usuarios")
    IO.puts("7.  Registrar préstamo")
    IO.puts("8.  Registrar devolución")
    IO.puts("9.  Listar préstamos")
    IO.puts("--- REPORTES ---")
    IO.puts("10. Libros más prestados")
    IO.puts("11. Usuarios con préstamos vencidos")
    IO.puts("12. Libros por género")
    IO.puts("13. Disponibilidad de libros")
    IO.puts("14. Libros clásicos")
    IO.puts("0.  Salir")
    IO.puts("----------------------")
  end

  # === LIBROS ===

  defp agregar_libro(estado) do
    isbn = IO.gets("ISBN: ") |> String.trim()
    titulo = IO.gets("Título: ") |> String.trim()
    autor = IO.gets("Autor: ") |> String.trim()
    anio_str = IO.gets("Año: ") |> String.trim()
    genero = IO.gets("Género: ") |> String.trim()

    case Integer.parse(anio_str) do
      {anio, _} ->
        case Bib.agregar_libro(estado, isbn, titulo, autor, anio, genero) do
          {:ok, nuevo} -> guardar_y_confirmar(nuevo, "Libro agregado.")
          {:error, :isbn_duplicado} -> IO.puts("\nError: ISBN duplicado.\n"); estado
          {:error, r} -> IO.puts("\nError: #{inspect(r)}\n"); estado
        end
      :error -> IO.puts("\nError: Año inválido.\n"); estado
    end
  end

  defp eliminar_libro(estado) do
    isbn = IO.gets("ISBN del libro a eliminar: ") |> String.trim()
    case Bib.eliminar_libro(estado, isbn) do
      {:ok, nuevo} -> guardar_y_confirmar(nuevo, "Libro eliminado.")
      {:error, _} -> IO.puts("\nError: Libro no encontrado.\n"); estado
    end
  end

  defp listar_libros(estado) do
    libros = Bib.listar_libros(estado)
    if Enum.empty?(libros) do
      IO.puts("\nNo hay libros.\n")
    else
      IO.puts("\n=== Libros (#{length(libros)}) ===")
      Enum.each(libros, fn l ->
        disp = if l.disponible, do: "✓", else: "✗"
        IO.puts("  [#{disp}] #{l.isbn} | #{l.titulo} - #{l.autor} (#{l.anio}) [#{l.genero}]")
      end)
      IO.puts("")
    end
    estado
  end

  # === USUARIOS ===

  defp agregar_usuario(estado) do
    id = IO.gets("ID: ") |> String.trim()
    nombre = IO.gets("Nombre: ") |> String.trim()
    email = IO.gets("Email: ") |> String.trim()

    case Bib.agregar_usuario(estado, id, nombre, email) do
      {:ok, nuevo} -> guardar_y_confirmar(nuevo, "Usuario agregado.")
      {:error, :id_duplicado} -> IO.puts("\nError: ID duplicado.\n"); estado
      {:error, :email_invalido} -> IO.puts("\nError: Email inválido.\n"); estado
      {:error, r} -> IO.puts("\nError: #{inspect(r)}\n"); estado
    end
  end

  defp eliminar_usuario(estado) do
    id = IO.gets("ID del usuario a eliminar: ") |> String.trim()
    case Bib.eliminar_usuario(estado, id) do
      {:ok, nuevo} -> guardar_y_confirmar(nuevo, "Usuario eliminado.")
      {:error, _} -> IO.puts("\nError: Usuario no encontrado.\n"); estado
    end
  end

  defp listar_usuarios(estado) do
    usuarios = Bib.listar_usuarios(estado)
    if Enum.empty?(usuarios) do
      IO.puts("\nNo hay usuarios.\n")
    else
      IO.puts("\n=== Usuarios (#{length(usuarios)}) ===")
      Enum.each(usuarios, fn u ->
        IO.puts("  #{u.id} | #{u.nombre} (#{u.email}) - Prestados: #{length(u.libros_prestados)}/3")
      end)
      IO.puts("")
    end
    estado
  end

  # === PRÉSTAMOS ===

  defp registrar_prestamo(estado) do
    pid = IO.gets("ID del préstamo: ") |> String.trim()
    isbn = IO.gets("ISBN del libro: ") |> String.trim()
    uid = IO.gets("ID del usuario: ") |> String.trim()

    case Bib.registrar_prestamo(estado, pid, isbn, uid) do
      {:ok, nuevo} -> guardar_y_confirmar(nuevo, "Préstamo registrado.")
      {:error, :libro_no_encontrado} -> IO.puts("\nError: Libro no encontrado.\n"); estado
      {:error, :usuario_no_encontrado} -> IO.puts("\nError: Usuario no encontrado.\n"); estado
      {:error, :libro_no_disponible} -> IO.puts("\nError: Libro no disponible.\n"); estado
      {:error, :limite_prestamos_alcanzado} -> IO.puts("\nError: Límite de préstamos alcanzado.\n"); estado
      {:error, r} -> IO.puts("\nError: #{inspect(r)}\n"); estado
    end
  end

  defp registrar_devolucion(estado) do
    pid = IO.gets("ID del préstamo a devolver: ") |> String.trim()
    case Bib.registrar_devolucion(estado, pid) do
      {:ok, nuevo} -> guardar_y_confirmar(nuevo, "Devolución registrada.")
      {:error, :prestamo_no_encontrado} -> IO.puts("\nError: Préstamo no encontrado.\n"); estado
      {:error, :ya_devuelto} -> IO.puts("\nError: Ya fue devuelto.\n"); estado
      {:error, r} -> IO.puts("\nError: #{inspect(r)}\n"); estado
    end
  end

  defp listar_prestamos(estado) do
    prestamos = Bib.listar_prestamos(estado)
    if Enum.empty?(prestamos) do
      IO.puts("\nNo hay préstamos.\n")
    else
      IO.puts("\n=== Préstamos (#{length(prestamos)}) ===")
      Enum.each(prestamos, fn p ->
        dev = if p.fecha_devolucion, do: Date.to_iso8601(p.fecha_devolucion), else: "Pendiente"
        IO.puts("  #{p.id} | Libro: #{p.libro_isbn} | Usuario: #{p.usuario_id} | #{Date.to_iso8601(p.fecha_prestamo)} -> #{dev}")
      end)
      IO.puts("")
    end
    estado
  end

  # === REPORTES ===

  defp reporte_mas_prestados(estado) do
    lista = Bib.libros_mas_prestados(estado)
    IO.puts("\n=== Libros más prestados ===")
    if Enum.empty?(lista), do: IO.puts("  Sin datos.")
    Enum.each(lista, fn {isbn, titulo, c} -> IO.puts("  #{isbn} | #{titulo} - #{c} préstamo(s)") end)
    IO.puts("")
    estado
  end

  defp reporte_vencidos(estado) do
    lista = Bib.usuarios_con_prestamos_vencidos(estado)
    IO.puts("\n=== Préstamos vencidos ===")
    if Enum.empty?(lista), do: IO.puts("  No hay préstamos vencidos.")
    Enum.each(lista, fn i -> IO.puts("  #{i.usuario} (#{i.usuario_id}) - #{i.libro} | #{i.dias_retraso} días") end)
    IO.puts("")
    estado
  end

  defp reporte_por_genero(estado) do
    grupos = Bib.libros_por_genero(estado)
    IO.puts("\n=== Libros por género ===")
    Enum.each(grupos, fn {genero, libros} ->
      IO.puts("  #{genero}:")
      Enum.each(libros, fn l -> IO.puts("    - #{l.titulo} (#{l.autor}, #{l.anio})") end)
    end)
    IO.puts("")
    estado
  end

  defp reporte_disponibilidad(estado) do
    lista = Bib.disponibilidad_libros(estado)
    IO.puts("\n=== Disponibilidad ===")
    Enum.each(lista, fn {isbn, titulo, disp} -> IO.puts("  #{isbn} | #{titulo} -> #{disp}") end)
    IO.puts("")
    estado
  end

  defp reporte_clasicos(estado) do
    lista = Bib.libros_clasicos(estado)
    IO.puts("\n=== Libros clásicos (>50 años) ===")
    if Enum.empty?(lista), do: IO.puts("  No hay libros clásicos.")
    Enum.each(lista, fn l ->
      IO.puts("  #{l.titulo} (#{l.anio}) - #{Date.utc_today().year - l.anio} años")
    end)
    IO.puts("")
    estado
  end

  # === UTILIDADES ===

  defp guardar_y_confirmar(estado, mensaje) do
    case GestionArchivos.guardar_estado(estado) do
      :ok -> IO.puts("\n#{mensaje}\nDatos guardados.\n")
      {:error, _} -> IO.puts("\n#{mensaje}\nAdvertencia: No se pudieron guardar.\n")
    end
    estado
  end
end
