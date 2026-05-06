defmodule Gimnasio.Menu do
  @moduledoc """
  Módulo de menú interactivo por consola para la gestión de socios del gimnasio.
  Todas las funcionalidades son accesibles desde consola.
  """

  alias Gimnasio.Gimnasio, as: Gym
  alias Gimnasio.GestionArchivos

  @doc """
  Inicia el menú interactivo.
  Carga datos al iniciar y guarda después de cada operación.
  """
  def iniciar do
    IO.puts("\n===================================")
    IO.puts("  SISTEMA DE GESTIÓN DE GIMNASIO")
    IO.puts("===================================\n")

    case GestionArchivos.cargar_socios() do
      {:ok, socios} ->
        IO.puts("Datos cargados exitosamente. #{map_size(socios)} socio(s) encontrado(s).\n")
        loop(socios)

      {:error, _razon} ->
        IO.puts("Error al cargar datos. Iniciando con datos vacíos.\n")
        loop(%{})
    end
  end

  defp loop(socios) do
    mostrar_menu()
    opcion = IO.gets("Seleccione una opción: ") |> String.trim()

    case opcion do
      "1" -> socios |> crear_socio() |> loop()
      "2" -> socios |> eliminar_socio() |> loop()
      "3" -> socios |> inscribir_clase() |> loop()
      "4" -> socios |> desinscribir_clase() |> loop()
      "5" -> socios |> buscar_socio() |> loop()
      "6" -> socios |> listar_socios() |> loop()
      "7" -> socios |> listar_socios_por_clase() |> loop()
      "8" -> socios |> listar_clases_socio() |> loop()
      "0" ->
        IO.puts("\n¡Hasta luego!")
        :ok

      _ ->
        IO.puts("\nOpción no válida. Intente de nuevo.\n")
        loop(socios)
    end
  end

  defp mostrar_menu do
    IO.puts("--- MENÚ PRINCIPAL ---")
    IO.puts("1. Crear socio")
    IO.puts("2. Eliminar socio")
    IO.puts("3. Inscribir a clase")
    IO.puts("4. Desinscribir de clase")
    IO.puts("5. Buscar socio por cédula")
    IO.puts("6. Listar todos los socios")
    IO.puts("7. Listar socios por clase")
    IO.puts("8. Listar clases de un socio")
    IO.puts("0. Salir")
    IO.puts("----------------------")
  end

  # --- Opciones del menú ---

  defp crear_socio(socios) do
    cedula = IO.gets("Ingrese la cédula: ") |> String.trim()
    nombre = IO.gets("Ingrese el nombre: ") |> String.trim()
    edad_str = IO.gets("Ingrese la edad: ") |> String.trim()

    case Integer.parse(edad_str) do
      {edad, _} ->
        case Gym.crear_socio(socios, cedula, nombre, edad) do
          {:ok, socios_actualizados} ->
            guardar_y_confirmar(socios_actualizados, "Socio creado exitosamente.")

          {:error, :cedula_duplicada} ->
            IO.puts("\nError: Ya existe un socio con esa cédula.\n")
            socios

          {:error, :edad_invalida} ->
            IO.puts("\nError: La edad debe ser un número positivo.\n")
            socios

          {:error, razon} ->
            IO.puts("\nError: #{inspect(razon)}\n")
            socios
        end

      :error ->
        IO.puts("\nError: La edad debe ser un número válido.\n")
        socios
    end
  end

  defp eliminar_socio(socios) do
    cedula = IO.gets("Ingrese la cédula del socio a eliminar: ") |> String.trim()

    case Gym.eliminar_socio(socios, cedula) do
      {:ok, socios_actualizados} ->
        guardar_y_confirmar(socios_actualizados, "Socio eliminado exitosamente.")

      {:error, :no_encontrado} ->
        IO.puts("\nError: No se encontró un socio con esa cédula.\n")
        socios
    end
  end

  defp inscribir_clase(socios) do
    cedula = IO.gets("Ingrese la cédula del socio: ") |> String.trim()
    clase = IO.gets("Ingrese el nombre de la clase: ") |> String.trim()

    case Gym.inscribir_clase(socios, cedula, clase) do
      {:ok, socios_actualizados} ->
        guardar_y_confirmar(socios_actualizados, "Socio inscrito en #{clase} exitosamente.")

      {:error, :no_encontrado} ->
        IO.puts("\nError: No se encontró un socio con esa cédula.\n")
        socios

      {:error, :ya_inscrito} ->
        IO.puts("\nError: El socio ya está inscrito en esa clase.\n")
        socios

      {:error, razon} ->
        IO.puts("\nError: #{inspect(razon)}\n")
        socios
    end
  end

  defp desinscribir_clase(socios) do
    cedula = IO.gets("Ingrese la cédula del socio: ") |> String.trim()
    clase = IO.gets("Ingrese el nombre de la clase: ") |> String.trim()

    case Gym.desinscribir_clase(socios, cedula, clase) do
      {:ok, socios_actualizados} ->
        guardar_y_confirmar(socios_actualizados, "Socio desinscrito de #{clase} exitosamente.")

      {:error, :no_encontrado} ->
        IO.puts("\nError: No se encontró un socio con esa cédula.\n")
        socios

      {:error, :no_inscrito} ->
        IO.puts("\nError: El socio no está inscrito en esa clase.\n")
        socios
    end
  end

  defp buscar_socio(socios) do
    cedula = IO.gets("Ingrese la cédula a buscar: ") |> String.trim()

    case Gym.buscar_socio(socios, cedula) do
      {:ok, socio} ->
        IO.puts("\n=== Socio Encontrado ===")
        imprimir_socio(socio)
        IO.puts("")

      {:error, :no_encontrado} ->
        IO.puts("\nNo se encontró un socio con cédula #{cedula}.\n")
    end

    socios
  end

  defp listar_socios(socios) do
    lista = Gym.listar_socios(socios)

    if Enum.empty?(lista) do
      IO.puts("\nNo hay socios registrados.\n")
    else
      IO.puts("\n=== Lista de Socios (#{length(lista)}) ===")

      Enum.each(lista, fn socio ->
        imprimir_socio(socio)
      end)

      IO.puts("")
    end

    socios
  end

  defp listar_socios_por_clase(socios) do
    clase = IO.gets("Ingrese el nombre de la clase: ") |> String.trim()
    lista = Gym.socios_en_clase(socios, clase)

    if Enum.empty?(lista) do
      IO.puts("\nNo hay socios inscritos en #{clase}.\n")
    else
      IO.puts("\n=== Socios en #{clase} (#{length(lista)}) ===")

      Enum.each(lista, fn socio ->
        IO.puts("  - #{socio.cedula} | #{socio.nombre} (Edad: #{socio.edad})")
      end)

      IO.puts("")
    end

    socios
  end

  defp listar_clases_socio(socios) do
    cedula = IO.gets("Ingrese la cédula del socio: ") |> String.trim()

    case Gym.clases_de_socio(socios, cedula) do
      {:ok, clases} ->
        if Enum.empty?(clases) do
          IO.puts("\nEl socio no está inscrito en ninguna clase.\n")
        else
          IO.puts("\n=== Clases del socio #{cedula} ===")

          Enum.each(clases, fn clase ->
            IO.puts("  - #{clase}")
          end)

          IO.puts("")
        end

      {:error, :no_encontrado} ->
        IO.puts("\nNo se encontró un socio con cédula #{cedula}.\n")
    end

    socios
  end

  # --- Utilidades ---

  defp imprimir_socio(socio) do
    clases_str =
      if Enum.empty?(socio.clases),
        do: "Ninguna",
        else: Enum.join(socio.clases, ", ")

    IO.puts("  Cédula: #{socio.cedula} | Nombre: #{socio.nombre} | Edad: #{socio.edad} | Clases: #{clases_str}")
  end

  defp guardar_y_confirmar(socios, mensaje) do
    case GestionArchivos.guardar_socios(socios) do
      :ok ->
        IO.puts("\n#{mensaje}")
        IO.puts("Datos guardados en socios.csv.\n")

      {:error, _} ->
        IO.puts("\n#{mensaje}")
        IO.puts("Advertencia: No se pudieron guardar los datos.\n")
    end

    socios
  end
end
