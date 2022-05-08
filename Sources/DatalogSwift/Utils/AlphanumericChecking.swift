extension Character {

    var isAlphanumeric: Bool {
        get {
            self.isLetter || self.isNumber
        }
    }
}
