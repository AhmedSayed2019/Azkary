/// Minimal local result wrapper used by the `features/refactor` slices.
///
/// This project has no `ApiResult<T>` (no networking layer with that shape),
/// so this tiny sealed type stands in for it: `Ok<T>` carries the success
/// payload, `Err<T>` carries a human-readable failure message.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);

  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.message);

  final String message;
}
