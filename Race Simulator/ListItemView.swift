struct ListItemView: View {
    let at: Atlar // Replace with your actual model type

    var body: some View {
        VStack(alignment: .leading) {
            Text(at.name) // Assuming 'at' has a 'name' property
                .font(.headline)
            Text("Age: \(at.age)") // Assuming 'at' has an 'age' property
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}