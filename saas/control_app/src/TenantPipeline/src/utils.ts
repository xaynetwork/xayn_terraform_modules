export function assertNonNull<T>(obj: T | undefined): T {
    if (obj == null || obj == undefined) {
        throw Error("obj is null, but was asserted to be non null.")
    }
    return obj
} 
