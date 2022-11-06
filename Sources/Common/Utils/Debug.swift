func dePrint(_ object: Any...) {
    #if DEBUG
    for item in object {
        print(item)
    }
    #endif
}
