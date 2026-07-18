# CocinaLab

App nativa para iPhone y iPad enfocada en experimentación culinaria: guarda
recetas, pruébalas varias veces y compara variantes de un mismo paso (ej.
"hornear 10 min" vs. "hornear 15 min") con sus propias fotos y notas.

## Stack

- SwiftUI + SwiftData
- Swift 5.9+, iOS / iPadOS 17+
- Sin dependencias externas
- Empaquetado como **App Playground** (`CocinaLab.swiftpm`) para poder
  abrirse y correrse directamente en **Swift Playgrounds en iPad**, sin
  necesitar una Mac. El mismo `.swiftpm` también se abre tal cual en Xcode
  si en algún momento tienes acceso a una Mac (Xcode 13+ reconoce las
  carpetas `.swiftpm` como proyecto nativo, no hace falta generar nada).

## Abrir en iPad (sin Mac)

1. Descarga/descomprime la carpeta `CocinaLab.swiftpm` en la app **Archivos**
   del iPad (por ejemplo, descargando el ZIP de la rama desde GitHub en
   Safari, o desde el archivo que te haya compartido directamente).
2. En Archivos, toca la carpeta `CocinaLab.swiftpm` — debería mostrar el
   icono de "App Playground" y abrir **Swift Playgrounds** automáticamente.
   Si en tu caso no la reconoce así (puede variar según versión de iPadOS),
   la alternativa manual es:
   - Abre Swift Playgrounds → crea un "App" en blanco.
   - Abre Archivos en pantalla partida junto a Playgrounds.
   - Arrastra las carpetas `Models`, `Views`, `Persistence`, `Utilities` y
     el archivo `CocinaLabApp.swift` hacia el navegador de archivos del
     proyecto en Playgrounds.
   - Borra los archivos de plantilla (`ContentView.swift`, el `App.swift`
     generado por Playgrounds, etc.) para que solo quede un `@main App`
     (el nuestro).
3. Ejecuta con el botón ▶️. Playgrounds compila y corre la app en el propio
   iPad.

## Estructura

```
CocinaLab.swiftpm/
  Package.swift              # manifiesto de la App Playground
  CocinaLabApp.swift         # entry point + modelContainer
  Models/                    # Recipe, Ingredient, Step, StepVariant, PhotoAsset
  Persistence/PhotoStore.swift  # fotos guardadas como JPEG en Documents/Photos
  Utilities/Formatters.swift
  Views/
    RecipeList/               # pantalla principal: grid + buscador
    RecipeDetail/               # modo lectura: ingredientes escalables,
                                 # pasos con temporizador e indicador de ramas
    RecipeForm/                  # alta/edición de receta
    Shared/
  Assets.xcassets/
```

## Modelo de datos: árbol de variantes

- `Recipe` → tiene `Ingredient`s y `Step`s ordenados.
- `Step` es un nodo del árbol: siempre contiene al menos una `StepVariant`
  (la creada junto con la receta). Cuando `variants.count > 1`, el paso
  muestra el indicador de "tarjetas apiladas" (`BranchIndicatorView`) en el
  modo lectura.
- `StepVariant` tiene su propio texto de instrucciones, temporizador
  opcional, notas de resultado y fotos (`PhotoAsset`).
- Tocar el indicador de un paso con variantes navega directamente a
  `StepVariantsView` para ESE paso (push en el `NavigationStack`, sin pasar
  por el editor completo de la receta). Ahí puedes moverte entre variantes
  con un segmented control o deslizando (swipe), y volver atrás con el botón
  de navegación estándar.
- Las fotos no se guardan en SwiftData: solo se guarda el nombre de archivo;
  el JPEG vive en `Documents/Photos` dentro del sandbox de la app
  (`PhotoStore`).

## CI

`.github/workflows/cocinalab-ios.yml` compila el paquete en un runner macOS
de GitHub Actions (`xcodebuild build` sobre `CocinaLab.swiftpm`) en cada
push, para detectar errores de compilación sin necesitar una Mac local.

## Notas de diseño

- La grilla de recetas usa columnas adaptativas (`GridItem(.adaptive)`), más
  anchas en iPad, para lograr el layout de dos columnas en pantallas
  grandes.
- Editar una receta existente actualiza el título y la variante principal de
  cada paso, pero nunca borra variantes adicionales — esas solo se eliminan
  si borras el paso completo desde el formulario.
