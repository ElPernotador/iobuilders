# Dieter

Compañero offline de salud y entrenamiento para Android. Todo se guarda en el
teléfono (SQLite), sin cuentas ni servidores.

**Todo es editable.** La app viene con contenido por defecto (hábitos,
ejercicios, recetas y lista de compra), pero nada está fijo: podés renombrar,
borrar, reordenar y agregar en cada sección, y restaurar los valores por defecto
cuando quieras.

## Qué hace

- **Hoy** — panel del día: anillo de progreso, resumen (peso y tendencia, fuerza
  y bici de los últimos 7 días, racha) y checks de suplementos y alimentación.
  Con "Editar" podés renombrar, reordenar, borrar y agregar cualquier ítem.
- **Navegación por día** — barra de fecha (‹ fecha › y botón *Hoy*) en Hoy,
  Entrenamiento y Progreso, para rellenar o consultar cualquier día.
- **Entrenamiento** — rutina del día según el plan semanal, adaptada
  automáticamente si registrás dolor (oculta ejercicios no seguros para hombro o
  rodilla). Editable: podés agregar ejercicios propios y quitar los que no uses.
  Bici con minutos e intensidad; movilidad y misión de la mañana.
- **Comidas** — plan de 26 semanas con recetas, notas para intestino/hígado,
  reemplazo de comidas, recetas propias y búsqueda de recetas nuevas en internet
  (TheMealDB, sin API key).
- **Compras** — lista semanal por categorías, copiable, con recordatorios en los
  días de la semana que elijas.
- **Progreso** — peso y cintura con gráficos, fotos de seguimiento por fecha,
  mapa de calor de hábitos.
- **Ítems personalizados** — agregá lo que quieras seguir a diario
  (Ajustes → Mis ítems) y aparece como check en Hoy.

## Build

Requiere Flutter 3.32+ y el Android SDK.

```bash
flutter pub get
flutter test
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. La última
versión publicada está en [`releases/`](releases/).

## Estructura

```
lib/
  core/       # tema, widgets compartidos, storage (SQLite), notificaciones,
              # controladores de fecha y navegación, cliente TheMealDB
  data/       # datos semilla: plan de entrenamiento, recetas, plan de comidas, compras
  features/   # today, meals, training, shopping, progress, settings
android/      # app nativa (com.dieter.app) + receivers de arranque/desbloqueo
test/         # tests unitarios
```

## Aviso médico

Esta app no es consejo médico. Para hígado graso, glucosa, colesterol, dolor o
medicación, consultá con tu médico.
