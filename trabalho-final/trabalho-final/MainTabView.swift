import SwiftUI

struct MainTabView: View {
    var body: some View {
        // Substitua depois pelo conteúdo real (ex.: TabView com várias telas)
        NavigationStack {
            VStack {
                Text("Tela principal")
                    .font(.largeTitle)
                Text("Em breve as demais telas")
                    .foregroundColor(.gray)
            }
            .navigationTitle("SensorySafe")
        }
    }
}
