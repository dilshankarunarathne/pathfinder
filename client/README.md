# turn-by-turn-navigation-flutter

Uint8List get data {
    final data = cast<Uint8>(tfliteBinding.TfLiteTensorData(_tensor));
    return data.asTypedList(tfliteBinding.TfLiteTensorByteSize(_tensor)).asUnmodifiableView();
  }

  adb reverse tcp:8000 tcp:8000