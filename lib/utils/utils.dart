T? castOrNull<T>(dynamic x) => x is T ? x : null;

T castOrFallback<T>(dynamic x, T fallback) => x is T ? x : fallback;
