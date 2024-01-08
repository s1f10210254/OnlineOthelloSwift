import { prismaClient } from "$/service/prismaClient";
import { JsonValue } from "@prisma/client/runtime/library";

export const createNewGmeSession = async () => {
  const initialBoard = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 2, 0, 0, 0],
    [0, 0, 0, 2, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  const newGame = await prismaClient.game.create({
    data: {
      board: initialBoard,
      turn: 1,
    },
  });
  console.log("newGame", newGame.id);
  return newGame;
};

//指定されたマスにコマを置くことができるかどうか
const isMoveValid = (board: number[][], x: number, y: number, turn: number) => {
  const validDirections = checkAllDirections(board, x, y, turn);
  return validDirections.length > 0;
};

const checkAllDirections = (
  board: number[][],
  x: number,
  y: number,
  turn: number
) => {
  let validDirections = [];
  for (let dx = -1; dx <= 1; dx++) {
    for (let dy = -1; dy <= 1; dy++) {
      if (dx === 0 && dy === 0) continue;
      const pieces = checkDirection(board, x, y, dx, dy, turn);
      if (pieces.length > 0) {
        validDirections.push(...pieces);
      }
    }
  }
  return validDirections;
};

//盤面の範囲内で隣接するますを確認し、反転可能な駒のリストを返す
const checkDirection = (
  board: number[][],
  x: number,
  y: number,
  dx: number,
  dy: number,
  turn: number
) => {
  let newX = x + dx;
  let newY = y + dy;

  let picesToFlip = [];

  while (
    newX >= 0 &&
    newX < board.length &&
    newY >= 0 &&
    newX < board[0].length
  ) {
    if (board[newX][newY] === 3 - turn) {
      picesToFlip.push([newX, newY]);
      newX += dx;
      newY += dy;
    } else if (board[newX][newY] === turn) {
      return picesToFlip;
    } else {
      break;
    }
  }
  return [];
};

export const updateGameBoard = (
  board: number[][],
  x: number,
  y: number,
  turn: number
) => {
  if (!isMoveValid(board, x, y, turn)) {
    return board;
  }

  const validDirections = checkAllDirections(board, x, y, turn);

  const newBoard = board.map((row) => [...row]);
  newBoard[x][y] = turn;
  for (const [flipX, flipY] of validDirections) {
    newBoard[flipX][flipY] = turn;
  }
  // console.log(newBoard);
  return newBoard;
};
