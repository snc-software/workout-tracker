//
//  MuscleMapMuscleMappingTests.swift
//  WorkoutTrackerTests
//

import MuscleMap
import Testing
@testable import WorkoutTracker

struct MuscleMapMuscleMappingTests {
    @Test(arguments: [
        ("Anterior deltoid", MuscleMap.Muscle.deltoids),
        ("Biceps brachii", MuscleMap.Muscle.biceps),
        ("Biceps femoris", MuscleMap.Muscle.hamstring),
        ("Brachialis", MuscleMap.Muscle.biceps),
        ("Gastrocnemius", MuscleMap.Muscle.calves),
        ("Gluteus maximus", MuscleMap.Muscle.gluteal),
        ("Latissimus dorsi", MuscleMap.Muscle.upperBack),
        ("Obliquus externus abdominis", MuscleMap.Muscle.obliques),
        ("Pectoralis major", MuscleMap.Muscle.chest),
        ("Quadriceps femoris", MuscleMap.Muscle.quadriceps),
        ("Rectus abdominis", MuscleMap.Muscle.abs),
        ("Serratus anterior", MuscleMap.Muscle.serratus),
        ("Soleus", MuscleMap.Muscle.calves),
        ("Trapezius", MuscleMap.Muscle.trapezius),
        ("Triceps brachii", MuscleMap.Muscle.triceps)
    ])
    func seededMuscleMapsToExpectedRegion(name: String, expectedRegion: MuscleMap.Muscle) {
        let muscle = Muscle(name: name, displayName: name, isFront: true)

        #expect(muscle.muscleMapRegion == expectedRegion)
    }

    @Test func calvesRegionReturnsBothGastrocnemiusAndSoleus() {
        let gastrocnemius = Muscle(name: "Gastrocnemius", displayName: "Calves", isFront: false)
        let soleus = Muscle(name: "Soleus", displayName: "Soleus", isFront: false)
        let chest = Muscle(name: "Pectoralis major", displayName: "Chest", isFront: true)
        let allMuscles = [gastrocnemius, soleus, chest]

        let result = Muscle.muscles(forRegion: .calves, in: allMuscles)

        #expect(Set(result) == Set([gastrocnemius, soleus]))
    }
}
