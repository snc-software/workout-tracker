//
//  MuscleMapMuscleMapping.swift
//  WorkoutTracker
//

import MuscleMap

extension Muscle {
    /// The MuscleMap SDK region this muscle renders/highlights as.
    ///
    /// The library's 22 base regions don't line up 1:1 with this app's seeded muscles,
    /// so `Gastrocnemius` and `Soleus` both resolve to `.calves` — see `muscles(forRegion:in:)`.
    var muscleMapRegion: MuscleMap.Muscle? {
        switch name {
        case "Anterior deltoid": return .deltoids
        case "Biceps brachii": return .biceps
        case "Biceps femoris": return .hamstring
        case "Brachialis": return .biceps
        case "Gastrocnemius": return .calves
        case "Gluteus maximus": return .gluteal
        case "Latissimus dorsi": return .upperBack
        case "Obliquus externus abdominis": return .obliques
        case "Pectoralis major": return .chest
        case "Quadriceps femoris": return .quadriceps
        case "Rectus abdominis": return .abs
        case "Serratus anterior": return .serratus
        case "Soleus": return .calves
        case "Trapezius": return .trapezius
        case "Triceps brachii": return .triceps
        default: return nil
        }
    }

    /// All muscles from `allMuscles` that map to the given MuscleMap region.
    ///
    /// More than one `Muscle` can resolve to the same region (e.g. `.calves`), so a
    /// region tap must be able to toggle every matching muscle together.
    static func muscles(forRegion region: MuscleMap.Muscle, in allMuscles: [Muscle]) -> [Muscle] {
        allMuscles.filter { $0.muscleMapRegion == region }
    }
}
