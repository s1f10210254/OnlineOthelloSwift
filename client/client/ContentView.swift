//
//  ContentView.swift
//  client
//
//  Created by Hiroki on 2024/01/08.
//

import SwiftUI

struct ContentView: View {
  let rows = 8
  let columns = 8
  @State private var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 8), count: 8)
  @State private var turn: Int = 1
  @State private var blackCount: Int = 0
  @State private var whiteCount: Int = 0
  @State private var possibleMoves: [(Int, Int)] = []
  @State private var passCount: Int = 0
  @State private var passMessage: String = ""
  @State private var userTurn: Int = 1 // 1 = 黒, 2 = 白

  var body: some View {
    Text("OthelloGame")
      .font(.largeTitle)
    HStack {
      Text("黒: \(blackCount)")
      Text("白: \(whiteCount)")
    }
    .font(.headline)

    Text(turn == 1 ? "黒のターン" : "白のターン")
      .font(.headline)
      .padding()

    VStack(spacing: 1) {
      ForEach(0..<rows, id: \.self) { row in
        HStack(spacing: 1) {
          ForEach(0..<columns, id: \.self) { column in
            Button(action: {
              onClick(x: row, y: column)
            }) {
              pieceView(at: row, y: column)
                .frame(width: 45, height: 45)
                .background(Color.green)
                .border(Color.black, width: 0.5)
            }
          }
        }
        .background(Color.black)
      }
    }
    .background(Color.black)
    .onAppear {
      startNewGame()
    }
  }

  func isUserTurnValid() -> Bool {
    return turn == userTurn
  }
  func onClick(x:Int, y:Int) {
    //    if board[x][y] == 0 && isMoveValid(x: x, y: y){
    ////          updateBoard(x: x, y: y)
    //
    //        }

    if isUserTurnValid(){
      if board[x][y] == 0 && isMoveValid(x: x, y: y){
        let moveData = MoveData(x:x, y:y, turn: turn)
//        moveToServer(moveData: moveData)
      }
    }
  }

  //   指定されたマスに駒を置くことが有効かどうかを判断
  func isMoveValid(x: Int, y: Int) -> Bool {
    let validDirections = checkAllDirections(x: x, y: y)

    if(validDirections.isEmpty){
      return false
    }
    return !validDirections.isEmpty
  }

  // すべての方向をチェックして、反転可能な駒のリストを返す関数
  func checkAllDirections(x: Int, y: Int) -> [(Int, Int)] {
    var validDirections: [(Int, Int)] = []
    for dx in -1...1 {
      for dy in -1...1 {
        if dx == 0 && dy == 0 { continue }
        let pieces = checkDirection(x: x, y: y, dx: dx, dy: dy)
        if !pieces.isEmpty {
          validDirections.append(contentsOf: pieces)
        }
      }
    }
    return validDirections
  }

  func updateBoard(x: Int, y: Int) {
    var validDirections: [(Int, Int)] = []

    // 盤面の範囲内で隣接するマスを確認
    for dx in -1...1 {
      for dy in -1...1 {
        if dx == 0 && dy == 0 { continue } // 同じマスはスキップ

        let pieces = checkDirection(x: x, y: y, dx: dx, dy: dy)
        if !pieces.isEmpty {
          validDirections.append(contentsOf: pieces)
        }
      }
    }
    if !validDirections.isEmpty {
      board[x][y] = turn
      // 有効な方向の駒を反転
      for (flipX, flipY) in validDirections {
        board[flipX][flipY] = turn
      }
      turn = 3 - turn
      PiceCounts()
    }
    checkNextTurnMoves()
  }



  func checkDirection(x: Int, y: Int, dx: Int, dy: Int) -> [(Int, Int)] {
    var newX = x + dx
    var newY = y + dy
    //反転可能なマスを記録
    var piecesToFlip: [(Int, Int)] = []

    while newX >= 0 && newX < rows && newY >= 0 && newY < columns {
      if board[newX][newY] == 3 - turn {
        piecesToFlip.append((newX, newY))
        newX += dx
        newY += dy
      } else if board[newX][newY] == turn {
        return piecesToFlip
      } else {
        break
      }
    }

    return []
  }
  func checkNextTurnMoves() {
    possibleMoves = []
    for row in 0..<rows {
      for col in 0..<columns {
        if board[row][col] == 0 && isMoveValid(x: row, y: col) {
          possibleMoves.append((row, col))
        }
      }
    }
    if possibleMoves.isEmpty{
      passCount+=1
      passMessage = turn == 1 ? "黒がパスしました" : "白がパスしました"
      turn = 3 - turn
      checkPossibleMovesAfterPass()
      if(passCount >= 2  || blackCount == 0 || whiteCount == 0 || isBoardFull()){
        //        endGame()
      }
    }else{
      passCount = 0
      passMessage = ""
    }
  }

  func checkPossibleMovesAfterPass() {
    possibleMoves = []
    for row in 0..<rows {
      for col in 0..<columns {
        if board[row][col] == 0 && isMoveValid(x: row, y: col) {
          possibleMoves.append((row, col))
        }
      }
    }
    if possibleMoves.isEmpty {
      // 連続パスの場合
      passCount += 1
      passMessage = turn == 1 ? "黒がパスしました" : "白がパスしました"
    } else {
      // パス後に候補地が存在する場合
      passCount = 0
      passMessage = ""
    }
  }
  func PiceCounts(){
    var newBlackCount = 0
    var newWhiteCount = 0

    for row in board {
      for cell in row {
        if cell == 1 {
          newBlackCount += 1
        } else if cell == 2 {
          newWhiteCount += 1
        }
      }
    }

    blackCount = newBlackCount
    whiteCount = newWhiteCount
  }

  func isBoardFull() -> Bool {
    for row in board {
      for cell in row {
        if cell == 0 { // 空のマスがある場合
          return false
        }
      }
    }
    return true // 全てのマスが埋まっている場合
  }
  func pieceView(at x: Int, y: Int) -> some View {
    let piece = board[x][y]
    let isPossibleMove = possibleMoves.contains(where: { $0 == (x, y) })
    return Group{
      if piece != 0 {
        Circle()
          .foregroundColor(pieceColor(piece))
      }else if isPossibleMove {
        Rectangle()
          .foregroundColor(Color.yellow.opacity(0.7)) // ハイライト色

      } else{
        Rectangle()
          .foregroundColor(pieceColor(piece))
      }
    }
  }
  // 駒の状態に応じた色を返す
  func pieceColor(_ piece: Int) -> Color {
    switch piece {
    case 0:
      return Color.green.opacity(0.5) // 透明な緑色
    case 1:
      return .black
    case 2:
      return .white
    default:
      return .clear
    }
  }


  // サーバーに移動を送信する関数
  //  func moveToServer(moveData: MoveData) {
  //    guard let url = URL(string: "http://localhost:31577/make-move") else { return }
  //    var request = URLRequest(url: url)
  //    request.httpMethod = "POST"
  //    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  //
  //    do {
  //      let jsonData = try JSONEncoder().encode(moveData)
  //      request.httpBody = jsonData
  //
  //      URLSession.shared.dataTask(with: request) { data, response, error in
  //        if let data = data {
  //          // サーバーからの応答を解析し、ゲームの状態を更新する
  //          updateGameState(from: data)
  //        }
  //      }.resume()
  //    } catch {
  //      print("JSONエンコードエラー: \(error)")
  //    }
  //  }

  func moveToServer(gameId:Int, x:Int, y:Int, turn:Int){
    let url = URL(string: "http://localhost:31577/make-move")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = ["gameId": gameId, "x":x, "y":y, "turn": turn]
    request.httpBody =  try? JSONSerialization.data(withJSONObject: body)

    URLSession.shared.dataTask(with: request){data, response, error in
      if let data = data{
        self.updateGameState(from: data)
      }
    }.resume()
  }
  struct MoveData: Codable {
    var x: Int
    var y: Int
    var turn: Int
  }
  // サーバーからの応答を解析し、UIを更新する
  func updateGameState(from data: Data) {
    do {
      let gameData = try JSONDecoder().decode(GameData.self, from: data)
      DispatchQueue.main.async {
        self.board = gameData.board
        self.turn = gameData.turn
        self.PiceCounts()
        self.checkNextTurnMoves()
      }
    } catch {
      print("JSON解析エラー: \(error)")
    }
  }

  // データの構造体（例）
  struct GameData: Codable {
    var board: [[Int]]
    var turn: Int
  }

  // サーバーから新しいゲームデータを取得する
  func startNewGame() {
    let url = URL(string: "http://localhost:31577/start-game")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data {
        self.updateGameState(from: data)
      }
    }.resume()
    print("start new game")
  }
}




#Preview {
  ContentView()
}