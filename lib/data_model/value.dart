
/// Wrapper for optional values passed to copyWith() functions.
/// Ensures that null values are not interpreted as "do not change" but as "set to null".
class Value<T> {
  final T value;

  const Value(this.value);
}