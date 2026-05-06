# Gimnasio - Sistema de Gestión de Socios

## Descripción

Sistema de gestión de socios de un gimnasio implementado en Elixir usando Mix con Application.
Permite crear, eliminar, inscribir y desinscribir socios en clases deportivas, con persistencia automática en archivo CSV.

### Funcionalidades
- Crear y eliminar socios con validaciones (cédula única, edad positiva)
- Inscribir y desinscribir socios en clases (sin duplicados)
- Buscar socio por cédula
- Listar todos los socios
- Listar socios por clase específica
- Listar clases de un socio
- Persistencia automática en `socios.csv` después de cada operación

### Estructura de módulos
- `Gimnasio.Socio` - Definición del struct y validaciones
- `Gimnasio.Gimnasio` - Lógica de negocio
- `Gimnasio.GestionArchivos` - Lectura y escritura CSV
- `Gimnasio.Menu` - Menú interactivo por consola

## Ejecución

```bash
cd gimnasio
mix run --no-halt
```

## Aprendizajes

- Uso de structs con `@enforce_keys` para campos obligatorios
- Mapas como estructura de datos principal con cédula como clave
- Manejo de errores con tuplas `{:ok, resultado}` y `{:error, motivo}`
- Persistencia en CSV con manejo de errores de lectura/escritura
- Organización modular del código en un proyecto Mix con Application

## Uso de IA

Se utilizó inteligencia artificial como apoyo para:
- Estructuración del proyecto Mix con Application
- Diseño de la arquitectura modular
- Implementación del menú interactivo con persistencia automática
- Validaciones y manejo de errores con pattern matching
