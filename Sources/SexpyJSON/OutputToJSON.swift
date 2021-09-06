import Foundation

func outputToJSONObject(_ value: OutputValue) -> Any? {
    switch value {
    case let .number(n): return n
    case .null: return nil
    case let .string(s): return s
    case let .boolean(b): return b
    case let .array(a): return a.map(outputToJSONObject)
    case let .object(members):
        let pairs = members.map { member in
            (member.name, outputToJSONObject(member.value))
        }
        return Dictionary(pairs, uniquingKeysWith: { $1 })
    }
}
