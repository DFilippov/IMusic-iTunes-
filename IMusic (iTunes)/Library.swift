//
//  Library.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 25/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import SwiftUI
import URLImage

struct Library: View {
    
    @State var tracks = UserDefaults.standard.getTracks()
    @State private var showingAlert = false
    @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack (spacing: 20) {
                        Button(action: {
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizeTrackDetailView(viewModel: self.track)
                        }) {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9818451801, green: 0, blue: 0.01838182259, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9425438836, green: 0.9425438836, blue: 0.9425438836, alpha: 1)))
                                .cornerRadius(10)
                        }
                        Button(action: {
                            self.tracks = UserDefaults.standard.getTracks()
                        }) {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9818451801, green: 0, blue: 0.01838182259, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9425438836, green: 0.9425438836, blue: 0.9425438836, alpha: 1)))
                                .cornerRadius(10)
                        }
                    }
                }.padding().frame(height: 50)
                Divider().padding(.leading).padding(.trailing)
                List {
                    ForEach(tracks) { track in
                        
                        LibraryCell(cell: track)
                            .gesture(LongPressGesture().onEnded{ _ in
                                print("-= PRESSED =-")
                                self.track = track
                                self.showingAlert = true
                                
                                }.simultaneously(with: TapGesture().onEnded{ _ in
                                    let keyWindow = UIApplication.shared.connectedScenes
                                        .filter ({$0.activationState == .foregroundActive})
                                        .map({$0 as? UIWindowScene})
                                        .compactMap({$0})
                                        .first?.windows
                                        .filter({$0.isKeyWindow}).first
                                    
                                    let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                                    tabBarVC?.trackDetailView.delegate = self
                                    
                                    self.track = track
                                    self.tabBarDelegate?.maximizeTrackDetailView(viewModel: self.track)
                                }))
                    }.onDelete(perform: delete)
                }
            }
            .actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(
                    title: Text("Are you sure you want to delete this track?"),
                    buttons: [
                        .destructive(Text("Delete track"), action: {
                            print("-= DELETING TRACK: \(self.track.trackName) =-")
                            self.delete(track: self.track)
                        }),
                        .cancel()
                    ]
                )
            })
                .navigationBarTitle("Library")
        }
    }
    
    func delete(at offset: IndexSet) {
        tracks.remove(atOffsets: offset)
        UserDefaults.standard.saveTracks(listOfTracks: tracks)
    }
    
    func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        UserDefaults.standard.saveTracks(listOfTracks: tracks)
    }
}

struct LibraryCell: View {
    
    var cell: SearchViewModel.Cell
    
    var body: some View {
        HStack {
            URLImage(URL(string: cell.iconUrlString ?? "")!,
                     content: {
                        $0.image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(2)
            }
            )
            
            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)")
            }
        }
    }
}


struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}

extension Library: TrackMovingDelegate {
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        
//        return myIndex == -1 ? tracks[tracks.count - 1] : tracks[myIndex - 1]
        var nextTrack: SearchViewModel.Cell
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        track = nextTrack
        return nextTrack
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }

//        return myIndex + 1 > tracks.count - 1 ? tracks[0] : tracks[myIndex + 1]
        
        var nextTrack: SearchViewModel.Cell
               if myIndex + 1 == tracks.count {
                   nextTrack = tracks[0]
               } else {
                nextTrack = tracks[myIndex + 1]
               }
        track = nextTrack
        return nextTrack
    }
    
    
}
