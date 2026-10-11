# IR Control

Aplicación Flutter para usar el emisor infrarrojo de un teléfono Android como control remoto de un televisor TCL 50P7K.

## Funciones

- Detecta si el teléfono tiene emisor infrarrojo y consulta sus rangos de frecuencia.
- Incluye encendido, silencio, fuente, navegación, inicio, atrás, ajustes, volumen, canales, guía, información, teclado numérico, botones de color y accesos directos.
- Usa el paquete [`infrared_plugin`](https://pub.dev/packages/infrared_plugin) para transmitir señales desde Android.
- Muestra el estado de la transmisión y gestiona el caso en que no haya emisor disponible.

## Compatibilidad y códigos

La transmisión IR de este proyecto funciona en Android con un teléfono que tenga emisor infrarrojo. El paquete utilizado no ofrece implementación para iOS ni Web. Android clasifica `TRANSMIT_IR` como permiso normal, por lo que no aparece una solicitud de autorización durante el uso.

La app transmite el perfil NIKAI a 38 kHz. El usuario confirmó encendido y volumen con un TCL 50P7K. Los comandos extendidos se basan en un perfil publicado para un TCL 55T8B con control RC833 y deben probarse con el televisor; no se garantiza que todos funcionen en el 50P7K.

## Requisitos

- Flutter y Dart compatibles con las restricciones indicadas en `pubspec.yaml`.
- Android 4.4 (API 19) o posterior.
- Teléfono Android con emisor IR para transmitir comandos.

## Preparar y compilar

```sh
flutter pub get
flutter analyze
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

Para instalar en un teléfono conectado por USB con depuración habilitada:

```sh
flutter install
```

## Estructura principal

- `lib/main.dart`: punto de entrada de la aplicación.
- `lib/app.dart`: tema global y configuración de la pantalla inicial.
- `lib/screens/remote_screen.dart`: estado de la pantalla, detección del emisor y coordinación de comandos.
- `lib/widgets/remote_control_panel.dart`: distribución de botones y controles del mando.
- `lib/widgets/remote_buttons.dart`: botones reutilizables del mando.
- `lib/widgets/device_card.dart` y `lib/widgets/ir_status_card.dart`: tarjetas del televisor y del estado IR.
- `lib/services/infrared_service.dart`: consulta del emisor y transmisión de patrones infrarrojos.
- `lib/data/tcl_remote_codes.dart`: mapa de códigos del perfil del control.
- `lib/theme/app_colors.dart`: colores compartidos de la interfaz.
- `android/app/src/main/AndroidManifest.xml`: permiso `TRANSMIT_IR` y declaración opcional de hardware Consumer IR.
- `pubspec.yaml`: dependencias Flutter.

## Autor y contacto

- **Autor:** Erick jose Pinto Carrillo
- **Correo institucional:** [ejosepinto@unicesar.edu.co](mailto:ejosepinto@unicesar.edu.co)
