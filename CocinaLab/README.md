# CocinaLab

App nativa para iPhone y iPad enfocada en experimentación culinaria: guarda
recetas, pruébalas varias veces y compara variantes de un mismo paso (ej.
"hornear 10 min" vs. "hornear 15 min") con sus propias fotos y notas.

## Stack

- SwiftUI + SwiftData
- Swift 5.9+, iOS / iPadOS 17+
- Sin dependencias externas

## Estructura

```
CocinaLab/
  project.yml                 # definición del proyecto (XcodeGen)
  CocinaLab/
    CocinaLabApp.swift        # entry point + modelContainer
    Models/                   # Recipe, Ingredient, Step, StepVariant, PhotoAsset
    Persistence/PhotoStore.swift  # fotos guardadas como JPEG en Documents/Photos
    Utilities/Formatters.swift
    Views/
      RecipeList/              # pantalla principal: grid + buscador
      RecipeDetail/             # modo lectura: ingredientes escalables,
                                 # pasos con temporizador e indicador de ramas
      RecipeForm/                # alta/edición de receta
  CocinaLabTests/
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
  por el editor completo de la receta). Ahí puedes moverse entre variantes
  con un segmented control o deslizando (swipe), y volver atrás con el botón
  de navegación estándar.
- Las fotos no se guardan en SwiftData: solo se guarda el nombre de archivo;
  el JPEG vive en `Documents/Photos` dentro del sandbox de la app
  (`PhotoStore`).

## Abrir el proyecto

Este repo no versiona el `.xcodeproj` (se genera con
[XcodeGen](https://github.com/yonaskolb/XcodeGen) para evitar conflictos en
el `pbxproj`). En una Mac con Xcode instalado:

```bash
brew install xcodegen
cd CocinaLab
xcodegen generate
open CocinaLab.xcodeproj
```

Selecciona el esquema `CocinaLab` y un simulador de iPhone o iPad (iOS 17+)
para correr la app. El target `CocinaLabTests` incluye pruebas unitarias
sobre el escalado de ingredientes y la lógica de variantes.

## Notas de diseño

- La grilla de recetas usa columnas adaptativas (`GridItem(.adaptive)`), más
  anchas en iPad, para lograr el layout de dos columnas en pantallas
  grandes sin necesitar una `NavigationSplitView` separada.
- Editar una receta existente actualiza el título y la variante principal de
  cada paso, pero nunca borra variantes adicionales — esas solo se eliminan
  si borras el paso completo desde el formulario.
