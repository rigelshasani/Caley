//
//  WorkoutDetailView.swift
//  Caley
//
//  Created by Rigels H on 2024-09-05.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    // State variables for the new workout
    @State private var newTitle: String = ""
    @State private var newDescription: String = ""
    @State private var newRating: Int16 = 1

    // State variable to hold all workouts for the selected day
    @State private var workoutsForDate: [Workout] = []

    // State variables to keep track of the workout being edited
    @State private var editingWorkout: Workout?

    var selectedDate: Date

    var body: some View {
        NavigationView {
            VStack {
                Text("Add Workout for \(formattedDate(selectedDate))")
                    .font(.title)
                    .padding()

                Form {
                    // Section to add a new workout
                    Section(header: Text("Add New Workout")) {
                        TextField("Workout Title", text: $newTitle)
                        TextField("Workout Description", text: $newDescription)
                        Stepper(value: $newRating, in: 1...5) {
                            Text("Rating: \(newRating)")
                        }
                        Button(action: {
                            addNewWorkout()
                        }) {
                            Text("Save New Workout")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                    // Section to display and edit previous workouts for the day
                    if !workoutsForDate.isEmpty {
                        Section(header: Text("Previous Workouts")) {
                            ForEach(workoutsForDate, id: \.self) { workout in
                                VStack(alignment: .leading) {
                                    Text("Title: \(workout.title ?? "Untitled")")
                                    Text("Description: \(workout.desc ?? "No description")")
                                    Text("Rating: \(workout.rating)")

                                    HStack {
                                        // Edit Button
                                        Button(action: {
                                            editingWorkout = workout
                                            newTitle = workout.title ?? ""
                                            newDescription = workout.desc ?? ""
                                            newRating = workout.rating
                                        }) {
                                            Text("Edit")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }

                                        // Delete Button
                                        Button(action: {
                                            deleteWorkout(workout)
                                        }) {
                                            Text("Delete")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.red)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Workout", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Back")
            })
            .onAppear {
                fetchWorkoutsForDate() // Fetch all workouts for the selected date when the view appears
            }
        }
    }

    // Helper function to format the selected date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Function to fetch all workouts for the selected date
    private func fetchWorkoutsForDate() {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", Calendar.current.startOfDay(for: selectedDate) as CVarArg, Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: selectedDate))! as CVarArg)

        do {
            workoutsForDate = try viewContext.fetch(request)
        } catch {
            print("Error fetching workouts: \(error)")
        }
    }

    // Function to add a new workout
    private func addNewWorkout() {
        let newWorkout = editingWorkout ?? Workout(context: viewContext)
        newWorkout.title = newTitle
        newWorkout.desc = newDescription
        newWorkout.rating = newRating
        newWorkout.date = selectedDate

        do {
            try viewContext.save()
            fetchWorkoutsForDate() // Refresh the list of workouts after saving
            resetForm() // Reset the form for adding another workout
        } catch {
            print("Failed to save workout: \(error)")
        }
    }

    // Function to delete a workout
    private func deleteWorkout(_ workout: Workout) {
        viewContext.delete(workout)
        do {
            try viewContext.save()
            fetchWorkoutsForDate() // Refresh the list of workouts after deletion
        } catch {
            print("Error deleting workout: \(error)")
        }
    }

    // Function to reset the form fields after adding a workout
    private func resetForm() {
        newTitle = ""
        newDescription = ""
        newRating = 1
        editingWorkout = nil // Reset editing state
    }
}
